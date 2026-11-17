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

// Gemeinsame Meldungs-, Passwort- und Ordnerdialoge über ihrem Besitzerfenster.
unit AppDialogs;

interface

uses
  Winapi.Windows, Vcl.Dialogs, Vcl.Forms;

procedure CenterFormOnPrimaryMonitor(const Dialog: TForm);
function CenteredFolderDialogExecute(const Dialog: TFileOpenDialog): Boolean;
function CenteredSelectDirectory(const Caption: string; var Directory: string): Boolean;
function CenteredSelectListItem(const Caption, Prompt: string; const Items: TArray<string>;
  out ItemIndex: Integer): Boolean;
procedure CenteredShowMessage(const Msg: string);
function CenteredMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
function CenteredMessageBox(const Text, Caption: string; Flags: Cardinal): Integer;
function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string = 'Abbrechen'): Integer;
function RequestPasswordOrSkipDialog(const DialogCaption, Prompt, SkipButtonCaption: string; out Password: string): Integer;

function RequestInstallationModeDialog: Integer;
function RequestSshFingerprintDialog(const Endpoint, Fingerprints: string; AllowOnce: Boolean): Integer;

implementation

uses
  System.SysUtils, System.Types, Vcl.Controls, Vcl.StdCtrls;

threadvar
  MessageBoxHook: HHOOK;
  NativeDialogOwner: HWND;

// Prefer the active application form, including an open setup or modal dialog.
// Das aktive Programmfenster bevorzugen, auch ein geöffnetes Setupfenster oder einen modalen Dialog.
function ActivePopupParent: TCustomForm;
begin
  Result := Screen.ActiveCustomForm;
  if Assigned(Result) and Result.HandleAllocated and IsWindowVisible(Result.Handle) then Exit;
  Result := Application.MainForm;
  if Assigned(Result) and Result.HandleAllocated then Exit;
  Result := nil;
end;

function ActiveFormHandle: HWND;
var
  PopupParent: TCustomForm;
begin
  PopupParent := ActivePopupParent;
  if Assigned(PopupParent) then Result := PopupParent.Handle
  else Result := Application.Handle;
end;

function PrimaryWorkArea: TRect;
var
  PrimaryMonitor: TMonitor;
begin
  PrimaryMonitor := Screen.PrimaryMonitor;
  if Assigned(PrimaryMonitor) then
    Result := PrimaryMonitor.WorkareaRect
  else
    Result := Screen.WorkAreaRect;
end;

// Use the visible owner's bounds, or the primary work area during startup.
// Über dem sichtbaren Besitzerfenster zentrieren, beim Start ersatzweise auf dem Hauptmonitor.
function DialogAnchorRect(OwnerHandle: HWND): TRect;
begin
  if IsWindowVisible(OwnerHandle) and not IsIconic(OwnerHandle) and
     GetWindowRect(OwnerHandle, Result) then Exit;
  Result := PrimaryWorkArea;
end;

procedure CenterWindowInRect(WindowHandle: HWND; const Anchor: TRect);
var
  DialogRect: TRect;
  DialogWidth, DialogHeight, NewLeft, NewTop: Integer;
  Control: TWinControl;
