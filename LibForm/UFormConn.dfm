object fFormConnDB: TfFormConnDB
  Left = 209
  Top = 164
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 395
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    354
    395)
  PixelsPerInch = 96
  TextHeight = 12
  object wPage: TPageControl
    Left = 10
    Top = 12
    Width = 331
    Height = 342
    ActivePage = Sheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object Sheet1: TTabSheet
      Caption = #25968#25454#24211
      DesignSize = (
        323
        315)
      object Group1: TGroupBox
        Left = 10
        Top = 5
        Width = 300
        Height = 301
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        DesignSize = (
          300
          301)
        object Label1: TLabel
          Left = 15
          Top = 25
          Width = 30
          Height = 12
          Caption = #31867#22411':'
        end
        object Label2: TLabel
          Left = 15
          Top = 78
          Width = 42
          Height = 12
          Caption = #29992#25143#21517':'
        end
        object Label3: TLabel
          Left = 15
          Top = 105
          Width = 30
          Height = 12
          Caption = #23494#30721':'
        end
        object Label4: TLabel
          Left = 15
          Top = 131
          Width = 42
          Height = 12
          Caption = #25991#20214#21517':'
        end
        object Label5: TLabel
          Left = 15
          Top = 211
          Width = 54
          Height = 12
          Caption = #25968#25454#24211#21517':'
        end
        object Label6: TLabel
          Left = 15
          Top = 238
          Width = 54
          Height = 12
          Caption = #25968#25454#28304#21517':'
        end
        object Bevel1: TBevel
          Left = 10
          Top = 55
          Width = 280
          Height = 8
          Anchors = [akLeft, akTop, akRight]
          Shape = bsTopLine
          Style = bsRaised
        end
        object Label7: TLabel
          Left = 15
          Top = 158
          Width = 54
          Height = 12
          Caption = #20027#26426#22320#22336':'
        end
        object Label8: TLabel
          Left = 15
          Top = 185
          Width = 54
          Height = 12
          Caption = #36830#25509#31471#21475':'
        end
        object DBName: TComboBox
          Left = 72
          Top = 20
          Width = 212
          Height = 20
          Style = csDropDownList
          ItemHeight = 12
          TabOrder = 0
          OnChange = DBNameChange
        end
        object Edit_User: TEdit
          Left = 72
          Top = 75
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 1
          OnKeyDown = Edit_UserKeyDown
        end
        object Edit_Pwd: TEdit
          Left = 72
          Top = 102
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          PasswordChar = '*'
          TabOrder = 2
          OnKeyDown = Edit_UserKeyDown
        end
        object Edit_File: TEdit
          Left = 72
          Top = 128
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 3
          OnKeyDown = Edit_UserKeyDown
        end
        object Edit_DB: TEdit
          Left = 72
          Top = 208
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 6
          OnKeyDown = Edit_UserKeyDown
        end
        object Edit_DS: TEdit
          Left = 72
          Top = 235
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 7
          OnKeyDown = Edit_UserKeyDown
        end
        object BtnTest: TButton
          Left = 209
          Top = 267
          Width = 75
          Height = 22
          Anchors = [akRight, akBottom]
          Caption = #27979#35797
          TabOrder = 8
          OnClick = BtnTestClick
        end
        object Edit_Host: TEdit
          Left = 72
          Top = 155
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 4
          OnKeyDown = Edit_UserKeyDown
        end
        object Edit_Port: TEdit
          Left = 72
          Top = 182
          Width = 212
          Height = 20
          BevelKind = bkTile
          BorderStyle = bsNone
          TabOrder = 5
          OnKeyDown = Edit_UserKeyDown
        end
      end
    end
  end
  object BtnOK: TButton
    Left = 194
    Top = 363
    Width = 65
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #30830#23450
    TabOrder = 1
    OnClick = BtnOKClick
  end
  object BtnExit: TButton
    Left = 276
    Top = 363
    Width = 65
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = #21462#28040
    ModalResult = 2
    TabOrder = 2
  end
end
