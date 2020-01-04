object Main: TMain
  Left = 192
  Top = 124
  AlphaBlend = True
  AlphaBlendValue = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1073#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
  ClientHeight = 480
  ClientWidth = 467
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000000000000000000000000000000000000000000000000
    00000000000000000000000000003358DE3A3358DE993358DECA3358DEDC3358
    DEDC3358DEC83358DE943358DE30000000000000000000000000000000000000
    0000000000003358DE083358DE8E3358DEFE3358DEFF3358DEFF3358DEFF3358
    DEFF3358DEFF3358DEFF3358DEFA3257DE933358DE0400000000000000000000
    00003358DE073358DEBB3358DEFF3358DEFF3358DEFF3358DEFF3358DEFF3358
    DEFF3358DEFF3358DEFF3055DDFF3156DEFF3358DEBD3358DE03000000000000
    00003358DE863358DEFF3358DEFF3358DEFF3358DEFF3358DEFF3358DEFF3358
    DEFF3358DEFF2E54DDFF5D7AE3FFBEC8EEFF3156DEFF3358DE73000000003358
    DE2D3358DEF93358DEFF3358DEFF3358DEFF3258DEFF3358DEFF3358DEFF3358
    DEFF3257DEFF4769E1FFD9DFF1FF5170E1FF3358DEFF3358DEF23358DE203358
    DE8E3358DEFF3358DEFF3358DEFF2950DCFF4B6BE2FF7A92EAFF718AE8FF4668
    E1FF3B5EDFFFD4DAF0FF5F7CE3FF3156DEFF3358DEFF3358DEFF3358DE7E3358
    DEC93358DEFF3358DEFF2A50DCFF7D95EAFFBBC7F4FF7E95EAFF7991E9FFA9B9
    F2FFE1E6F5FF748DE6FF2E54DEFF3358DEFF3358DEFF3358DEFF3358DEB83358
    DEE83358DEFF3156DEFF627FE5FFB9C6F4FF274EDCFF2A50DDFF2B52DDFF224A
    DBFFA2B3F0FF7990E9FF3258DEFF3358DEFF3358DEFF3358DEFF3358DECE3358
    DEE63257DEFF2A51DCFFB0BFF2FF5776E4FF2E54DDFF3358DEFF3358DEFF3257
    DEFF395DDFFFB3C1F3FF3258DEFF3358DEFF3358DEFF3358DEFF3358DECD3358
    DEC43056DEFF2A51DCFFB9C6F4FF4466E1FF3157DEFF3358DEFF3358DEFF3358
    DEFF2A51DCFFA7B7F1FF3559DEFF3358DEFF3358DEFF3358DEFF3358DEB43358
    DE843257DEFF2B51DDFFACBCF2FF5E7CE5FF2C52DDFF3358DEFF3358DEFF3056
    DEFF3F62E0FFB6C3F3FF3156DEFF3358DEFF3358DEFF3358DEFF3358DE713358
    DE233358DEF83156DEFF5473E3FFBFCAF5FF3459DEFF274EDCFF284FDCFF2A51
    DDFFB5C2F3FF6E88E8FF3257DEFF3358DEFF3358DEFF3358DEEE3358DE170000
    00003358DE743358DEFF3156DEFF6884E7FFC1CDF5FF8DA2EDFF899FECFFBBC7
    F4FF7891E9FF3157DEFF3358DEFF3358DEFF3358DEFF3358DE61000000000000
    0000000000003358DEA33358DEFF3157DEFF355ADFFF4F6FE2FF5A77E5FF3C5F
    E0FF3257DEFF3358DEFF3358DEFF3358DEFF3358DE9400000000000000000000
    000000000000000000003358DE713358DEF03358DEFF3257DEFF2F55DDFF3156
    DEFF3358DEFF3358DEFF3358DEE83358DE630000000000000000000000000000
    00000000000000000000000000003358DE213358DE7C3358DEB83358DED73358
    DED63358DEB53358DE753358DE1B00000000000000000000000000000000F00F
    0000C00300008001000080010000000000000000000000000000000000000000
    000000000000000000000000000080010000C0030000E0070000F00F0000}
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PathSearchLbl: TLabel
    Left = 8
    Top = 8
    Width = 239
    Height = 13
    Caption = #1055#1072#1087#1082#1080' '#1076#1083#1103' '#1087#1086#1080#1089#1082#1072' ('#1085#1072#1087#1088#1080#1084#1077#1088', "C:\Documents"):'
  end
  object ExtFilesLbl: TLabel
    Left = 8
    Top = 144
    Width = 104
    Height = 13
    Caption = #1056#1072#1089#1096#1080#1088#1077#1085#1080#1103' '#1092#1072#1081#1083#1086#1074
  end
  object TypeFilesLbl: TLabel
    Left = 8
    Top = 200
    Width = 60
    Height = 13
    Caption = #1058#1080#1087' '#1092#1072#1081#1083#1086#1074
  end
  object IgnorePathLbl: TLabel
    Left = 8
    Top = 256
    Width = 261
    Height = 13
    Caption = #1048#1075#1085#1086#1088#1080#1088#1086#1074#1072#1090#1100' '#1087#1072#1087#1082#1080' ('#1085#1072#1087#1088#1080#1084#1077#1088', "C:\Program Files"):'
  end
  object CreateCatBtn: TButton
    Left = 8
    Top = 428
    Width = 75
    Height = 25
    Caption = #1057#1086#1079#1076#1072#1090#1100
    TabOrder = 17
    OnClick = CreateCatBtnClick
  end
  object ExtsEdit: TEdit
    Left = 8
    Top = 168
    Width = 369
    Height = 21
    TabOrder = 4
  end
  object AllCB: TCheckBox
    Left = 8
    Top = 224
    Width = 41
    Height = 17
    Caption = #1042#1089#1077
    TabOrder = 6
  end
  object TextCB: TCheckBox
    Left = 64
    Top = 224
    Width = 49
    Height = 17
    Caption = #1058#1077#1082#1089#1090
    TabOrder = 7
  end
  object PicsCB: TCheckBox
    Left = 128
    Top = 224
    Width = 73
    Height = 17
    Caption = #1050#1072#1088#1090#1080#1085#1082#1080
    TabOrder = 8
  end
  object ArchCB: TCheckBox
    Left = 336
    Top = 224
    Width = 65
    Height = 17
    Caption = #1040#1088#1093#1080#1074#1099
    TabOrder = 11
  end
  object ClearExtsBtn: TButton
    Left = 384
    Top = 168
    Width = 75
    Height = 21
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100
    TabOrder = 5
    OnClick = ClearExtsBtnClick
  end
  object IgnorePaths: TMemo
    Left = 8
    Top = 280
    Width = 369
    Height = 105
    ScrollBars = ssBoth
    TabOrder = 12
  end
  object AddIgnorePathBtn: TButton
    Left = 384
    Top = 280
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 13
    OnClick = AddIgnorePathBtnClick
  end
  object Paths: TMemo
    Left = 8
    Top = 32
    Width = 369
    Height = 105
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object AddPathBtn: TButton
    Left = 384
    Top = 32
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = AddPathBtnClick
  end
  object CancelBtn: TButton
    Left = 88
    Top = 428
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 18
    OnClick = CancelBtnClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 461
    Width = 467
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object OpenPathsBtn: TButton
    Left = 384
    Top = 64
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 2
    OnClick = OpenPathsBtnClick
  end
  object SavePathsBtn: TButton
    Left = 384
    Top = 96
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 3
    OnClick = SavePathsBtnClick
  end
  object OpenIgnorePathsBtn: TButton
    Left = 384
    Top = 312
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 14
    OnClick = OpenIgnorePathsBtnClick
  end
  object SaveIgnorePathsBtn: TButton
    Left = 384
    Top = 344
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 15
    OnClick = SaveIgnorePathsBtnClick
  end
  object VideoCB: TCheckBox
    Left = 208
    Top = 224
    Width = 57
    Height = 17
    Caption = #1042#1080#1076#1077#1086
    TabOrder = 9
  end
  object AudioCB: TCheckBox
    Left = 272
    Top = 224
    Width = 57
    Height = 17
    Caption = #1040#1091#1076#1080#1086
    TabOrder = 10
  end
  object TagsCB: TCheckBox
    Left = 8
    Top = 400
    Width = 201
    Height = 17
    Caption = #1042#1082#1083#1102#1095#1080#1090#1100' '#1090#1077#1075#1080' '#1080#1079' '#1092#1072#1081#1083#1086#1074' (tags.hst)'
    Checked = True
    State = cbChecked
    TabOrder = 16
  end
  object XPManifest: TXPManifest
    Left = 368
    Top = 432
  end
  object IdHTTPServer: TIdHTTPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 757
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    OnCommandGet = IdHTTPServerCommandGet
    Left = 400
    Top = 432
  end
  object SaveDialog: TSaveDialog
    Left = 336
    Top = 432
  end
  object PopupMenu: TPopupMenu
    Left = 432
    Top = 432
    object GoToSearchBtn: TMenuItem
      Caption = #1055#1086#1080#1089#1082
      OnClick = GoToSearchBtnClick
    end
    object Line: TMenuItem
      Caption = '-'
    end
    object DataBaseBtn: TMenuItem
      Caption = #1041#1072#1079#1099' '#1076#1072#1085#1085#1099#1093
      object DBCreateBtn: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        OnClick = DBCreateBtnClick
      end
      object Line3: TMenuItem
        Caption = '-'
      end
      object DBsOpen: TMenuItem
        Caption = #1054#1073#1079#1086#1088
        OnClick = DBsOpenClick
      end
    end
    object TagsBtn: TMenuItem
      Caption = #1058#1077#1075#1080
      object TagsCreateBtn: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        OnClick = TagsCreateBtnClick
      end
    end
    object Line2: TMenuItem
      Caption = '-'
    end
    object AboutBtn: TMenuItem
      Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077'...'
      OnClick = AboutBtnClick
    end
    object ExitBtn: TMenuItem
      Caption = #1042#1099#1093#1086#1076
      OnClick = ExitBtnClick
    end
  end
  object OpenDialog: TOpenDialog
    Left = 304
    Top = 432
  end
end
