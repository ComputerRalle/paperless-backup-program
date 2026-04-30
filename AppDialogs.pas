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

implementation

uses
  System.Types, Vcl.Forms, Vcl.Controls;

threadvar
  MessageBoxHook: HHOOK;

// Return the rectangle that should own centered dialogs.
// Das Rechteck zurueckgeben, an dem Dialoge zentriert werden sollen.
function MainFormRect: TRect;
begin
  if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated then
    GetWindowRect(Application.MainForm.Handle, Result)
  else
    Result := Screen.WorkAreaRect;
end;

// Center a window over the main form.
// Ein Fenster ueber dem Hauptformular zentrieren.
procedure CenterWindowOnMainForm(WindowHandle: HWND);
var
  OwnerRect, DialogRect: TRect;
  DialogWidth, DialogHeight, NewLeft, NewTop: Integer;
begin
  if WindowHandle = 0 then Exit;

  OwnerRect := MainFormRect;
  GetWindowRect(WindowHandle, DialogRect);
  DialogWidth := DialogRect.Right - DialogRect.Left;
  DialogHeight := DialogRect.Bottom - DialogRect.Top;
  NewLeft := OwnerRect.Left + ((OwnerRect.Right - OwnerRect.Left) - DialogWidth) div 2;
  NewTop := OwnerRect.Top + ((OwnerRect.Bottom - OwnerRect.Top) - DialogHeight) div 2;

  SetWindowPos(WindowHandle, 0, NewLeft, NewTop, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

// Center native Windows message boxes as soon as they are activated.
// Native Windows-Messageboxen beim Aktivieren zentrieren.
function MessageBoxCbtHook(Code: Integer; WParam: WPARAM; LParam: LPARAM): LRESULT; stdcall;
begin
  if Code = HCBT_ACTIVATE then
  begin
    CenterWindowOnMainForm(HWND(WParam));
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
begin
  Dialog := CreateMessageDialog(Msg, DlgType, Buttons);
  try
    Dialog.HelpContext := HelpCtx;
    Dialog.Position := poMainFormCenter;
    CenterWindowOnMainForm(Dialog.Handle);
    Result := Dialog.ShowModal;
  finally
    Dialog.Free;
  end;
end;

function CenteredMessageBox(const Text, Caption: string; Flags: Cardinal): Integer;
var
  OwnerHandle: HWND;
begin
  if Assigned(Application.MainForm) and Application.MainForm.HandleAllocated then
    OwnerHandle := Application.MainForm.Handle
  else
    OwnerHandle := Application.Handle;

  MessageBoxHook := SetWindowsHookEx(WH_CBT, @MessageBoxCbtHook, 0, GetCurrentThreadId);
  try
    Result := Winapi.Windows.MessageBox(OwnerHandle, PChar(Text), PChar(Caption), Flags);
  finally
    if MessageBoxHook <> 0 then
    begin
      UnhookWindowsHookEx(MessageBoxHook);
      MessageBoxHook := 0;
    end;
  end;
end;

end.
