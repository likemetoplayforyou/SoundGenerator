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
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 410
    Top = 117
    Width = 63
    Height = 13
    Alignment = taCenter
    AutoSize = False
    Caption = 'Label1'
  end
  object gbSettings: TGroupBox
    Left = 8
    Top = 8
    Width = 329
    Height = 162
    Caption = ' Settings '
    TabOrder = 0
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
    object cbKeybordStyle: TCheckBox
      Left = 16
      Top = 134
      Width = 97
      Height = 17
      Caption = 'Keybord style'
      TabOrder = 5
      OnClick = cbKeybordStyleClick
    end
  end
  object pnKeyBoard: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 173
    Width = 546
    Height = 150
    Align = alBottom
    TabOrder = 1
    object pbSoundKeys: TPaintBox
      Left = 1
      Top = 25
      Width = 544
      Height = 124
      Align = alClient
      OnMouseDown = pbSoundKeysMouseDown
      OnMouseMove = pbSoundKeysMouseMove
      OnMouseUp = pbSoundKeysMouseUp
      OnPaint = pbSoundKeysPaint
      ExplicitLeft = 0
      ExplicitTop = 31
    end
    object pnKeyCaptions: TPanel
      Left = 1
      Top = 1
      Width = 544
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      OnResize = pnKeyCaptionsResize
    end
  end
end