begin
  if not GetWindowRect(WindowHandle, DialogRect) then Exit;
  DialogWidth := DialogRect.Width;
  DialogHeight := DialogRect.Height;
  NewLeft := Anchor.Left + (Anchor.Width - DialogWidth) div 2;
  NewTop := Anchor.Top + (Anchor.Height - DialogHeight) div 2;

  // VCL-Koordinaten mitführen, damit die Anzeige die berechnete Position beibehält.
  Control := FindControl(WindowHandle);
  if Control is TCustomForm then
    Control.SetBounds(NewLeft, NewTop, DialogWidth, DialogHeight)
  else
    SetWindowPos(WindowHandle, 0, NewLeft, NewTop, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

// Legt PopupParent und Position vor ShowModal fest und hält den Dialog vor der Anwendung.
// Position darf nicht während OnShow/OnHide geändert werden, da dies das Fenster neu erzeugen kann.
procedure PrepareModalDialog(const Dialog: TForm);
var
  PopupParent: TCustomForm;
  OwnerHandle: HWND;
begin
  Dialog.Position := poDesigned;
  // Keep the computed position when VCL shows the dialog.
  // Die berechnete Position beim Anzeigen durch die VCL beibehalten.
  Dialog.DefaultMonitor := dmDesktop;
  OwnerHandle := 0;
  PopupParent := ActivePopupParent;
  if Assigned(PopupParent) then
  begin
    Dialog.PopupMode := pmExplicit;
    Dialog.PopupParent := PopupParent;
    OwnerHandle := PopupParent.Handle;
  end;
  Dialog.FormStyle := fsStayOnTop;
  CenterWindowInRect(Dialog.Handle, DialogAnchorRect(OwnerHandle));
  SetWindowPos(Dialog.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE);
  SetForegroundWindow(Dialog.Handle);
end;

// Zentriert den nativen Dialog bei seiner ersten Aktivierung und entfernt danach den Thread-Hook.
// Der aufrufende Dialogwrapper entfernt einen eventuell verbliebenen Hook im finally-Block.
function MessageBoxCbtHook(Code: Integer; WParam: WPARAM; LParam: LPARAM): LRESULT; stdcall;
begin
  if Code = HCBT_ACTIVATE then
  begin
    CenterWindowInRect(HWND(WParam), DialogAnchorRect(NativeDialogOwner));
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

// Einen zentrierten VCL-Meldungsdialog anzeigen und die gewählte Schaltfläche zurückgeben.
function CenteredMessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
var
  Dialog: TForm;
  DialogButtons: TMsgDlgButtons;
begin
  DialogButtons := Buttons;
  // Allow closing decision dialogs without treating X as Yes or No.
  // Entscheidungsdialoge mit X abbrechen, ohne Ja oder Nein auszuwählen.
  if (mbYes in Buttons) and (mbNo in Buttons) and not (mbCancel in Buttons) then
    Include(DialogButtons, mbCancel);
  Dialog := CreateMessageDialog(Msg, DlgType, DialogButtons);
  try
    Dialog.HelpContext := HelpCtx;
    PrepareModalDialog(Dialog);
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
  NativeDialogOwner := OwnerHandle;

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
    NativeDialogOwner := 0;
  end;
end;

// Verschiebt das Formular bei unveränderter Größe mittig auf den Hauptmonitor.
// Keine Änderung von Position: Der Aufruf ist damit auch aus OnShow ohne RecreateWnd vorgesehen.
procedure CenterFormOnPrimaryMonitor(const Dialog: TForm);
begin
  // Position changes recreate the window and are forbidden inside OnShow/OnHide.
  // Im OnShow/OnHide nur verschieben, ohne das Fenster neu zu erzeugen.
  CenterWindowInRect(Dialog.Handle, PrimaryWorkArea);
end;

// Startet die native Ordnerauswahl mit Besitzerhandle und zentriert ihr Fenster bei Aktivierung.
// Der Hook wird auch bei Abbruch oder Exception wieder entfernt.
function CenteredFolderDialogExecute(const Dialog: TFileOpenDialog): Boolean;
var
  OwnerHandle: HWND;
begin
  OwnerHandle := ActiveFormHandle;
  NativeDialogOwner := OwnerHandle;
  MessageBoxHook := SetWindowsHookEx(WH_CBT, @MessageBoxCbtHook, 0, GetCurrentThreadId);
  try
    Result := Dialog.Execute(OwnerHandle);
  finally
    if MessageBoxHook <> 0 then
    begin
      UnhookWindowsHookEx(MessageBoxHook);
      MessageBoxHook := 0;
    end;
    NativeDialogOwner := 0;
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

// Select a single list entry by index so callers can keep the original data separate.
// Einen Eintrag per Index auswählen, damit der Aufrufer die Originaldaten getrennt halten kann.
function CenteredSelectListItem(const Caption, Prompt: string; const Items: TArray<string>;
  out ItemIndex: Integer): Boolean;
var
  Dialog: TForm;
  PromptLbl: TLabel;
  ItemList: TListBox;
  ContinueBtn, CancelBtn: TButton;
  Item: string;
begin
  Result := False;
  ItemIndex := -1;
  if Length(Items) = 0 then Exit;

  Dialog := TForm.Create(nil);
  try
    Dialog.BorderStyle := bsDialog;
    Dialog.Caption := Caption;
    Dialog.ClientWidth := 420;
    Dialog.ClientHeight := 320;

    PromptLbl := TLabel.Create(Dialog);
    PromptLbl.Parent := Dialog;
    PromptLbl.Left := 16;
    PromptLbl.Top := 16;
    PromptLbl.Caption := Prompt;

    ItemList := TListBox.Create(Dialog);
    ItemList.Parent := Dialog;
    ItemList.SetBounds(16, 42, Dialog.ClientWidth - 32, 216);
    ItemList.IntegralHeight := False;
    ItemList.Items.BeginUpdate;
    try
      for Item in Items do
        ItemList.Items.Add(Item);
    finally
      ItemList.Items.EndUpdate;
    end;
    // Preserve the caller's order and preselect the first entry for keyboard navigation.
    // Die vorgegebene Reihenfolge beibehalten und den ersten Eintrag für die Tastaturbedienung vorwählen.
    ItemList.ItemIndex := 0;
    PromptLbl.FocusControl := ItemList;

    ContinueBtn := TButton.Create(Dialog);
    ContinueBtn.Parent := Dialog;
    ContinueBtn.SetBounds(188, 274, 104, 30);
    ContinueBtn.Caption := 'Weiter';
    ContinueBtn.ModalResult := mrOk;
    ContinueBtn.Default := True;

    CancelBtn := TButton.Create(Dialog);
    CancelBtn.Parent := Dialog;
    CancelBtn.SetBounds(300, 274, 104, 30);
    CancelBtn.Caption := 'Abbrechen';
    CancelBtn.ModalResult := mrCancel;
    CancelBtn.Cancel := True;

    Dialog.ActiveControl := ItemList;
    PrepareModalDialog(Dialog);
    if Dialog.ShowModal <> mrOk then Exit;
    ItemIndex := ItemList.ItemIndex;
    Result := ItemIndex >= 0;
  finally
    Dialog.Free;
  end;
end;

// Fragt ein maskiertes Passwort ab und prüft bei Bedarf die Wiederholung. Leere oder abweichende Angaben führen erneut zur Eingabe.
// Bei Abbruch bleibt das Ergebnis False; der temporäre Dialog wird in jedem Fall freigegeben.
function RequestPasswordDialog(const DialogCaption, Prompt: string; const ConfirmPassword: Boolean; out Password: string; const CancelButtonCaption: string): Integer;
var
  Dialog: TForm;
  PromptLbl, PasswordLbl, ConfirmLbl: TLabel;
  PasswordEdit, ConfirmEdit: TEdit;
  OkBtn, CancelBtn: TButton;
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
      CancelBtn.ModalResult := mrIgnore;
      CancelBtn.Cancel := False;
      if Length(CancelButtonCaption) > 16 then
        CancelButtonWidth := 260
      else
        CancelButtonWidth := 100;
      CancelBtn.Width := CancelButtonWidth;
      CancelBtn.Left := Dialog.ClientWidth - CancelButtonWidth - 16;
      CancelBtn.Top := ButtonTop;
      OkBtn.Left := CancelBtn.Left - OkBtn.Width - 8;

      Dialog.ClientHeight := ButtonTop + 48;
      PrepareModalDialog(Dialog);

      Result := Dialog.ShowModal;
      if Result <> mrOk then
        Exit;

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
      Result := mrOk;
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
      PrepareModalDialog(Dialog);

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

// Ask how to set up Paperless before running any local installation checks.
// Vor den lokalen Installationsprüfungen fragen, wo Paperless eingerichtet werden soll.
function RequestInstallationModeDialog: Integer;
var
  Dialog: TForm;
begin
  Dialog := CreateMessageDialog(
    'Wo möchten Sie Paperless einrichten?' + sLineBreak + sLineBreak +
    'Lokal: Paperless auf diesem PC mit Docker Desktop installieren.' + sLineBreak +
    'Server: Paperless auf einem entfernten Server einrichten.',
    mtConfirmation, [mbYes, mbNo], mbYes, ['Lokal', 'Server']);
  try
    Dialog.Caption := 'Paperless einrichten';
    PrepareModalDialog(Dialog);
    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

// Use the application style and select Cancel by default.
// Den Anwendungsstil verwenden und Abbrechen als Standardauswahl setzen.
function RequestSshFingerprintDialog(const Endpoint, Fingerprints: string; AllowOnce: Boolean): Integer;
var
  Dialog: TForm;
  Prompt: TLabel;
  FingerprintMemo: TMemo;
  ConfirmBtn, OnceBtn, CancelBtn: TButton;
begin
  Dialog := TForm.Create(nil);
  try
    Dialog.BorderStyle := bsDialog;
    Dialog.Caption := 'SSH-Fingerabdruck bestätigen';
    Dialog.ClientWidth := 680;
    Dialog.ClientHeight := 286;
    if Assigned(Application.MainForm) then
      Dialog.Font.Assign(Application.MainForm.Font);

    Prompt := TLabel.Create(Dialog);
    Prompt.Parent := Dialog;
    Prompt.AutoSize := False;
    Prompt.WordWrap := True;
    Prompt.SetBounds(16, 16, 648, 108);
    Prompt.Caption := 'Server ' + Endpoint + sLineBreak + sLineBreak +
      'Vergleichen Sie die angezeigten SSH-Fingerabdrücke mit denen auf Ihrem Server. ' +
      'Bestätigen Sie nur, wenn sie übereinstimmen.' + sLineBreak +
      'Das Programm speichert neue Schlüssel erst nach erfolgreicher SSH-Anmeldung.';

    FingerprintMemo := TMemo.Create(Dialog);
    FingerprintMemo.Parent := Dialog;
    FingerprintMemo.SetBounds(16, 132, 648, 88);
    FingerprintMemo.ReadOnly := True;
    FingerprintMemo.WordWrap := False;
    FingerprintMemo.ScrollBars := ssBoth;
    FingerprintMemo.Text := Fingerprints;

    ConfirmBtn := TButton.Create(Dialog);
    ConfirmBtn.Parent := Dialog;
    ConfirmBtn.SetBounds(140, 236, 196, 32);
    ConfirmBtn.Caption := 'Bestätigen und speichern';
    ConfirmBtn.ModalResult := mrYes;

    if AllowOnce then
    begin
      OnceBtn := TButton.Create(Dialog);
      OnceBtn.Parent := Dialog;
      OnceBtn.SetBounds(344, 236, 196, 32);
      OnceBtn.Caption := 'Nur diesmal bestätigen';
      OnceBtn.ModalResult := mrNo;
    end
    else
      ConfirmBtn.Left := 344;

    CancelBtn := TButton.Create(Dialog);
    CancelBtn.Parent := Dialog;
    CancelBtn.SetBounds(548, 236, 116, 32);
    CancelBtn.Caption := 'Abbrechen';
    CancelBtn.ModalResult := mrCancel;
    CancelBtn.Cancel := True;
    CancelBtn.Default := True;
    Dialog.ActiveControl := CancelBtn;
    PrepareModalDialog(Dialog);
    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

end.
