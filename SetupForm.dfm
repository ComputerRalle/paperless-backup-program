object SetupFrm: TSetupFrm
  Left = 0
  Top = 0
  Caption = 'Willkommen im Paperless Backup Programm'
  ClientHeight = 611
  ClientWidth = 844
  Color = clBtnFace
  Constraints.MaxHeight = 650
  Constraints.MaxWidth = 860
  Constraints.MinHeight = 650
  Constraints.MinWidth = 860
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Verdana'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 18
  object DockerGefundenLbl: TLabel
    Left = 20
    Top = 472
    Width = 593
    Height = 25
    AutoSize = False
    Caption = 'Docker Desktop wurde gefunden. Installation von Paperless-ngx ka' +
      'nn beginnen.'
    Visible = False
  end
  object BitteBestaetigenLbl: TLabel
    Left = 560
    Top = 472
    Width = 280
    Height = 25
    AutoSize = False
    Caption = '"Hinweis vertanden" best'#228'tigen:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object SieBenoetigenDockerLbl: TLabel
    Left = 20
    Top = 78
    Width = 820
    Height = 25
    AutoSize = False
    Caption = 
      'Sie ben'#246'tigen Docker Desktop f'#252'r Windows um das Paperless Backup' +
      ' Programm verwenden zu k'#246'nnen.'
  end
  object LinkKlickLbl: TLabel
    Left = 175
    Top = 114
    Width = 450
    Height = 25
    Cursor = crHandPoint
    AutoSize = False
    Caption = 'https://www.docker.com/products/docker-desktop/'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    OnClick = LinkClickLblClick
  end
  object Label1: TLabel
    Left = 20
    Top = 114
    Width = 149
    Height = 25
    AutoSize = False
    Caption = 'Docker Download:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object KeePassXCLbl: TLabel
    Left = 674
    Top = 114
    Width = 166
    Height = 25
    Cursor = crHandPoint
    AutoSize = False
    Caption = 'KeePassXC Video'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    Visible = False
    OnClick = KeePassXCLblClick
  end
  object WillkommenLbl: TLabel
    Left = 20
    Top = 114
    Width = 413
    Height = 25
    AutoSize = False
    Caption = 'Willkommen im Paperless Backup Programm von: '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
    Visible = False
  end
  object ComputerRalleLbl: TLabel
    Left = 435
    Top = 114
    Width = 142
    Height = 25
    Cursor = crHandPoint
    AutoSize = False
    Caption = '#ComputerRalle'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Verdana'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    Visible = False
    OnClick = ComputerRalleLblClick
  end
  object InstallLbl: TLabel
    Left = 21
    Top = 409
    Width = 738
    Height = 18
    Caption = 'Um ein Backup oder eine Wiederherstellung zu machen, muss das Pr' +
      'ogramm neu gestartet werden'
    Visible = False
  end
  object HinweisVerstandenBtn: TButton
    Left = 590
    Top = 504
    Width = 250
    Height = 60
    Caption = 'Hinweis verstanden'
    TabOrder = 1
    OnClick = NoticeAcceptedBtnClick
  end
  object Panel14: TPanel
    Left = 0
    Top = 0
    Width = 844
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    Color = 3767324
    ParentBackground = False
    TabOrder = 2
    object Label8: TLabel
      Left = 20
      Top = 19
      Width = 285
      Height = 20
      Caption = 'Paperless-ngx Backup Programm'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label9: TLabel
      Left = 579
      Top = 21
      Width = 249
      Height = 16
      Caption = 'Getestet mit: Paperless-ngx v2.20.15'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 592
    Width = 844
    Height = 19
    Panels = <>
    SizeGrip = False
  end
  object PaperlessInstallierenBtn: TButton
    Left = 21
    Top = 504
    Width = 250
    Height = 60
    Caption = 'Paperless installieren'
    Default = True
    TabOrder = 0
    OnClick = InstallPaperlessBtnClick
  end
  object HinweisMemo: TMemo
    Left = 20
    Top = 148
    Width = 820
    Height = 249
    Lines.Strings = (
      'Willkommen im Paperless Backup Programm.'
      ''
      
        'Dieser Hinweis wird beim ersten Start, und alle 30 Tage angezeig' +
        't.Wenn Ihr Paperless viele Dokumente '
      'enth'#228'lt, wird ein Backup entsprechend gro'#223' werden.'
      ''
      
        'W'#228'hlen Sie als Ziel einen Ordner aus, der '#252'ber gen'#252'gend Speicher' +
        'platz f'#252'r das Backup verf'#252'gt. Sollten Sie '
      
        'keinen Zielordner ausw'#228'hlen, wird der Ordner "Paperless Backup" ' +
        'auf dem Desktop angelegt.'
      ''
      
        'In Ihrem Benutzerordner wird au'#223'erdem ein Ordner namens "Paperle' +
        'ss Backup Programm" erstellt. Dieser '
      
        'Ordner enth'#228'lt Ihre pers'#246'nlichen Einstellungen. L'#246'schen Sie ihn ' +
        'nicht '#8211' sonst gehen alle Einstellungen '
      'verloren.'
      ''
      'Sie verwenden das Programm auf eigene Verantwortung.')
    ReadOnly = True
    TabOrder = 4
  end
  object ProgressBar2: TProgressBar
    Left = 20
    Top = 440
    Width = 820
    Height = 17
    TabOrder = 5
  end
end
