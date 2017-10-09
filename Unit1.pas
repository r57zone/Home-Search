unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XMLDoc, XMLIntf, ShellAPI, XPMan, ActiveX,
  IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, ShlObj, Menus, ExtCtrls, ComCtrls;

type
  TMain = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    CreateCategoryBtn: TButton;
    ExtEdit: TEdit;
    AllCB: TCheckBox;
    TextCB: TCheckBox;
    PicsCB: TCheckBox;
    ArchCB: TCheckBox;
    ClearFormatsBtn: TButton;
    IgnorePaths: TMemo;
    AddIgnorePathBtn: TButton;
    XPManifest: TXPManifest;
    IdHTTPServer: TIdHTTPServer;
    SaveDialog: TSaveDialog;
    PopupMenu: TPopupMenu;
    GoToSearchBtn: TMenuItem;
    N2: TMenuItem;
    DataBaseBtn: TMenuItem;
    DataBaseCreateBtn: TMenuItem;
    N6: TMenuItem;
    AboutBtn: TMenuItem;
    ExitBtn: TMenuItem;
    Paths: TMemo;
    AddPathBtn: TButton;
    CancelBtn: TButton;
    StatusBar: TStatusBar;
    OpenPathsBtn: TButton;
    SavePathsBtn: TButton;
    OpenDialog: TOpenDialog;
    OpenIgnorePathsBtn: TButton;
    SaveIgnorePathsBtn: TButton;
    VideoCB: TCheckBox;
    AudioCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure CreateCategoryBtnClick(Sender: TObject);
    procedure IdHTTPServerCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure AddPathBtnClick(Sender: TObject);
    procedure ClearFormatsBtnClick(Sender: TObject);
    procedure AddIgnorePathBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DataBaseCreateBtnClick(Sender: TObject);
    procedure GoToSearchBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure PathsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IgnorePathsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ExtEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure CancelBtnClick(Sender: TObject);
    procedure OpenPathsBtnClick(Sender: TObject);
    procedure SavePathsBtnClick(Sender: TObject);
    procedure OpenIgnorePathsBtnClick(Sender: TObject);
    procedure SaveIgnorePathsBtnClick(Sender: TObject);
  private
    procedure DefaultHandler(var Message); override;
    function GetResults(RequestText, RequestType, RequestExt, RequestCategory: string): string;
    procedure ControlWindow(var Msg: TMessage); message WM_SYSCOMMAND;
    { Private declarations }
  public
    { Public declarations }
  protected
    { Protected declarations }
    procedure IconMouse(var Msg : TMessage); message wm_user+1;
  end;

var
  Main: TMain;
  WM_TaskBarCreated: Cardinal;
  doc: IXMLDocument;
  XMLFile: TStringList;
  AllowIPs, TemplateMain, TemplateResults, TemplateOpen, Template404: TStringList;
  RunOnce: boolean;
  
implementation

{$R *.dfm}

const cuthalf = 100;
var
  buf: array [0..((cuthalf * 2) - 1)] of integer;
 
function min3(a, b, c: integer): integer;
begin
  Result := a;
  if b < Result then Result := b;
  if c < Result then Result := c;
end;

procedure Tray(n:integer); //1 - добавить, 2 - удалить, 3 -  заменить
var
  nim: TNotifyIconData;
begin
  with nim do begin
    cbSize:=SizeOf(nim);
    wnd:=Main.Handle;
    uId:=1;
    uFlags:=nif_icon or nif_message or nif_tip;
    //hIcon:=Application.Icon.Handle;
    hIcon:=Main.Icon.Handle;
    uCallBackMessage:=WM_User + 1;
    StrCopy(szTip, PChar(Application.Title));
  end;
  case n of
    1: Shell_NotifyIcon(nim_add, @nim);
    2: Shell_NotifyIcon(nim_delete, @nim);
    3: Shell_NotifyIcon(nim_modify, @nim);
  end;
end;

procedure TMain.IconMouse(var Msg: TMessage);
begin
  case Msg.lParam of
    WM_LButtonUp: GoToSearchBtn.Click;
    WM_RButtonUp: PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  end;
end;

//Расстояние Левенштейна
function LeveDist(s, t: string): integer;
var i, j, m, n: integer; 
    cost: integer;
    flip: boolean;
