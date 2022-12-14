unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,JSON,System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient,
  IdCompressorZLib,
  IdMultipartFormData;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


const
  AppToken = 'hAQiq39NeHWaQ25t6cTkV8762VcHL2Tds7qBuLR4';
 // userToken = 'CaM4QneWuojgQPCHMiCO7Nz0GLsNfUSuEmmkNpa5';
  userToken = 'pRHHulWPKXqSrL3xS8vlSCqGIsOu7HWb7rJ3ixI4';
//  UserID = '32';
  UserID = '8';
  TiketType = 2;

var
  Form1: TForm1;
  session_token : string;
  GlpiUser, GlpiPassword, GlpiRestUrl : string;

implementation

{$R *.dfm}

function idHttpGet(const aURL: string): string;
// uses  System.Net.HttpClient, System.Net.HttpClientComponent, System.Net.URLClient;
var
  Resp: TStringStream;
  Return: IHTTPResponse;
begin
  Result := '';
  with TNetHTTPClient.Create(nil) do
  begin
    Resp := TStringStream.Create('', TEncoding.ANSI);
    Return := Get( { TURI.URLEncode } (aURL), Resp);
    Result := Resp.DataString;
    Resp.Free;
    Free;
  end;
end;

Function Get_session_token : string;
    var
      IdHTTP: TIdHTTP;
      Answer: string;
      JSON : TJSONObject;
begin
  try

    try
      IdHTTP := TIdHTTP.Create(nil);
      try
        IdHTTP.Request.Connection := 'Keep-Alive';

        Idhttp.HTTPOptions := [hoKeepOrigProtocol,hoForceEncodeParams,hoNoProtocolErrorException,hoWantProtocolErrorContent];
        IdHTTP.Request.ContentType := 'application/json';

        idHttp.Request.BasicAuthentication := true;
        idHttp.Request.Username := GlpiUser;
        idHttp.Request.Password := GlpiPassword;

        IdHTTP.Request.ContentEncoding := 'utf-8';
        IdHTTP.Request.CustomHeaders.Values['Authorization'] :=  'user_token  ' + userToken;
        IdHTTP.Request.CustomHeaders.Values['App-Token'] :=  AppToken;

        Answer := IdHTTP.Get(GlpiRestUrl + '/initSession/');

        JSON := TJSONObject.ParseJSONValue(Answer) as TJSONObject;

        Result := JSON.Get('session_token').JsonValue.Value;

      finally
        IdHTTP.Free;
      end;
    finally

    end;

  except
    on E: Exception do
      ShowMessage('Error: '+E.ToString);
  end;

end;

Function KillSession (sToken: string) : boolean;
    var
      IdHTTP: TIdHTTP;
      Answer: string;

begin
  if sToken = '' then Exit;

  try
    try
      IdHTTP := TIdHTTP.Create(nil);
      try
        IdHTTP.Request.Connection := 'Keep-Alive';
        IdHTTP.Request.ContentType := 'application/json';
        idHttp.Request.BasicAuthentication := true;
        idHttp.Request.Username := GlpiUser;
        idHttp.Request.Password := GlpiPassword;


        IdHTTP.Request.ContentEncoding := 'utf-8';
        IdHTTP.Request.CustomHeaders.Values['Session-Token'] := sToken ;
        IdHTTP.Request.CustomHeaders.Values['App-Token'] :=  AppToken;

        Answer := IdHTTP.Get(GlpiRestUrl + '/killSession/');

        if IdHttp.ResponseCode = 200 then Result := true
                                     else Result := false;

      finally
        IdHTTP.Free;
      end;
    finally

    end;

  except
    on E: Exception do
      ShowMessage('Error: '+E.ToString);
  end;

end;

Procedure getActiveEntities (sToken : string);
  var
      IdHTTP: TIdHTTP;
      Answer: string;
      JSON : TJSONObject;
      code : byte;
