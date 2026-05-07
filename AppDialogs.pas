// --------------------------------------------------------------
// Original author: Ralf-Peter Kleinert - 2025
// Ursprünglicher Autor: Ralf-Peter Kleinert - 2025
// Alias: #ComputerRalle / DIGITAL-easy
// Künstlername: #ComputerRalle / DIGITAL-easy
// Project: Paperless Backup Program / Paperless Backup Programm
// Projekt: Paperless Backup Program / Paperless Backup Programm
// Website: https://ralf-peter-kleinert.de
// Webseite: https://ralf-peter-kleinert.de
// YouTube: https://www.youtube.com/@ralf-peter-kleinert
// YouTube-Kanal: https://www.youtube.com/@ralf-peter-kleinert
// Copyright (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// Urheberrecht (C) 2026 Ralf-Peter Kleinert / ComputerRalle
// GNU General Public License v3 - see LICENSE.txt in the repository
// GNU General Public License v3 - siehe LICENSE.txt im Repository
// --------------------------------------------------------------

unit AppDialogs;

interface

uses
  Winapi.Windows, Vcl.Dialogs;

procedure CenteredShowMessage(const Msg: string);
function CenteredMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
function CenteredMessageBox(const Text, Caption: string; Flags: Cardinal): Integer;
function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string = 'Abbrechen'): Boolean;
function RequestPasswordOrSkipDialog(const DialogCaption, Prompt, SkipButtonCaption: string; out Password: string): Integer;

implementation

uses
  System.SysUtils, System.Types, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls;

threadvar
  MessageBoxHook: HHOOK;
  MessageBoxOwnerHandle: HWND;

// Return the rectangle that should own centered dialogs.
// Das Rechteck zurueckgeben, an dem Dialoge zentriert werden sollen.
function ActiveFormHandle: HWND;
var
  ActiveForm: TCustomForm;
begin
  ActiveForm := Screen.ActiveCustomForm;
  if Assigned(ActiveForm) and ActiveForm.HandleAllocated then
  begin
    Result := ActiveForm.Handle;
    Exit;
  end;

  if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated then
  begin
    Result := Application.MainForm.Handle;
    Exit;
  end;

  Result := Application.Handle;
end;

// Return the form that should act as popup parent for modal dialogs.
// Das Formular zurueckgeben, das Popup-Parent fuer modale Dialoge sein soll.
function ActivePopupParent: TCustomForm;
begin
  Result := Screen.ActiveCustomForm;
  if Assigned(Result) and Result.HandleAllocated then Exit;

  if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated then
    Result := Application.MainForm
  else
    Result := nil;
end;

// Return the rectangle of the form that should own centered dialogs.
// Das Rechteck des Formulars zurueckgeben, zu dem Dialoge gehoeren sollen.
function OwnerFormRect(const OwnerHandle: HWND): TRect;
begin
  if (OwnerHandle = 0) or not GetWindowRect(OwnerHandle, Result) then
    Result := Screen.WorkAreaRect;
end;

// Center a window over its owning form.
// Ein Fenster ueber seinem besitzenden Formular zentrieren.
procedure CenterWindowOnOwner(WindowHandle, OwnerHandle: HWND);
var
  OwnerRect, DialogRect: TRect;
  DialogWidth, DialogHeight, NewLeft, NewTop: Integer;
