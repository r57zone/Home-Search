object TagsForm: TTagsForm
  Left = 192
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1057#1086#1079#1076#1072#1085#1080#1077' '#1090#1077#1075#1086#1074
  ClientHeight = 289
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 189
    Top = 48
    Width = 24
    Height = 13
    Caption = #1058#1077#1075#1080
  end
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 29
    Height = 13
    Caption = #1060#1072#1081#1083
  end
  object AddBtn: TButton
    Left = 88
    Top = 8
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = AddBtnClick
  end
  object RemBtn: TButton
    Left = 262
    Top = 8
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 3
    OnClick = RemBtnClick
  end
  object ClearBtn: TButton
    Left = 342
    Top = 8
    Width = 75
    Height = 25
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100
    TabOrder = 4
    OnClick = ClearBtnClick
  end
  object SaveBtn: TButton
    Left = 8
    Top = 256
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 5
    OnClick = SaveBtnClick
  end
  object CancelBtn: TButton
    Left = 88
    Top = 256
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 6
    OnClick = CancelBtnClick
  end
  object FilesTagsLB: TListBox
    Left = 8
    Top = 64
    Width = 409
    Height = 185
    ItemHeight = 13
    TabOrder = 7
    TabWidth = 120
  end
  object OpenBtn: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 0
    OnClick = OpenBtnClick
  end
  object EditBtn: TButton
    Left = 168
    Top = 8
    Width = 89
    Height = 25
    Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 2
    OnClick = EditBtnClick
  end
end
