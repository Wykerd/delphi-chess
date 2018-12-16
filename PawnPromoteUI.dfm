object frmPawnPromote: TfrmPawnPromote
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Promote Pawn'
  ClientHeight = 68
  ClientWidth = 446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object cbxPromote: TComboBox
    Left = 8
    Top = 8
    Width = 431
    Height = 21
    TabOrder = 0
    Text = 'Choose to what to promote pawn'
    Items.Strings = (
      'Rook'
      'Bishop'
      'Knight'
      'Queen')
  end
  object btnPromote: TButton
    Left = 8
    Top = 35
    Width = 431
    Height = 25
    Caption = 'Promote'
    TabOrder = 1
    OnClick = btnPromoteClick
  end
end