begin 
  s := copy(s, 1, cuthalf - 1);
  t := copy(t, 1, cuthalf - 1); 
  m := Length(s);
  n := Length(t);
  if m = 0 then Result := n
  else if n = 0 then Result := m
  else begin
    flip := false;
    for i := 0 to n do buf[i] := i;
    for i := 1 to m do begin
      if flip then buf[0] := i
      else buf[cuthalf] := i;
      for j := 1 to n do begin
        if s[i] = t[j] then cost := 0
        else cost := 1;
        if flip then
          buf[j] := min3((buf[cuthalf + j] + 1),
                         (buf[j - 1] + 1),
                         (buf[cuthalf + j - 1] + cost))
        else
          buf[cuthalf + j] := min3((buf[j] + 1),
                                   (buf[cuthalf + j - 1] + 1),
                                   (buf[j - 1] + cost));
      end;
      flip := not flip;
    end;
    if flip then Result := buf[cuthalf + n]
    else Result := buf[n];
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  //Шаблоны
  TemplateMain:=TStringList.Create;
  TemplateMain.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\index.htm');
  TemplateResults:=TStringList.Create;
  TemplateResults.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\results.htm');
  TemplateOpen:=TStringList.Create;
  TemplateOpen.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\open.htm');
  Template404:=TStringList.Create;
  Template404.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\404.htm');

  //IP для доступа
  AllowIPs:=TStringList.Create;
  AllowIPs.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Allow.txt');

  Application.Title:='Home Search';
  IdHTTPServer.Active:=true;
  WM_TaskBarCreated:=RegisterWindowMessage('TaskbarCreated');
  Tray(1);
  Main.AlphaBlend:=true;
  Main.AlphaBlendValue:=0;
  //SetWindowLong(Application.Handle, GWL_EXSTYLE,GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);  //Скрываем программу с панели задач
end;

//Возможное количество ошибок для слова
function GetErrorCount(name: string): integer;
begin
  Result:=(Length(name) div 4)+1;
end;

function DigitToHex(Digit: Integer): Char;
  begin
    case Digit of
      0..9: Result := Chr(Digit + Ord('0'));
      10..15: Result := Chr(Digit - 10 + Ord('A'));
    else
      Result := '0';
  end;
end;

function URLDecode(const S: string): string;
var
  i, idx, len, n_coded: Integer;
  function WebHexToInt(HexChar: Char): Integer;
    begin
      if HexChar < '0' then
        Result := Ord(HexChar) + 256 - Ord('0')
      else if HexChar <= Chr(Ord('A') - 1) then
        Result := Ord(HexChar) - Ord('0')
      else if HexChar <= Chr(Ord('a') - 1) then
        Result := Ord(HexChar) - Ord('A') + 10
      else
        Result := Ord(HexChar) - Ord('a') + 10;
      end;
begin
  len := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then begin
      n_coded := n_coded + 1;
        if n_coded >= 3 then
          n_coded := 0;
    end else begin
      len := len + 1;
      if S[i] = '%' then
        n_coded := 1;
    end;
  SetLength(Result, len);
  idx := 0;
  n_coded := 0;
  for i := 1 to Length(S) do
    if n_coded >= 1 then begin
      n_coded := n_coded + 1;
      if n_coded >= 3 then begin
        Result[idx] := Chr((WebHexToInt(S[i - 1]) * 16 +
        WebHexToInt(S[i])) mod 256);
        n_coded := 0;
      end;
    end else begin
      idx := idx + 1;
      if S[i] = '%' then
        n_coded := 1;
      if S[i] = '+' then
        Result[idx] := ' '
      else
        Result[idx] := S[i];
    end;
end;

function RevertFixName(str: string): string;
begin
  str:=StringReplace(str, '&amp;', '&', [rfReplaceAll]);
  str:=StringReplace(str, '&lt;', '<', [rfReplaceAll]);
  str:=StringReplace(str, '&gt;', '>', [rfReplaceAll]);
  str:=StringReplace(str, '&quot;', '«»', [rfReplaceAll]);
  Result:=str;
end;

function FixName(str: string): string;
begin
  str:=StringReplace(str, '&', '&amp;', [rfReplaceAll]);
  str:=StringReplace(str, '<', '&lt;', [rfReplaceAll]);
  str:=StringReplace(str, '>', '&gt;', [rfReplaceAll]);
  str:=StringReplace(str, '«»', '&quot;', [rfReplaceAll]);
  Result:=str;
end;

