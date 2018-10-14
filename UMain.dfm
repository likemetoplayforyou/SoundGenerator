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
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pbSoundKeys: TPaintBox
    Left = 8
    Top = 176
    Width = 529
    Height = 105
    OnMouseDown = pbSoundKeysMouseDown
    OnMouseMove = pbSoundKeysMouseMove
    OnMouseUp = pbSoundKeysMouseUp
    OnPaint = pbSoundKeysPaint
  end
  object Label1: TLabel
    Left = 506
    Top = 144
    Width = 31
    Height = 13
    Caption = 'Label1'
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 162
    Caption = ' Settings '
    TabOrder = 2
    object lblTonesPerOctave: TLabel
      Left = 16
      Top = 27
      Width = 95
      Height = 13
      Caption = 'Tone count/octave:'
    end
    object lblGeneratorType: TLabel
      Left = 16
      Top = 55
      Width = 78
      Height = 13
      Caption = 'Generator type:'
    end
    object lblOrigFreq: TLabel
      Left = 16
      Top = 82
      Width = 94
      Height = 13
      Caption = 'Original Frequency:'
    end
    object lblObertonCount: TLabel
      Left = 16
      Top = 109
      Width = 74
      Height = 13
      Caption = 'Oberton count:'
    end
    object edTonesPerOctave: TSpinEdit
      Left = 117
      Top = 24
      Width = 92
      Height = 22
      MaxValue = 50000
      MinValue = 1
      TabOrder = 0
      Value = 12
      OnExit = edTonesPerOctaveExit
    end
    object cbGeneratorType: TComboBox
      Left = 117
      Top = 52
      Width = 92
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object edOrigFreq: TEdit
      Left = 116
      Top = 79
      Width = 92
      Height = 21
      TabOrder = 2
      Text = '440'
    end
    object edObertonCount: TSpinEdit
      Left = 117
      Top = 106
      Width = 92
      Height = 22
      MaxValue = 50000
      MinValue = 1
      TabOrder = 3
      Value = 1
    end
    object btnApplySettings: TButton
      Left = 232
      Top = 22
      Width = 75
      Height = 25
      Caption = 'Apply'
      TabOrder = 4
      OnClick = btnApplySettingsClick
    end
    object cbKeyBordStyle: TCheckBox
      Left = 16
      Top = 134
      Width = 97
      Height = 17
      Caption = 'Keybord style'
      TabOrder = 5
    end
  end
end
