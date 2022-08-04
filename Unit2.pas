unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TformGlpiTiket = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    Label3: TLabel;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Memo1: TMemo;
    Label6: TLabel;
    Edit1: TEdit;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  formGlpiTiket: TformGlpiTiket;

implementation

{$R *.dfm}

end.