function FixNameURI(str: string): string;
begin
  str:=StringReplace(str, '\', '\\', [rfReplaceAll]);
  str:=StringReplace(str, '&', '*AMP', [rfReplaceAll]);
  str:=StringReplace(str, '''', '*APOS', [rfReplaceAll]);  //апостроф заменяется на спец. фразу *APOS
  Result:=str;
end;

//Проверка на UTF8
function IsUTF8Encoded(const s: AnsiString): boolean;
begin
  Result:=(s <> '') and (UTF8Decode(s) <> '')
end;

function RevertFixNameURI(str: string): string;
begin
  str:=URLDecode(str);
  str:=StringReplace(str, '*APOS', '''', [rfReplaceAll]);  //апостроф заменяется на спец. фразу *APOS
  str:=StringReplace(str, '\\', '\',[rfReplaceAll]);
  str:=StringReplace(str, '*AMP', '&',[rfReplaceAll]);
  if UTF8Decode(str) <> '' then str:=UTF8ToAnsi(str);
  Result:=str;
end;

function TMain.GetResults(RequestText, RequestType, RequestExt, RequestCategory: string): string;
var
  ResponseNode: IXMLNode; i, j, n, ResultRank, TickTime, PagesCount: integer; Doc: IXMLDocument;
  Filters: string;
  CheckList, SearchList, Results: TStringList;
  ResultsA: array of Packed Record
    Name: string;
    Path: string;
    Rank: integer;
  end;
  ResultsC: integer;
  TempRank: integer;
  TempName, TempPath: string;
const
  MinCountWord = 2;
  ResultsPageCount = 12;  //Кол-во результатов на страницу
begin
  CheckList:=TStringList.Create;
  SearchList:=TStringList.Create;
  Results:=TStringList.Create;
  SearchList.Text:=StringReplace(RequestText, ' ', #13#10, [rfReplaceAll]);

  //Категория
  if RequestCategory <> '' then begin
    if FileExists(ExtractFilePath(ParamStr(0)) + RequestCategory + '.xml') then
      RequestCategory:=RequestCategory + '.xml';
  end else RequestCategory:='default.xml';

  doc:=LoadXMLDocument(ExtractFilePath(ParamStr(0)) + RequestCategory);

  TickTime:=GetTickCount; //Затраченное время

  ResponseNode:=doc.DocumentElement.childnodes.Findnode('files');

  //Фильтры по умолчанию
  filters:='txt html htm';

  //Если заданы типы расширений
  if RequestExt<>'' then begin
    Filters:=StringReplace(RequestExt, ';', ' ', [rfReplaceAll]);
    Filters:=StringReplace(Filters, '+', ' ', [rfReplaceAll]);
    Filters:=StringReplace(Filters, ',', ' ', [rfReplaceAll]);
  end;

  if RequestType='all' then Filters:='';
  if RequestType='text' then Filters:='txt html htm doc rtf';
  if RequestType='pics' then Filters:='jpg jpeg bmp png apng gif';
  if RequestType='video' then Filters:='mp4 3gp flv mpeg avi mkv mov';
  if RequestType='audio' then Filters:='mp3 wav aac flac ogg';
  if RequestType='arch' then Filters:='7z zip rar';

  ResultsC:=0;

  for i:=0 to Responsenode.ChildNodes.Count - 1 do begin

    ResultRank:=0;

    if (Filters <> '') and (Pos(ResponseNode.ChildNodes[i].Attributes['ext'], Filters) = 0) then Continue;

    //Преобразование названия в список (разбор поискового текста на строки)
    CheckList.Text:=ResponseNode.ChildNodes[i].NodeValue;
    CheckList.Text:=StringReplace(CheckList.Text, '&amp;', ' ', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, '&lt;', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, '&gt;', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, '&quot;', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, '-', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, ' ', #13#10, [rfReplaceAll]);

    //Проверка на полное совпадение
    if AnsiLowerCase(RequestText) = AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue) then
      ResultRank:=ResultRank + 9;

    //Проверка на частичное вхождение
    if Pos(AnsiLowerCase(RequestText), AnsiLowerCase(CheckList.Text)) > 0 then
      ResultRank:=ResultRank + 3;
    if Pos(AnsiLowerCase(CheckList.Text), AnsiLowerCase(RequestText)) > 0 then
      ResultRank:=ResultRank + 3;

    //Проверка на совпадение c ошибками
    if LeveDist(AnsiLowerCase(requestText), AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue)) < GetErrorCount(RequestText) then
      ResultRank:=ResultRank + 7;

    for j:=0 to CheckList.Count - 1 do
      for n:=0 to SearchList.Count - 1 do
        if (Length(SearchList.Strings[n]) > MinCountWord) and (Length(CheckList.Strings[j]) > MinCountWord) then begin

          //Проверка на прямое вхождение
          if AnsiLowerCase(SearchList.Strings[n])=AnsiLowerCase(CheckList.Strings[j]) then
            resultRank:=resultRank + 7;

          //Проверка на частичное вхождение
          if Pos(AnsiLowerCase(SearchList.Strings[n]), AnsiLowerCase(CheckList.Strings[j])) > 0 then
            resultRank:=resultRank + 5;

          //Проверка на вхождение с ошибками (расстояние Левинштейна)
          if LeveDist(AnsiLowerCase(SearchList.Strings[n]), AnsiLowerCase(CheckList.Strings[j])) < GetErrorCount(SearchList.Strings[n]) then
            ResultRank:=ResultRank + 3;
          end;

    //Проверка на вхождение склеенных слов запроса
    for j:=0 to SearchList.Count - 2 do
      for n:=0 to CheckList.Count - 1 do begin
        //Проверка на прямое вхождение склеенных слов запроса
        if Pos(AnsiLowerCase(SearchList.Strings[j]+SearchList.Strings[j+1]), AnsiLowerCase(CheckList.Strings[n])) > 0 then
          resultRank:=resultRank + 3;
         //Проверка на вхождение с ошибками (расстояние Левинштейна) склеенных слов запроса
        if LeveDist(AnsiLowerCase(SearchList.Strings[j]+SearchList.Strings[j+1]), AnsiLowerCase(CheckList.Strings[n])) < GetErrorCount(SearchList.Strings[j]+SearchList.Strings[j+1]) then
          ResultRank:=ResultRank + 2;

      end;

    //Преобразования пути в список папок
    CheckList.Text:=Copy(Copy(ResponseNode.ChildNodes[i].Attributes['path'], Length(ExtractFileDrive(ResponseNode.ChildNodes[i].Attributes['path']))+1, Length(ResponseNode.ChildNodes[i].Attributes['path'])), 2, Length(ResponseNode.ChildNodes[i].Attributes['path'])-Length(ResponseNode.ChildNodes[i].NodeValue+'.'+ResponseNode.ChildNodes[i].Attributes['ext'])-3);

    //Проверка прямое вхождение запроса на папку
    if Pos(AnsiLowerCase(RequestText), AnsiLowerCase(CheckList.Text)) > 0 then
      ResultRank:=ResultRank + 3;
    if Pos(AnsiLowerCase(CheckList.Text), AnsiLowerCase(RequestText)) > 0 then
      ResultRank:=ResultRank + 3;

    //Разделение папок на строки
    CheckList.Text:=StringReplace(checkList.Text, '\', #13#10, [rfReplaceAll]);


      for j:=0 to CheckList.Count - 1 do
        for n:=0 to SearchList.Count - 1 do

          if (Length(SearchList.Strings[n]) > MinCountWord) and (Length(CheckList.Strings[j]) > MinCountWord) then begin

            //Проверка на название папок без ошибок
            if AnsiLowerCase(searchList.Strings[n])=AnsiLowerCase(checkList.Strings[j]) then
              ResultRank:=ResultRank + 2 else

            //Проверка на название папок с ошибками (расстояние Левинштейна)
            if (LeveDist(AnsiLowerCase(SearchList.Strings[n]), AnsiLowerCase(CheckList.Strings[j])) < GetErrorCount(SearchList.Strings[n])) then
              ResultRank:=ResultRank + 1;

          end; //Конец проверки на совпадения папок


    if ResultRank > 0 then begin

      //Заполнение массива для сортировки по ResultRank
      Inc(ResultsC);
      SetLength(ResultsA, ResultsC);
      ResultsA[ResultsC-1].Name:=Responsenode.ChildNodes[i].NodeValue;
      ResultsA[ResultsC-1].Path:=ResponseNode.ChildNodes[i].Attributes['path'];
      ResultsA[ResultsC-1].Rank:=ResultRank;

    end; //Конец проверки на ResultRank

  end; //Конец проверки XML

  //Сортировка результатов по ResultRank
  for i:=0 to Length(ResultsA) - 1 do
    for j:=0 to Length(ResultsA) - 1 do
      if ResultsA[i].Rank > ResultsA[j].Rank then begin
        TempName:=ResultsA[i].Name;
        TempPath:=ResultsA[i].Path;
        TempRank:=ResultsA[i].Rank;
        ResultsA[i].Name:=ResultsA[j].Name;
        ResultsA[i].Path:=ResultsA[j].Path;
        ResultsA[i].Rank:=ResultsA[j].Rank;
        ResultsA[j].Name:=TempName;
        ResultsA[j].Path:=TempPath;
        ResultsA[j].Rank:=TempRank;
      end;

    if ResultsC > 0 then
      Results.Add(#9 + '<span style="display:block; color:gray; padding-bottom:12px;">Результатов: '+IntToStr(ResultsC)+' ('+FloatToStr((GetTickCount - TickTime)/1000)+' сек.)</span>' + #13#10)
    else
      Results.Add(#9 + '<p>По Вашему запросу <b>'+RequestText+'</b> не найдено соответствующих файлов.</p>' + #13#10);


    //Вывод результатов
    PagesCount:=1;
    Results.Add(#9 + '<div id="page1" style="display:block;">' + #13#10);
    for i:=0 to Length(ResultsA) - 1 do begin
      if (i + 1) mod ResultsPageCount = 0 then begin
        Inc(PagesCount);
        Results.Add('</div>' + #13#10#13#10 + '<div id="page' + IntToStr(PagesCount) + '" style="display:none;">');
      end;
      Results.Add(#9#9 + '<div id="item">' + #13#10 +
      #9#9#9 + '<span id="title" onclick="Request(''' + '/?OpenFile=' + FixNameURI(ResultsA[i].path) + ''', this);">' + ResultsA[i].name + ExtractFileExt(ResultsA[i].Path) + '</span>' + #13#10 +
      #9#9#9 + '<!--RageRank ' + IntToStr(ResultsA[i].rank) + '-->' + #13#10 +
      #9#9#9 + '<div id="link" style="color:green;">' + ResultsA[i].path + '</div>' + #13#10 +
      //'<div id="description">Пусто</div>' + #13#10 +
      #9#9#9 + '<span id="open-folder" onclick="Request(''' + '/?OpenFolder=' + FixNameURI(ResultsA[i].path) + ''', this);">Открыть папку</span>' + #13#10 +
      #9#9 + '</div>' + #13#10);
    end;
      Results.Add(#9 + '</div>' + #13#10);

  //Вывод страничной навигации
  if PagesCount > 1 then begin
    Results.Add(#13#10 + '<div id="pages">Страницы: ');
    Results.Text:=Results.Text + '<span id="nav1" class="active" onclick="ShowResults(1);">1</span>';
    for i:=2 to PagesCount do
       Results.Text:=Results.Text + '<span id="nav' + IntToStr(i) + '" onclick="ShowResults(' + IntToStr(i) + ');">' + IntToStr(i) + '</span>';
    Results.Add(#13#10 + '</div>');
  end;

  Result:=Results.Text;
  Results.Free;
  SearchList.Free;
  CheckList.Free;
end;

procedure ScanDir(Dir: string);
var
  SR: TSearchRec; i: integer;
begin
  Main.StatusBar.SimpleText:=' Идет сканирование папки ' + Dir;

  if Dir[Length(Dir)] <> '\' then Dir:=Dir + '\';

  //Игнорируемые папки
  if (Trim(Main.IgnorePaths.Text) <> '') then
    for i:=0 to Main.IgnorePaths.Lines.Count - 1 do
      if Trim(Main.IgnorePaths.Lines.Strings[i]) <> '' then
        if Main.IgnorePaths.Lines.Strings[i] + '\' = Dir then Exit;

  //Поиск файлов
  if FindFirst(Dir + '*.*', faAnyFile, SR) = 0 then begin
    repeat
      Application.ProcessMessages;
      if (SR.name <> '.') and (SR.name <> '..') then
        if (SR.Attr and faDirectory) <> faDirectory then begin
          if (Pos(AnsiLowerCase(Copy(ExtractFileExt(Dir + SR.name), 2, Length(ExtractFileExt(Dir + SR.name)))), AnsiLowerCase(Main.ExtEdit.Text)) > 0) or (Main.ExtEdit.Text = '') then
            XMLFile.Add('   <file ext="' + AnsiLowerCase(Copy(ExtractFileExt(SR.Name), 2, Length(ExtractFileExt(SR.Name)))) + '" path="'+ FixName(Dir + SR.name) + '">'+ FixName(Copy(SR.Name, 1, Length(SR.Name) - Length(ExtractFileExt(SR.Name)))) + '</file>');
        end else ScanDir(Dir + SR.name + '\');
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
end;

procedure TMain.CreateCategoryBtnClick(Sender: TObject);
var
  i: integer;
begin
  SaveDialog.Filter:='Базы данных|*.xml';
  SaveDialog.DefaultExt:=SaveDialog.Filter;

  if SaveDialog.Execute then begin

    //Отключение кнопок
    Paths.Enabled:=false;
    AddPathBtn.Enabled:=false;
    OpenPathsBtn.Enabled:=false;
    SavePathsBtn.Enabled:=false;

    ExtEdit.Enabled:=false;
    ClearFormatsBtn.Enabled:=false;

    AllCB.Enabled:=false;
    TextCB.Enabled:=false;
    PicsCB.Enabled:=false;
    ArchCB.Enabled:=false;

    IgnorePaths.Enabled:=false;
    AddIgnorePathBtn.Enabled:=false;
    OpenIgnorePathsBtn.Enabled:=false;
    SaveIgnorePathsBtn.Enabled:=false;

    CreateCategoryBtn.Enabled:=false;
    CancelBtn.Enabled:=false;

    if TextCB.Checked then
      if Pos('txt htm html', ExtEdit.Text) = 0 then ExtEdit.Text:=ExtEdit.Text+' txt html htm doc rtf';
    if PicsCB.Checked then
      if Pos('jpg jpeg bmp png apng gif', ExtEdit.Text) = 0 then ExtEdit.Text:=ExtEdit.Text+' jpg jpeg bmp png apng gif';
    if VideoCB.Checked then
      if Pos('mp4 3gp flv mpeg avi mkv mov', ExtEdit.Text) = 0 then ExtEdit.Text:=ExtEdit.Text+' mp4 3gp flv mpeg avi mkv mov';
    if AudioCB.Checked then
      if Pos('mp3 wav aac flac ogg', ExtEdit.Text) = 0 then ExtEdit.Text:=ExtEdit.Text+' mp3 wav aac flac ogg';
    if ArchCB.Checked then
      if Pos('7z zip rar', ExtEdit.Text) = 0 then ExtEdit.Text:=ExtEdit.Text+' 7z zip rar';
    if ExtEdit.Text[1] = ' ' then ExtEdit.Text:=Copy(ExtEdit.Text, 2, Length(ExtEdit.Text));


    if AllCB.Checked then ExtEdit.Text:='';

    XMLFile:=TStringList.Create;
    XMLFile.Add('<?xml version="1.0" encoding="windows-1251" ?>'+#13#10+'<tree>'+#13#10+' <files>');
    for i:=0 to Paths.Lines.Count-1 do
      if Trim(Paths.Lines.Strings[i]) <> '' then ScanDir(Paths.Lines.Strings[i]);
    XMLFile.Add(' </files>'+#13#10+'</tree>');
    if FileExists(SaveDialog.FileName) then DeleteFile(SaveDialog.FileName);
    XMLFile.SaveToFile(SaveDialog.FileName);
    XMLFile.Free;
    ShowMessage('Готово');
    StatusBar.SimpleText:='';

    //Включение кнопок
    Paths.Enabled:=true;
    AddPathBtn.Enabled:=true;
    OpenPathsBtn.Enabled:=true;
    SavePathsBtn.Enabled:=true;

    ExtEdit.Enabled:=true;
    ClearFormatsBtn.Enabled:=true;

    AllCB.Enabled:=true;
    TextCB.Enabled:=true;
    PicsCB.Enabled:=true;
    ArchCB.Enabled:=true;

    IgnorePaths.Enabled:=true;
    AddIgnorePathBtn.Enabled:=true;
    OpenIgnorePathsBtn.Enabled:=true;
    SaveIgnorePathsBtn.Enabled:=true;

    CreateCategoryBtn.Enabled:=true;
    CancelBtn.Enabled:=true;
  end;
end;

procedure TMain.IdHTTPServerCommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  RequestText, RequestType, RequestExt, RequestCategory, TempRequestDocument, TempFilePath, TempDirPath: string; i: integer;
begin
  if (AllowIPs.Count > 0) and (Trim(AnsiUpperCase(AllowIPs.Strings[0]))<>'ALL') then
    if Pos(AThread.Connection.Socket.Binding.PeerIP, AllowIPs.Text)=0 then Exit;

  CoInitialize(nil);

  if (ARequestInfo.Document = '') or (ARequestInfo.Document = '/') and (ARequestInfo.Params.Text = '') then
    AResponseInfo.ContentText:=TemplateMain.Text
  else begin
    TempRequestDocument:=StringReplace(ARequestInfo.Document, '/', '\', [rfReplaceAll]);
    TempRequestDocument:=StringReplace(TempRequestDocument, '\\', '\', [rfReplaceAll]);
    if TempRequestDocument[1]='\' then Delete(TempRequestDocument, 1, 1);

    if FileExists(ExtractFilePath(ParamStr(0)) + TempRequestDocument) then begin
      AResponseInfo.ContentType:=IdHTTPServer.MIMETable.GetDefaultFileExt(ExtractFilePath(ParamStr(0)) + TempRequestDocument);
      IdHTTPServer.ServeFile(AThread, AResponseinfo, ExtractFilePath(ParamStr(0)) + TempRequestDocument);
    end;
  end;


  if ARequestInfo.Params.Count > 0 then begin

    //Открытие файлов по запросу
    if Copy(ARequestInfo.Params.Text, 1, 9)='OpenFile=' then begin
      AResponseInfo.ContentText:=TemplateOpen.Text;
      TempFilePath:=RevertFixNameURI(Copy(ARequestInfo.Params.Strings[0], 10, Length(ARequestInfo.Params.Strings[0])));
      if FileExists(TempFilePath) then begin
        ShellExecute(0, 'open', PChar(TempFilePath), nil, nil, SW_SHOW);
        AResponseInfo.ContentText:=TemplateOpen.Text;
      end else AResponseInfo.ContentText:=StringReplace(Template404.Text, '[%FILE%]', AnsiToUTF8(TempFilePath), [rfIgnoreCase]);
    end;

    //Открытие папок по запросу
    if Copy(ARequestInfo.Params.Text, 1, 11)='OpenFolder=' then begin
      TempFilePath:=RevertFixNameURI(Copy(ARequestInfo.Params.Strings[0], 12, Length(ARequestInfo.Params.Strings[0])));
      if FileExists(TempFilePath) then begin
        ShellExecute(0, 'open', 'explorer', PChar('/select, '+ TempFilePath), nil, SW_SHOW);
        AResponseInfo.ContentText:=TemplateOpen.Text;
      end else begin
        TempDirPath:=Copy(TempFilePath, 1, Pos(ExtractFileName(TempFilePath), TempFilePath)-1);
        if DirectoryExists(TempDirPath) then ShellExecute(0, 'open', PChar(TempDirPath), nil, nil, SW_SHOW)
        else AResponseInfo.ContentText:=StringReplace(Template404.Text, '[%FILE%]', AnsiToUTF8(TempDirPath), [rfIgnoreCase]);
      end;
    end;


    if Copy(ARequestInfo.Params.Text, 1, 2)='q=' then begin
    
      RequestText:=Copy(ARequestInfo.Params.Strings[0], 3, Length(ARequestInfo.Params.Strings[0]));

      //Поиск команды type (тип данных)
      if Pos(' type:', AnsiLowerCase(RequestText)) > 0 then
        for i:=Pos(' type:', AnsiLowerCase(RequestText)) + 6 to Length(RequestText) do begin
          if RequestText[i]=' ' then break;
          RequestType:=RequestType+AnsiLowerCase(RequestText[i]);
        end;

      //Поиск команды ext (расширение)
      if Pos(AnsiLowerCase(' ext:'), AnsiLowerCase(RequestText)) > 0 then
        for i:=Pos(' ext:', AnsiLowerCase(RequestText)) + 5 to Length(RequestText) do begin
          if RequestText[i]=' ' then break;
          RequestExt:=RequestExt+AnsiLowerCase(RequestText[i]);
        end;

      //Поиск команды ext (расширение)
      if Pos(AnsiLowerCase(' cat:'), AnsiLowerCase(RequestText)) > 0 then
        for i:=Pos(' cat:', AnsiLowerCase(RequestText)) + 5 to Length(RequestText) do begin
          if RequestText[i]=' ' then break;
          RequestCategory:=RequestCategory+AnsiLowerCase(RequestText[i]);
        end;

      //Удаление из запроса команд
      if Pos(' type:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' type:', AnsiLowerCase(RequestText))-1);
      if Pos(' ext:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' ext:', AnsiLowerCase(RequestText))-1);
      if Pos(' cat:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' cat:', AnsiLowerCase(RequestText))-1);

        AResponseInfo.ContentText:=StringReplace( StringReplace(TemplateResults.Text, '[%NAME%]', Copy(ARequestInfo.Params.Strings[0], 3, Length(ARequestInfo.Params.Strings[0])), [rfReplaceAll]),
      '[%RESULTS%]', GetResults(RequestText, RequestType, RequestExt, RequestCategory), [rfIgnoreCase]);
    end;

  end;

  RequestType:='';
  RequestExt:='';
  RequestCategory:='';
  CoUninitialize;
end;

function BrowseFolderDialog(title: PChar): string;
var
  TitleName: string;
  lpItemid: pItemIdList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..max_Path] of char;
  TempPath: array[0..max_Path] of char;
begin
  FillChar(BrowseInfo,SizeOf(tBrowseInfo),#0);
  BrowseInfo.hwndowner:=GetDesktopWindow;
  BrowseInfo.pSzDisplayName:=@DisplayName;
  TitleName:=title;
  BrowseInfo.lpSzTitle:=PChar(TitleName);
  BrowseInfo.ulFlags:=bIf_ReturnOnlyFSDirs;
  lpItemId:=shBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    shGetPathFromIdList(lpItemId, TempPath);
    Result:=TempPath;
    GlobalFreePtr(lpItemId);
  end;
end;

procedure TMain.AddPathBtnClick(Sender: TObject);
begin
  Paths.Lines.Add(BrowseFolderDialog('Выберите папку'));
  if Paths.Lines.Strings[Paths.Lines.Count-1] = '' then Paths.Lines.Delete(Paths.Lines.Count - 1);
end;

procedure TMain.ClearFormatsBtnClick(Sender: TObject);
begin
  ExtEdit.Clear;
end;

procedure TMain.AddIgnorePathBtnClick(Sender: TObject);
begin
  IgnorePaths.Lines.Add(BrowseFolderDialog('Выберите папку'));
  if IgnorePaths.Lines.Strings[IgnorePaths.Lines.Count - 1] = '' then
    IgnorePaths.Lines.Delete(IgnorePaths.Lines.Count - 1);
end;

procedure TMain.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.FormDestroy(Sender: TObject);
begin
  Tray(2);
  IdHTTPServer.Active:=false;
  TemplateMain.Free;
  TemplateResults.Free;
  TemplateOpen.Free;
  Template404.Free;
  AllowIPs.Free;
end;

procedure TMain.DefaultHandler(var Message);
begin
  if TMessage(Message).Msg = WM_TASKBARCREATED then Tray(1);
  inherited;
end;

procedure TMain.DataBaseCreateBtnClick(Sender: TObject);
begin
  ShowWindow(Handle, SW_Normal);
  SetForegroundWindow(Main.Handle);

  Main.Repaint;
end;

procedure TMain.GoToSearchBtnClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, 'http://127.0.0.1:757', nil, nil, SW_SHOW);
end;

procedure TMain.ControlWindow(var Msg: TMessage);
begin
  case Msg.WParam of
    SC_MINIMIZE:
        ShowWindow(Handle, SW_HIDE);
    SC_CLOSE:
        ShowWindow(Handle, SW_HIDE);
    else
      inherited;
  end;
end;

procedure TMain.FormActivate(Sender: TObject);
begin
  if RunOnce = false then begin
    RunOnce:=true;
    Main.AlphaBlend:=false;
    ShowWindow(Handle, SW_HIDE);  //Скрываем программу
    ShowWindow(Application.Handle, SW_HIDE);  //Скрываем программу с панели задач
  end;
end;

procedure TMain.AboutBtnClick(Sender: TObject);
begin
    Application.MessageBox('Home Search 0.4' + #13#10 + 'Последнее обновление: 09.10.2017' + #13#10 + 'http://r57zone.github.io' + #13#10 + 'r57zone@gmail.com', 'О программе...', 0);
end;

procedure TMain.PathsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Main.Repaint;
end;

procedure TMain.IgnorePathsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Main.Repaint;
end;

procedure TMain.ExtEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Main.Repaint;
end;

procedure TMain.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.OpenPathsBtnClick(Sender: TObject);
begin
  OpenDialog.FileName:='';
  if OpenDialog.Execute then
    Paths.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TMain.SavePathsBtnClick(Sender: TObject);
begin
  SaveDialog.FileName:='';
  SaveDialog.Filter:='Файл HomeSearch|*.hsxt';
  SaveDialog.DefaultExt:=SaveDialog.Filter;
  if SaveDialog.Execute then
    Paths.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TMain.OpenIgnorePathsBtnClick(Sender: TObject);
begin
  OpenDialog.FileName:='';
  if OpenDialog.Execute then
    IgnorePaths.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TMain.SaveIgnorePathsBtnClick(Sender: TObject);
begin
  SaveDialog.FileName:='';
  SaveDialog.Filter:='Файл HomeSearch|*.hsxt';
  SaveDialog.DefaultExt:=SaveDialog.Filter;
  if SaveDialog.Execute then
    IgnorePaths.Lines.SaveToFile(SaveDialog.FileName);
end;

end.
