// --------------------------------------------------------------
// Paperless Backup Program / Paperless Backup Programm
//
// Copyright (C) 2025-2026 Ralf-Peter Kleinert (#ComputerRalle / DIGITAL-easy)
// Website: https://ralf-peter-kleinert.de
// Website: https://computerralle.de
// YouTube: https://www.youtube.com/@ComputerRalle
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.fsf.org/licenses/>
// or check LICENSE.txt in this repository.
// --------------------------------------------------------------

// Gemeinsame Meldungs-, Passwort- und Ordnerdialoge. Alle werden am Hauptfenster ausgerichtet; vor dessen Anzeige dient der Monitor-Arbeitsbereich als Bezug.
unit AppDialogs;

interface

uses
  Winapi.Windows, Vcl.Dialogs, Vcl.Forms;

procedure CenterFormOnApplication(const Dialog: TForm);
function CenteredFolderDialogExecute(const Dialog: TFileOpenDialog): Boolean;
function CenteredSelectDirectory(const Caption: string; var Directory: string): Boolean;
procedure CenteredShowMessage(const Msg: string);
function CenteredMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
function CenteredMessageBox(const Text, Caption: string; Flags: Cardinal): Integer;
function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string = 'Abbrechen'): Boolean;
function RequestPasswordOrSkipDialog(const DialogCaption, Prompt, SkipButtonCaption: string; out Password: string): Integer;

implementation

uses
  System.SysUtils, System.Types, Winapi.MultiMon, Vcl.Controls, Vcl.StdCtrls;

threadvar
  MessageBoxHook: HHOOK;
  MessageBoxOwnerHandle: HWND;

// Vorwärtsdeklaration für die gemeinsame Auswahl des Bezugsfensters.
function ActivePopupParent: TCustomForm; forward;

// Liefert das Fensterhandle des Dialogbezugs; ohne geeignetes Formular wird das Application-Handle verwendet.
function ActiveFormHandle: HWND;
var
  PopupParent: TCustomForm;
begin
  PopupParent := ActivePopupParent;
  if Assigned(PopupParent) then Result := PopupParent.Handle
  else Result := Application.Handle;
end;

// Bevorzugt das Hauptfenster, damit die Zentrierung bei aktivem Setup- oder Passwortdialog nicht wandert.
// Falls noch kein Hauptfensterhandle vorhanden ist, dient das aktive Formular als Rückfall.
function ActivePopupParent: TCustomForm;
begin
  Result := Application.MainForm;
  if Assigned(Result) and Result.HandleAllocated then Exit;
  Result := Screen.ActiveCustomForm;
  if Assigned(Result) and Result.HandleAllocated then Exit;
  Result := nil;
end;
// Verwendet die tatsächlichen Bildschirmkoordinaten des sichtbaren Bezugsfensters.
// Vor dessen Anzeige gilt die Monitor-Arbeitsfläche, da die VCL-Startposition noch nicht endgültig ist.
function OwnerFormRect(const OwnerHandle: HWND): TRect;
var
  MonitorInfo: TMonitorInfo;
begin
  if (OwnerHandle <> 0) and IsWindowVisible(OwnerHandle) and
     GetWindowRect(OwnerHandle, Result) then Exit;

  // Vor Anzeige des Hauptfensters dessen Monitor-Arbeitsbereich verwenden.
  MonitorInfo.cbSize := SizeOf(MonitorInfo);
  if GetMonitorInfo(MonitorFromWindow(OwnerHandle, MONITOR_DEFAULTTONEAREST),
    @MonitorInfo) then
    Result := MonitorInfo.rcWork
  else
    Result := Screen.WorkAreaRect;
end;

// Berechnet die Mitte anhand der aktuellen Fenstergröße. VCL-Fenster erhalten synchronisierte Bounds; native Dialoge werden über SetWindowPos verschoben.
procedure CenterWindowOnOwner(WindowHandle, OwnerHandle: HWND);
var
  OwnerRect, DialogRect: TRect;
  DialogWidth, DialogHeight, NewLeft, NewTop: Integer;
  Control: TWinControl;
