object znInputBox: TznInputBox
  Left = 252
  Top = 289
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 99
  ClientWidth = 287
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 12
    Top = 10
    Width = 265
    Height = 19
    AutoSize = False
    Caption = #25552#31034':'
    Layout = tlBottom
    WordWrap = True
  end
  object Edit1: TEdit
    Left = 12
    Top = 34
    Width = 265
    Height = 20
    TabOrder = 0
    Text = 'Edit1'
  end
  object BtnOK: TButton
    Left = 55
    Top = 66
    Width = 72
    Height = 22
    Caption = #30830#23450
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BtnExit: TButton
    Left = 155
    Top = 66
    Width = 72
    Height = 22
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