begin
  if WindowHandle = 0 then Exit;

  OwnerRect := OwnerFormRect(OwnerHandle);
  GetWindowRect(WindowHandle, DialogRect);
  DialogWidth := DialogRect.Right - DialogRect.Left;
  DialogHeight := DialogRect.Bottom - DialogRect.Top;
  NewLeft := OwnerRect.Left + ((OwnerRect.Right - OwnerRect.Left) - DialogWidth) div 2;
  NewTop := OwnerRect.Top + ((OwnerRect.Bottom - OwnerRect.Top) - DialogHeight) div 2;

  SetWindowPos(WindowHandle, 0, NewLeft, NewTop, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

// Prepare a modal dialog so it stays in front of the active application form.
// Einen modalen Dialog so vorbereiten, dass er vor dem aktiven Formular bleibt.
procedure PrepareModalDialog(const Dialog: TForm; const OwnerHandle: HWND);
var
  PopupParent: TCustomForm;
begin
  Dialog.Position := poDesigned;
  PopupParent := ActivePopupParent;
  if Assigned(PopupParent) then
  begin
    Dialog.PopupMode := pmExplicit;
    Dialog.PopupParent := PopupParent;
  end;
  Dialog.FormStyle := fsStayOnTop;
  CenterWindowOnOwner(Dialog.Handle, OwnerHandle);
  SetWindowPos(Dialog.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  SetForegroundWindow(Dialog.Handle);
end;

// Center native Windows message boxes as soon as they are activated.
// Native Windows-Messageboxen beim Aktivieren zentrieren.
function MessageBoxCbtHook(Code: Integer; WParam: WPARAM; LParam: LPARAM): LRESULT; stdcall;
begin
  if Code = HCBT_ACTIVATE then
  begin
    CenterWindowOnOwner(HWND(WParam), MessageBoxOwnerHandle);
    SetWindowPos(HWND(WParam), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
    SetForegroundWindow(HWND(WParam));
    if MessageBoxHook <> 0 then
    begin
      UnhookWindowsHookEx(MessageBoxHook);
      MessageBoxHook := 0;
    end;
  end;

  Result := CallNextHookEx(MessageBoxHook, Code, WParam, LParam);
end;

procedure CenteredShowMessage(const Msg: string);
begin
  CenteredMessageDlg(Msg, mtInformation, [mbOK], 0);
end;

function CenteredMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
var
  Dialog: TForm;
  OwnerHandle: HWND;
begin
  OwnerHandle := ActiveFormHandle;
  Dialog := CreateMessageDialog(Msg, DlgType, Buttons);
  try
    Dialog.HelpContext := HelpCtx;
    PrepareModalDialog(Dialog, OwnerHandle);
    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

function CenteredMessageBox(const Text, Caption: string; Flags: Cardinal): Integer;
var
  OwnerHandle: HWND;
begin
  OwnerHandle := ActiveFormHandle;
  MessageBoxOwnerHandle := OwnerHandle;

  MessageBoxHook := SetWindowsHookEx(WH_CBT, @MessageBoxCbtHook, 0, GetCurrentThreadId);
  try
    Result := Winapi.Windows.MessageBox(
      OwnerHandle,
      PChar(Text),
      PChar(Caption),
      Flags or MB_TOPMOST or MB_SETFOREGROUND or MB_SYSTEMMODAL);
  finally
    if MessageBoxHook <> 0 then
    begin
      UnhookWindowsHookEx(MessageBoxHook);
      MessageBoxHook := 0;
    end;
    MessageBoxOwnerHandle := 0;
  end;
end;

function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string): Boolean;
var
  Dialog: TForm;
  PromptLbl, PasswordLbl, ConfirmLbl: TLabel;
  PasswordEdit, ConfirmEdit: TEdit;
  OkBtn, CancelBtn: TButton;
  OwnerHandle: HWND;
  PromptTop, ButtonTop, CancelButtonWidth: Integer;
begin
  Result := False;
  Password := '';

  repeat
    Dialog := TForm.Create(nil);
    try
      Dialog.BorderStyle := bsDialog;
      Dialog.Caption := DialogCaption;
      Dialog.ClientWidth := 520;
      Dialog.ClientHeight := 250;

      PromptLbl := TLabel.Create(Dialog);
      PromptLbl.Parent := Dialog;
      PromptLbl.Left := 16;
      PromptLbl.Top := 16;
      PromptLbl.Width := Dialog.ClientWidth - 32;
      PromptLbl.AutoSize := False;
      PromptLbl.WordWrap := True;
      PromptLbl.Caption := Prompt;
      PromptLbl.Height := 92;

      PromptTop := PromptLbl.Top + PromptLbl.Height + 12;

      PasswordLbl := TLabel.Create(Dialog);
      PasswordLbl.Parent := Dialog;
      PasswordLbl.Left := 16;
      PasswordLbl.Top := PromptTop;
      PasswordLbl.Caption := 'Passwort:';

      PasswordEdit := TEdit.Create(Dialog);
      PasswordEdit.Parent := Dialog;
      PasswordEdit.Left := 160;
      PasswordEdit.Top := PasswordLbl.Top - 3;
      PasswordEdit.Width := Dialog.ClientWidth - 176;
      PasswordEdit.PasswordChar := '*';

      if ConfirmPassword then
      begin
        ConfirmLbl := TLabel.Create(Dialog);
        ConfirmLbl.Parent := Dialog;
        ConfirmLbl.Left := 16;
        ConfirmLbl.Top := PasswordLbl.Top + 36;
        ConfirmLbl.Caption := 'Passwort wiederholen:';

        ConfirmEdit := TEdit.Create(Dialog);
        ConfirmEdit.Parent := Dialog;
        ConfirmEdit.Left := 160;
        ConfirmEdit.Top := ConfirmLbl.Top - 3;
        ConfirmEdit.Width := Dialog.ClientWidth - 176;
        ConfirmEdit.PasswordChar := '*';
        ButtonTop := ConfirmEdit.Top + 42;
      end
      else
      begin
        ConfirmEdit := nil;
        ButtonTop := PasswordEdit.Top + 42;
      end;

      OkBtn := TButton.Create(Dialog);
      OkBtn.Parent := Dialog;
      OkBtn.Caption := 'OK';
      OkBtn.ModalResult := mrOk;
      OkBtn.Default := True;
      OkBtn.Width := 100;
      OkBtn.Top := ButtonTop;

      CancelBtn := TButton.Create(Dialog);
      CancelBtn.Parent := Dialog;
      CancelBtn.Caption := CancelButtonCaption;
      CancelBtn.ModalResult := mrCancel;
      CancelBtn.Cancel := True;
      if Length(CancelButtonCaption) > 16 then
        CancelButtonWidth := 260
      else
        CancelButtonWidth := 100;
      CancelBtn.Width := CancelButtonWidth;
      CancelBtn.Left := Dialog.ClientWidth - CancelButtonWidth - 16;
      CancelBtn.Top := ButtonTop;
      OkBtn.Left := CancelBtn.Left - OkBtn.Width - 8;

      Dialog.ClientHeight := ButtonTop + 48;
      OwnerHandle := ActiveFormHandle;
      PrepareModalDialog(Dialog, OwnerHandle);

      if Dialog.ShowModal <> mrOk then
        Exit(False);

      if Trim(PasswordEdit.Text) = '' then
      begin
        CenteredShowMessage('Bitte geben Sie ein Passwort ein.');
        Continue;
      end;

      if ConfirmPassword then
      begin
        if PasswordEdit.Text <> ConfirmEdit.Text then
        begin
          CenteredShowMessage('Die Passwörter stimmen nicht überein.');
          Continue;
        end;
      end;

      Password := PasswordEdit.Text;
      Result := True;
      Exit;
    finally
      Dialog.Free;
    end;
  until False;
end;

function RequestPasswordOrSkipDialog(const DialogCaption, Prompt, SkipButtonCaption: string; out Password: string): Integer;
var
  Dialog: TForm;
  PromptLbl, PasswordLbl: TLabel;
  PasswordEdit: TEdit;
  OkBtn, SkipBtn, CancelBtn: TButton;
  OwnerHandle: HWND;
  ButtonTop: Integer;
begin
  Password := '';

  repeat
    Dialog := TForm.Create(nil);
    try
      Dialog.BorderStyle := bsDialog;
      Dialog.Caption := DialogCaption;
      Dialog.ClientWidth := 640;
      Dialog.ClientHeight := 250;

      PromptLbl := TLabel.Create(Dialog);
      PromptLbl.Parent := Dialog;
      PromptLbl.Left := 16;
      PromptLbl.Top := 16;
      PromptLbl.Width := Dialog.ClientWidth - 32;
      PromptLbl.AutoSize := False;
      PromptLbl.WordWrap := True;
      PromptLbl.Caption := Prompt;
      PromptLbl.Height := 92;

      PasswordLbl := TLabel.Create(Dialog);
      PasswordLbl.Parent := Dialog;
      PasswordLbl.Left := 16;
      PasswordLbl.Top := PromptLbl.Top + PromptLbl.Height + 12;
      PasswordLbl.Caption := 'Passwort:';

      PasswordEdit := TEdit.Create(Dialog);
      PasswordEdit.Parent := Dialog;
      PasswordEdit.Left := 160;
      PasswordEdit.Top := PasswordLbl.Top - 3;
      PasswordEdit.Width := Dialog.ClientWidth - 176;
      PasswordEdit.PasswordChar := '*';

      ButtonTop := PasswordEdit.Top + 42;

      OkBtn := TButton.Create(Dialog);
      OkBtn.Parent := Dialog;
      OkBtn.Caption := 'OK';
      OkBtn.ModalResult := mrOk;
      OkBtn.Default := True;
      OkBtn.Width := 90;
      OkBtn.Left := Dialog.ClientWidth - 420;
      OkBtn.Top := ButtonTop;

      SkipBtn := TButton.Create(Dialog);
      SkipBtn.Parent := Dialog;
      SkipBtn.Caption := SkipButtonCaption;
      SkipBtn.ModalResult := mrIgnore;
      SkipBtn.Width := 200;
      SkipBtn.Left := Dialog.ClientWidth - 322;
      SkipBtn.Top := ButtonTop;

      CancelBtn := TButton.Create(Dialog);
      CancelBtn.Parent := Dialog;
      CancelBtn.Caption := 'Abbrechen';
      CancelBtn.ModalResult := mrCancel;
      CancelBtn.Cancel := True;
      CancelBtn.Width := 100;
      CancelBtn.Left := Dialog.ClientWidth - 108;
      CancelBtn.Top := ButtonTop;

      Dialog.ClientHeight := ButtonTop + 48;
      OwnerHandle := ActiveFormHandle;
      PrepareModalDialog(Dialog, OwnerHandle);

      Result := Dialog.ShowModal;
      if Result <> mrOk then
        Exit;

      if Trim(PasswordEdit.Text) = '' then
      begin
        CenteredShowMessage('Bitte geben Sie ein Passwort ein.');
        Continue;
      end;

      Password := PasswordEdit.Text;
      Exit;
    finally
      Dialog.Free;
    end;
  until False;
end;

end.