begin
  if WindowHandle = 0 then Exit;

  OwnerRect := OwnerFormRect(OwnerHandle);
  GetWindowRect(WindowHandle, DialogRect);
  DialogWidth := DialogRect.Right - DialogRect.Left;
  DialogHeight := DialogRect.Bottom - DialogRect.Top;
  NewLeft := OwnerRect.Left + ((OwnerRect.Right - OwnerRect.Left) - DialogWidth) div 2;
  NewTop := OwnerRect.Top + ((OwnerRect.Bottom - OwnerRect.Top) - DialogHeight) div 2;

  // VCL-Koordinaten mitführen, damit die Anzeige die berechnete Position beibehält.
  Control := FindControl(WindowHandle);
  if Control is TCustomForm then
    Control.SetBounds(NewLeft, NewTop, DialogWidth, DialogHeight)
  else
    SetWindowPos(WindowHandle, 0, NewLeft, NewTop, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

// Legt PopupParent und Position vor ShowModal fest und hält den Dialog vor der Anwendung.
// Position darf nicht während OnShow/OnHide geändert werden, da dies das Fenster neu erzeugen kann.
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

// Zentriert den nativen Dialog bei seiner ersten Aktivierung und entfernt danach den Thread-Hook.
// Der aufrufende Dialogwrapper entfernt einen eventuell verbliebenen Hook im finally-Block.
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

// Eine zentrierte Informationsmeldung mit dem aktiven Formular als Besitzer anzeigen.
procedure CenteredShowMessage(const Msg: string);
begin
  CenteredMessageDlg(Msg, mtInformation, [mbOK], 0);
end;

// Einen zentrierten VCL-Meldungsdialog anzeigen und die gewaehlte Schaltflaeche zurückgeben.
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

// Eine zentrierte native Windows-Messagebox anzeigen, die vor der Anwendung bleibt.
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

// Verschiebt das Formular bei unveränderter Größe auf den gemeinsamen Dialogbezug.
// Keine Änderung von Position: Der Aufruf ist damit auch aus OnShow ohne RecreateWnd vorgesehen.
procedure CenterFormOnApplication(const Dialog: TForm);
begin
  // Position changes recreate the window and are forbidden inside OnShow/OnHide.
  // Im OnShow/OnHide nur verschieben, ohne das Fenster neu zu erzeugen.
  CenterWindowOnOwner(Dialog.Handle, ActiveFormHandle);
end;

// Startet die native Ordnerauswahl mit Besitzerhandle und zentriert ihr Fenster bei Aktivierung.
// Der Hook wird auch bei Abbruch oder Exception wieder entfernt.
function CenteredFolderDialogExecute(const Dialog: TFileOpenDialog): Boolean;
var
  OwnerHandle: HWND;
begin
  OwnerHandle := ActiveFormHandle;
  MessageBoxOwnerHandle := OwnerHandle;
  MessageBoxHook := SetWindowsHookEx(WH_CBT, @MessageBoxCbtHook, 0, GetCurrentThreadId);
  try
    Result := Dialog.Execute(OwnerHandle);
  finally
    if MessageBoxHook <> 0 then
    begin
      UnhookWindowsHookEx(MessageBoxHook);
      MessageBoxHook := 0;
    end;
    MessageBoxOwnerHandle := 0;
  end;
end;

// Zeigt eine Dateisystem-Ordnerauswahl. Directory wird ausschließlich bei erfolgreicher Auswahl überschrieben.
function CenteredSelectDirectory(const Caption: string; var Directory: string): Boolean;
var
  Dialog: TFileOpenDialog;
begin
  Dialog := TFileOpenDialog.Create(nil);
  try
    Dialog.Title := Caption;
    Dialog.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
    if DirectoryExists(Directory) then Dialog.DefaultFolder := Directory;
    Result := CenteredFolderDialogExecute(Dialog);
    if Result then Directory := Dialog.FileName;
  finally
    Dialog.Free;
  end;
end;
// Fragt ein maskiertes Passwort ab und prüft bei Bedarf die Wiederholung. Leere oder abweichende Angaben führen erneut zur Eingabe.
// Bei Abbruch bleibt das Ergebnis False; der temporäre Dialog wird in jedem Fall freigegeben.
function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string): Boolean;
var
  Dialog: TForm;
  PromptLbl, PasswordLbl, ConfirmLbl: TLabel;
  PasswordEdit, ConfirmEdit: TEdit;
  OkBtn, CancelBtn: TButton;
  OwnerHandle: HWND;
  PromptTop, ButtonTop, CancelButtonWidth: Integer;
begin
  // Each normal exit assigns its result; cancellation returns False explicitly.
  // Jeder normale Ausgang setzt sein Ergebnis; Abbruch liefert ausdrücklich False.
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

// Unterscheidet Passwortbestätigung, ausdrückliches Überspringen und Abbruch über ModalResult.
// Die Eingabe bleibt maskiert; ohne Passwort kann nur übersprungen oder abgebrochen werden.
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
