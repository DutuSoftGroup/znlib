object Form1: TForm1
  Left = 224
  Top = 132
  Width = 471
  Height = 381
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 0
    Top = 145
    Width = 463
    Height = 209
    Align = alClient
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 463
    Height = 145
    ButtonHeight = 20
    ButtonWidth = 109
    Caption = 'ToolBar1'
    ShowCaptions = True
    TabOrder = 1
    object ToolButton1: TToolButton
      Left = 0
      Top = 2
      Caption = 'ShowBackForm'
      ImageIndex = 0
      OnClick = ToolButton1Click
    end
    object ToolButton2: TToolButton
      Left = 109
      Top = 2
      Caption = 'ShowRestoreForm'
      ImageIndex = 1
      OnClick = ToolButton2Click
    end
    object ToolButton3: TToolButton
      Left = 218
      Top = 2
      Caption = 'Process_ShowForm'
      ImageIndex = 2
      OnClick = ToolButton3Click
    end
    object ToolButton4: TToolButton
      Left = 327
      Top = 2
      Caption = 'Process_CloseForm'
      ImageIndex = 3
      Wrap = True
      OnClick = ToolButton4Click
    end
    object ToolButton5: TToolButton
      Left = 0
      Top = 22
      Caption = 'Process_SetPos'
      ImageIndex = 4
      OnClick = ToolButton5Click
    end
    object ToolButton6: TToolButton
      Left = 109
      Top = 22
      Caption = 'PopMsg_Init'
      ImageIndex = 5
      OnClick = ToolButton6Click
    end
    object ToolButton7: TToolButton
      Left = 218
      Top = 22
      Caption = 'PopMsg_Free'
      ImageIndex = 6
      OnClick = ToolButton7Click
    end
    object ToolButton8: TToolButton
      Left = 327
      Top = 22
      Caption = 'PopMsg_ShowMsg'
      ImageIndex = 7
      Wrap = True
      OnClick = ToolButton8Click
    end
    object ToolButton9: TToolButton
      Left = 0
      Top = 42
      Caption = 'InputBox'
      ImageIndex = 8
      OnClick = ToolButton9Click
    end
    object ToolButton10: TToolButton
      Left = 109
      Top = 42
      Caption = 'InputPWDBox '
      ImageIndex = 9
      OnClick = ToolButton10Click
    end
    object ToolButton11: TToolButton
      Left = 218
      Top = 42
      Caption = 'ShowBackup'
      ImageIndex = 10
      OnClick = ToolButton11Click
    end
    object ToolButton12: TToolButton
      Left = 327
      Top = 42
      Caption = 'ShowRestore'
      ImageIndex = 11
      Wrap = True
      OnClick = ToolButton12Click
    end
    object ToolButton13: TToolButton
      Left = 0
      Top = 62
      Caption = 'ZipFile'
      ImageIndex = 12
      OnClick = ToolButton13Click
    end
    object ToolButton14: TToolButton
      Left = 109
      Top = 62
      Caption = 'UnZipFile'
      ImageIndex = 13
      OnClick = ToolButton14Click
    end
    object ToolButton15: TToolButton
      Left = 218
      Top = 62
      Caption = 'ZipStream'
      ImageIndex = 14
      OnClick = ToolButton15Click
    end
    object ToolButton16: TToolButton
      Left = 327
      Top = 62
      Caption = 'UnZipStream'
      ImageIndex = 15
      OnClick = ToolButton16Click
    end
  end
end
