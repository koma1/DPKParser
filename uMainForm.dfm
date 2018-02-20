object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'DPK Sorter (DevExpress install helper)'
  ClientHeight = 461
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    832
    461)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDefaultExt: TLabel
    Left = 78
    Top = 11
    Width = 24
    Height = 13
    Caption = '.dpk'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object edtFolderName: TEdit
    Left = 107
    Top = 8
    Width = 580
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = edtFolderNameChange
  end
  object btnSelectFolder: TButton
    Left = 693
    Top = 6
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = btnSelectFolderClick
  end
  object btnFindDPK: TButton
    Left = 724
    Top = 6
    Width = 108
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Find&&Sort DPK'#39's'
    TabOrder = 2
    OnClick = btnFindDPKClick
  end
  object pcLog: TPageControl
    Left = 0
    Top = 223
    Width = 832
    Height = 238
    ActivePage = tsLogInfo
    Align = alBottom
    TabOrder = 3
    object tsLogInfo: TTabSheet
      Caption = 'Info'
      ImageIndex = 3
      object mmoLogInfo: TMemo
        Left = 0
        Top = 0
        Width = 824
        Height = 210
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsLogHint: TTabSheet
      Caption = 'Hint'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmoLogHint: TMemo
        Left = 0
        Top = 0
        Width = 824
        Height = 210
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsLogWarning: TTabSheet
      Caption = 'Warning'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmoLogWarning: TMemo
        Left = 0
        Top = 0
        Width = 824
        Height = 210
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsLogError: TTabSheet
      Caption = 'Error'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object mmoLogError: TMemo
        Left = 0
        Top = 0
        Width = 824
        Height = 210
        Align = alClient
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object tsPkgNotFound: TTabSheet
      Caption = 'Missed packages'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lstPkgNotFound: TListBox
        Left = 0
        Top = 0
        Width = 824
        Height = 210
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object lstFiles: TListBox
    Left = 0
    Top = 35
    Width = 832
    Height = 182
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    MultiSelect = True
    PopupMenu = pmFiles
    TabOrder = 4
    OnMouseDown = lstFilesMouseDown
  end
  object edtMask: TEdit
    Left = 9
    Top = 8
    Width = 65
    Height = 21
    TabOrder = 5
    Text = '*RS24'
  end
  object dlgFolder: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist, fdoFileMustExist, fdoCreatePrompt]
    Left = 112
    Top = 80
  end
  object ApplicationEvents: TApplicationEvents
    OnException = ApplicationEventsException
    Left = 312
    Top = 128
  end
  object pmFiles: TPopupMenu
    Left = 456
    Top = 136
  end
end