begin
  if sToken = '' then Exit;

  try
    try
      IdHTTP := TIdHTTP.Create(nil);
      try
        IdHTTP.Request.Connection := 'Keep-Alive';
        IdHTTP.Request.ContentType := 'application/json';
        idHttp.Request.BasicAuthentication := true;
        idHttp.Request.Username := GlpiUser;
        idHttp.Request.Password := GlpiPassword;


        IdHTTP.Request.ContentEncoding := 'utf-8';
        IdHTTP.Request.CustomHeaders.Values['Session-Token'] := sToken ;
        IdHTTP.Request.CustomHeaders.Values['App-Token'] :=  AppToken;

        Answer := IdHTTP.Get(GlpiRestUrl + '/getActiveEntities/');

        code := IdHttp.ResponseCode;
        if IdHttp.ResponseCode <> 200 then Answer := 'Error';

      finally
        IdHTTP.Free;
      end;
    finally

    end;

  except
    on E: Exception do
      ShowMessage('Error: '+E.ToString);
  end;

End;

function TranslitRus2Lat(const Str: string): string;
const
  cyr: array [1..33] of Char=('?','?','?','?','?','?','?','?','?','?','?','?',
  '?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?','?');
  lat: array [1..33] of String=('a','b','v','g','d','e','jo','zh','z','i','jj','k',
  'l','m','n','o','p','r','s','t','u','f','kh','c','ch','sh','shh',#34,'y',#39,'eh','yu','ya');
var
 MyTxt: string;
  i,j: Integer;
begin
  MyTxt:=Str;
  for i := Length(MyTxt) downto 1 do
    for j := 1 to 33 do begin
      if MyTxt[i]=cyr[j] then
        MyTxt:=copy(MyTxt,1,i-1)+lat[j]+copy(MyTxt,i+1,Length(MyTxt)-i)
      else if MyTxt[i]=AnsiUpperCase(cyr[j]) then
        MyTxt:=copy(MyTxt,1,i-1)+AnsiUpperCase(lat[j])+copy(MyTxt,i+1,Length(MyTxt)-i);
    end;
  Result:=MyTxt;
end;

Function CreateTiket (sToken : string): string;
    var
      IdHTTP: TIdHTTP;
      Answer: string;
      JSON, JSON2, JSON3 : TJSONObject;
      JsonToSend: TMemoryStream;
      jsontext : string;
      doc_id, doc_prefix, doc_file : string;
      MultiData : TIdMultiPartFormDataStream;
      JSONArray : TJSONArray;
      newticket_id : string;
      filenametest : UTF8String;
begin
  try

    try

     IdHTTP := TIdHTTP.Create(nil);
      try
        IdHTTP.Request.Connection := 'Keep-Alive';
        IdHTTP.Request.ContentType := 'multipart/form-data';     // ??? ??? ???????? ??????????
        idHttp.Request.BasicAuthentication := true;
        idHttp.Request.Username := GlpiUser;
        idHttp.Request.Password := GlpiPassword;
        Idhttp.Request.AcceptEncoding := 'gzip, identity;q=0';
        IdHttp.Compressor := TIdCompressorZLib.Create(IdHttp);
        Idhttp.Request.Accept := 'application/json';
        Idhttp.HTTPOptions := [hoKeepOrigProtocol,hoForceEncodeParams,hoNoProtocolErrorException,hoWantProtocolErrorContent];
        IdHTTP.Request.ContentEncoding := 'utf-8';
        //???????? user_token ??????? ?? ???? ?????????? ??????? ???????? ???????????? ????????????????? -> ???????????? -> USERNAME -> ?????????
        IdHTTP.Request.CustomHeaders.Values['Authorization'] :=  'user_token  ' + userToken;
        //"?????????"->"?????"->"API" ? ????? ?????? "???????? ???????", ????????? ?????? ? ?????????? ????? (app_token)
        IdHTTP.Request.CustomHeaders.Values['App-Token'] :=  AppToken;
        //"Session-Token" ???????? ? ???????
        IdHTTP.Request.CustomHeaders.Values['Session-Token'] := sToken ;

       //?????  ????????? ????
        MultiData := TIdMultiPartFormDataStream.Create;
      //  filenametest :=  TranslitRus2Lat('d:\14552090 ????????? ?? ??????? ??_test.docx');


        MultiData.AddFormField('uploadManifest', '{"input": {"name": "' + '???????? ?????? 0000' + '", "_filename" : "[docfilename]", "is_recursive" : true}}', 'utf-8', 'application/json').ContentTransfer := '8bit' ;
        filenametest :=  UTF8Encode('d:\????????? ? ??????????\14552090 ????????? ?? ??????? ??.docx');
        with MultiData.AddFile('filename[0]',UTF8Encode(filenametest),'') do              //????????? ????
          begin
            HeaderCharset := 'utf-8';
            HeaderEncoding := '8';
          end;



       //?????  ????????? ????

        //GlpiRestURL - ???? ? ?????? GLPI. ???????? http://myglpiserver.ru/glpi
        Answer := IdHTTP.Post(GlpiRestURL + '/Document/', MultiData);  // ?????????? ????????

        Form1.memo1.Lines.Append(Answer);

        MultiData.Free;

        //????? ????????? ?????????? ?????
      {  JSON := TJSONObject.ParseJSONValue(Answer) as TJSONObject;

        doc_id := JSON.Get('id').JsonValue.Value;    // ???????? ID ???????????? ?????

        JSON2 := TJSONObject(JSON.Get('upload_result').JsonValue);

        JSONArray := TJSONArray(JSON2.Get(0).JsonValue);

        JSON3 := TJSONObject(JSONArray.Get(0));

        doc_file := JSON3.GetValue('name').Value; // ??? ???????? ?? ?????, ??? ??? ??????? ??????? JSON

        doc_prefix := JSON3.GetValue('prefix').Value; //??? ???????? ?? ?????, ??? ??? ??????? ??????? JSON
        //????? ????????? ?????????? ?????

        if (IdHttp.ResponseCode <> 200) and (IdHttp.ResponseCode <> 201)  then Result := '?????? ??? ???????? ?????? (' + Answer + ')'
                                       else
         begin
             // ????? ?????????? ?????? ?? ???????? ??????
             IdHTTP.Request.ContentType := 'application/json';    // ??? ???????? json
              jsontext := '{"input": {"name": "?????? ????????", "content": "????????","status":"1",' +
                '"requesttypes_id":"8","_users_id_assign":"23","time_to_resolve":"2020-06-13 18:00:00",'+   }
           //     '"itilcategories_id":"23","urgency":"3","priority":"3"}}';
            {  JsonToSend := TStringStream.Create(jsontext, TEncoding.UTF8);

              Answer := IdHTTP.Post(GlpiRestURL + '/Ticket', JsonToSend);

              JSON := TJSONObject.ParseJSONValue(Answer) as TJSONObject;

              newticket_id := JSON.Get('id').JsonValue.Value;    //????????? ID ????????? ??????
              //????? ?????????? ?????? ?? ???????? ??????
            }
              // ????? ?????????? ?????? ?? ???????????? ????? ? ??????
           //   jsontext := '{"input": {"documents_id" : "' + doc_id + '", "items_id" : "' + newticket_id + '", "itemtype" : "Ticket" }}';
           //   JsonToSend := TStringStream.Create(jsontext, TEncoding.UTF8);

           //   Answer := IdHTTP.Post(GlpiRestURL + '/Document_Item', JsonToSend);
              //????? ?????????? ?????? ?? ???????????? ????? ? ??????

          //    Result := '?????? ???????'
       //  end;

      finally
        IdHTTP.Free;
      end;
    finally

    end;

  except
    on E: Exception do
      ShowMessage('Error: '+E.ToString);
  end;

end;

procedure TForm1.Button1Click(Sender: TObject);
Begin
 session_token := Get_session_token;
 ShowMessage(CreateTiket(session_token));
 KillSession(session_token);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
getActiveEntities(session_token);

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
// GlpiUser :='HelpdeskAPI';
// GlpiPassword := '2323@qwe';
GlpiUser :='ack';
GlpiPassword := '2323@qwe';

 GlpiRestUrl := 'http://10.0.5.205/glpi/apirest.php';
end;

end.
