object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'frmMain'
  ClientHeight = 326
  ClientWidth = 552
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object PaintBox1: TPaintBox
    Left = 8
    Top = 176
    Width = 105
    Height = 105
  end
  object lblOrigFreq: TLabel
    Left = 8
    Top = 38
    Width = 94
    Height = 13
    Caption = 'Original Frequency:'
  end
  object lblGeneratorType: TLabel
    Left = 8
    Top = 11
    Width = 78
    Height = 13
    Caption = 'Generator type:'
  end
  object lblObertonCount: TLabel
    Left = 8
    Top = 65
    Width = 74
    Height = 13
    Caption = 'Oberton count:'
  end
  object btnStart: TButton
    Left = 16
    Top = 293
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object btnStop: TButton
    Left = 104
    Top = 293
    Width = 75
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = btnStopClick
  end
  object edOrigFreq: TEdit
    Left = 108
    Top = 35
    Width = 71
    Height = 21
    TabOrder = 2
  end
  object cbGeneratorType: TComboBox
    Left = 108
    Top = 8
    Width = 181
    Height = 21
    Style = csDropDownList
    TabOrder = 3
  end
  object edObertonCount: TSpinEdit
    Left = 108
    Top = 62
    Width = 71
    Height = 22
    MaxValue = 50000
    MinValue = 1
    TabOrder = 4
    Value = 1
  end
end
