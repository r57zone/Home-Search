unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, XMLDoc, XMLIntf, ShellAPI, XPMan, ActiveX,
  IdBaseComponent, IdComponent, IdTCPServer, IdCustomHTTPServer,
  IdHTTPServer, ShlObj, Menus, ExtCtrls, ComCtrls, IniFiles;

type
  TMain = class(TForm)
    PathSearchLbl: TLabel;
    ExtFilesLbl: TLabel;
    TypeFilesLbl: TLabel;
    IgnorePathLbl: TLabel;
    CreateCatBtn: TButton;
    ExtsEdit: TEdit;
    AllCB: TCheckBox;
    TextCB: TCheckBox;
    PicsCB: TCheckBox;
    ArchCB: TCheckBox;
    ClearExtsBtn: TButton;
    IgnorePaths: TMemo;
    AddIgnorePathBtn: TButton;
    XPManifest: TXPManifest;
    IdHTTPServer: TIdHTTPServer;
    SaveDialog: TSaveDialog;
    PopupMenu: TPopupMenu;
    GoToSearchBtn: TMenuItem;
    Line: TMenuItem;
    DataBaseBtn: TMenuItem;
    DBCreateBtn: TMenuItem;
    Line2: TMenuItem;
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
    DBsOpen: TMenuItem;
    Line3: TMenuItem;
    TagsCB: TCheckBox;
    TagsBtn: TMenuItem;
    TagsCreateBtn: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure CreateCatBtnClick(Sender: TObject);
    procedure IdHTTPServerCommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure AddPathBtnClick(Sender: TObject);
    procedure ClearExtsBtnClick(Sender: TObject);
    procedure AddIgnorePathBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DBCreateBtnClick(Sender: TObject);
    procedure GoToSearchBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure OpenPathsBtnClick(Sender: TObject);
    procedure SavePathsBtnClick(Sender: TObject);
    procedure OpenIgnorePathsBtnClick(Sender: TObject);
    procedure SaveIgnorePathsBtnClick(Sender: TObject);
    procedure DBsOpenClick(Sender: TObject);
    procedure TagsCreateBtnClick(Sender: TObject);
  private
    procedure ScanDir(Dir: string);
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

const
  DataBasesPath = 'dbs';
  PathsExt = 'hsp'; //Расширение для файла со списком папок - Home Search Paths (HSP)
  TagsExt = 'hst'; //Расширение для файла с тегами - Home Search Tags (HST)

var
  Main: TMain;
  WM_TASKBARCREATED: Cardinal;
  doc: IXMLDocument;
  XMLFile: TStringList;
  AllowIPs, TemplateMain, TemplateResults, TemplateOpen, Template404: TStringList;
  RunOnce: boolean;
  TemplateName: string;

  TextExts, PicExts, VideoExts, AudioExts, ArchExts: string;

  MaxPageResults, MaxPages: integer;
  FileTagsList: TStringList;
  
implementation

uses Unit2;

{$R *.dfm}

const cuthalf = 100;
var
  buf: array [0..((cuthalf * 2) - 1)] of integer;
 
function min3(a, b, c: integer): integer;
begin
  Result:=a;
  if b < Result then
    Result:=b;
  if c < Result then
    Result:=c;
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
    WM_LBUTTONDOWN: begin
      //Скрываем PopupMenu
      PostMessage(Handle, WM_LBUTTONDOWN, MK_LBUTTON, 0);
      PostMessage(Handle, WM_LBUTTONUP, MK_LBUTTON, 0);
    end;
    WM_LBUTTONDBLCLK: GoToSearchBtn.Click;
    WM_RBUTTONUP: PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
  end;
end;

//Расстояние Левенштейна
function LevDist(s, t: string): integer;
var i, j, m, n: integer; 
    cost: integer;
    flip: boolean;
begin 
  s:=Copy(s, 1, cuthalf - 1);
  t:=Copy(t, 1, cuthalf - 1);
  m:=Length(s);
  n:=Length(t);
  if m = 0 then
    Result:=n
  else if n = 0 then
    Result:=m
  else begin
    flip := false;
    for i:=0 to n do buf[i] := i;
    for i:=1 to m do begin
      if flip then buf[0]:=i
      else buf[cuthalf]:=i;
      for j:=1 to n do begin
        if s[i] = t[j] then
          cost:=0
        else
          cost:=1;
        if flip then
          buf[j]:=min3((buf[cuthalf + j] + 1),
                         (buf[j - 1] + 1),
                         (buf[cuthalf + j - 1] + cost))
        else
          buf[cuthalf + j]:=min3((buf[j] + 1), (buf[cuthalf + j - 1] + 1), (buf[j - 1] + cost));
      end;
      flip:=not flip;
    end;
    if flip then
      Result:=buf[cuthalf + n]
    else
      Result:=buf[n];
  end;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Setup.ini');
  IdHTTPServer.DefaultPort:=Ini.ReadInteger('Main', 'Port', 757);
  TemplateName:=Ini.ReadString('Main', 'Template', 'default');

  //Результаты
  MaxPageResults:=Ini.ReadInteger('Results', 'MaxPageResults', 12);
  MaxPages:=Ini.ReadInteger('Results', 'MaxPages', 10);

  //Типы данных
  TextExts:=Ini.ReadString('Types', 'TextExts', 'txt html htm pdf rtf chm');
  PicExts:=Ini.ReadString('Types', 'PicExts', 'jpg jpeg bmp png apng gif');
  VideoExts:=Ini.ReadString('Types', 'VideoExts', 'mp4 3gp flv mpeg avi mkv mov');
  AudioExts:=Ini.ReadString('Types', 'AudioExts', 'mp3 wav aac flac ogg');
  ArchExts:=Ini.ReadString('Types', 'ArchExts', '7z zip rar');
  Ini.Free;

  //Шаблоны
  TemplateMain:=TStringList.Create;
  TemplateMain.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\' + TemplateName + '\index.htm');
  TemplateResults:=TStringList.Create;
  TemplateResults.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\' + TemplateName + '\results.htm');
  TemplateOpen:=TStringList.Create;
  TemplateOpen.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\' + TemplateName + '\open.htm');
  Template404:=TStringList.Create;
  Template404.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'templates\' + TemplateName + '\404.htm');

  //IP для доступа
  AllowIPs:=TStringList.Create;
  AllowIPs.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'Allow.txt');

  Application.Title:='Home Search';
  IdHTTPServer.Active:=true;
  WM_TASKBARCREATED:=RegisterWindowMessage('TaskbarCreated');
  Tray(1);
  //Main.AlphaBlend:=true;
  //Main.AlphaBlendValue:=0;
  //SetWindowLong(Application.Handle, GWL_EXSTYLE,GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);  //Скрываем программу с панели задач

  ExtsEdit.Text:=TextExts;
end;

//Возможное количество ошибок для слова
function GetWordErrorCount(Str: string): integer;
begin
  Result:=(Length(Str) div 4) + 1;
end;

function DigitToHex(Digit: Integer): Char;
begin
  case Digit of
      0..9: Result := Chr(Digit + Ord('0'));
      10..15: Result := Chr(Digit - 10 + Ord('A'));
    else
      Result:='0';
  end;
end;

function URLDecode(const S: string): string;
var
  i, idx, len, n_coded: Integer;
  function WebHexToInt(HexChar: Char): Integer;
    begin
      if HexChar < '0' then
        Result:=Ord(HexChar) + 256 - Ord('0')
      else if HexChar <= Chr(Ord('A') - 1) then
        Result:=Ord(HexChar) - Ord('0')
      else if HexChar <= Chr(Ord('a') - 1) then
        Result:=Ord(HexChar) - Ord('A') + 10
      else
        Result:=Ord(HexChar) - Ord('a') + 10;
      end;
begin
  len:=0;
  n_coded:=0;
  for i:=1 to Length(S) do
    if n_coded >= 1 then begin
      n_coded:=n_coded + 1;
        if n_coded >= 3 then
          n_coded:=0;
    end else begin
      len:=len + 1;
      if S[i] = '%' then
        n_coded:=1;
    end;
  SetLength(Result, len);
  idx:=0;
  n_coded:=0;
  for i:=1 to Length(S) do
    if n_coded >= 1 then begin
      n_coded:=n_coded + 1;
      if n_coded >= 3 then begin
        Result[idx]:=Chr((WebHexToInt(S[i - 1]) * 16 +
        WebHexToInt(S[i])) mod 256);
        n_coded:=0;
      end;
    end else begin
      idx:=idx + 1;
      if S[i] = '%' then
        n_coded:=1;
      if S[i] = '+' then
        Result[idx]:=' '
      else
        Result[idx]:=S[i];
    end;
end;

function FixName(Str: string): string;
begin
  Str:=StringReplace(Str, '&', '&amp;', [rfReplaceAll]);
  //Str:=StringReplace(Str, '<', '&lt;', [rfReplaceAll]);
  //Str:=StringReplace(Str, '>', '&gt;', [rfReplaceAll]);
  //Str:=StringReplace(Str, '"', '&quot;', [rfReplaceAll]);
  //Str:=StringReplace(Str, '«', '&laquo;', [rfReplaceAll]);
  //Str:=StringReplace(Str, '»', '&raquo;', [rfReplaceAll]);
  Result:=Str;
end;

function RevertFixName(Str: string): string;
begin
  Str:=StringReplace(Str, '&amp;', '&', [rfReplaceAll]);
  //Str:=StringReplace(Str, '&lt;', '<', [rfReplaceAll]);
  //Str:=StringReplace(Str, '&gt;', '>', [rfReplaceAll]);
  //Str:=StringReplace(Str, '&quot;', '"', [rfReplaceAll]);
  //Str:=StringReplace(Str, '&laquo;', '«', [rfReplaceAll]);
  //Str:=StringReplace(Str, '&raquo;', '»', [rfReplaceAll]);
  Result:=Str;
end;

function FixNameURI(Str: string): string;
begin
  Str:=StringReplace(Str, '\', '\\', [rfReplaceAll]);
  Str:=StringReplace(Str, '&', '*AMP', [rfReplaceAll]);
  Str:=StringReplace(Str, '''', '*APOS', [rfReplaceAll]);  //апостроф заменяется на спец. слово *APOS
  Result:=Str;
end;

//Проверка на UTF8
function IsUTF8Encoded(Str: string): boolean;
begin
  Result:=(Str <> '') and (UTF8Decode(Str) <> '')
end;

function RevertFixNameURI(Str: string): string;
begin
  Str:=URLDecode(Str);
  Str:=StringReplace(Str, '*APOS', '''', [rfReplaceAll]);  //апостроф заменяется на спец. слово *APOS
  Str:=StringReplace(Str, '\\', '\',[rfReplaceAll]);
  Str:=StringReplace(Str, '*AMP', '&',[rfReplaceAll]);
  if UTF8Decode(Str) <> '' then
    Str:=UTF8ToAnsi(Str);
  Result:=Str;
end;

function TMain.GetResults(RequestText, RequestType, RequestExt, RequestCategory: string): string;
var
  ResponseNode: IXMLNode; i, j, n, ResultRank, TickTime, PagesCount: integer; Doc: IXMLDocument;
  Filters: string;
  SearchList, CheckList, TagsList, Results: TStringList;
  ResultsA: array of Packed Record
    Name: string;
    Path: string;
    Rank: integer;
  end;
  ResultsC: integer;
  TempRank: integer;
  TempName, TempPath: string;
const
  MinCountChars = 2;
begin
  SearchList:=TStringList.Create;
  CheckList:=TStringList.Create;
  TagsList:=TStringList.Create;
  Results:=TStringList.Create;

  RequestText:=AnsiLowerCase(RequestText);
  SearchList.Text:=StringReplace(RequestText, ' ', #13#10, [rfReplaceAll]);

  //Категория
  if (RequestCategory <> '') and (FileExists(ExtractFilePath(ParamStr(0)) + DataBasesPath + '\' + RequestCategory + '.xml')) then
    RequestCategory:=RequestCategory + '.xml'
  else
    RequestCategory:='default.xml';

  Doc:=LoadXMLDocument(ExtractFilePath(ParamStr(0)) + DataBasesPath + '\' + RequestCategory);

  TickTime:=GetTickCount; //Затраченное время

  ResponseNode:=Doc.DocumentElement.childnodes.Findnode('files');

  //Фильтры по умолчанию
  Filters:=TextExts;

  //Если заданы типы расширений
  if RequestExt <> '' then begin
    Filters:=StringReplace(RequestExt, ';', ' ', [rfReplaceAll]);
    Filters:=StringReplace(Filters, '+', ' ', [rfReplaceAll]);
    Filters:=StringReplace(Filters, ',', ' ', [rfReplaceAll]);
  end;

  if RequestType = 'all' then Filters:='';
  if RequestType = 'text' then Filters:=TextExts;
  if RequestType = 'pics' then Filters:=PicExts;
  if RequestType = 'video' then Filters:=VideoExts;
  if RequestType = 'audio' then Filters:=AudioExts;
  if RequestType = 'arch' then Filters:=ArchExts;

  ResultsC:=0;

  for i:=0 to Responsenode.ChildNodes.Count - 1 do begin

    ResultRank:=0;

    //Пропускаем если расширение не совпадает, кроме поиска по всем файлам
    if ((RequestType <> 'all') and (Pos(ResponseNode.ChildNodes[i].Attributes['ext'], Filters) = 0)) then Continue;

    //Преобразование названия в список (разбор поискового текста на строки)
    CheckList.Text:=AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue);
    CheckList.Text:=StringReplace(CheckList.Text, '&amp;', ' ', [rfReplaceAll]);
    //CheckList.Text:=StringReplace(CheckList.Text, '&lt;', '', [rfReplaceAll]);
    //CheckList.Text:=StringReplace(CheckList.Text, '&gt;', '', [rfReplaceAll]);
    //CheckList.Text:=StringReplace(CheckList.Text, '&quot;', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, '-', '', [rfReplaceAll]);
    CheckList.Text:=StringReplace(CheckList.Text, ' ', #13#10, [rfReplaceAll]);

    //Преобразование тегов в список
    TagsList.Text:=ResponseNode.ChildNodes[i].Attributes['tags']; //Теги в базе уже LowerCase
    TagsList.Text:=StringReplace(TagsList.Text, ',', #13#10, [rfReplaceAll]);

    //Проверка на полное совпадение включая расширение
    if RequestText = AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue + '.' + ResponseNode.ChildNodes[i].Attributes['ext']) then
      ResultRank:=ResultRank + 12;

    //Проверка на полное совпадение без расширения
    if RequestText = AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue) then
      ResultRank:=ResultRank + 9;

    //Проверка на частичное вхождение
    if Pos(RequestText, CheckList.Text) > 0 then
      ResultRank:=ResultRank + 3;

    if Pos(CheckList.Text, RequestText) > 0 then
      ResultRank:=ResultRank + 3;

    //Проверка на совпадение c ошибками
    if LevDist(RequestText, AnsiLowerCase(ResponseNode.ChildNodes[i].NodeValue)) < GetWordErrorCount(RequestText) then
      ResultRank:=ResultRank + 7;

    //Проверка на отдельных слова
    for j:=0 to CheckList.Count - 1 do
      for n:=0 to SearchList.Count - 1 do begin
        if (Length(SearchList.Strings[n]) > MinCountChars) and (Length(CheckList.Strings[j]) > MinCountChars) then begin

          //Проверка на прямое вхождение
          if SearchList.Strings[n] = CheckList.Strings[j] then
            ResultRank:=ResultRank + 7

          //Проверка на вхождение с ошибками (расстояние Левинштейна)
          else if LevDist(SearchList.Strings[n], CheckList.Strings[j]) < GetWordErrorCount(SearchList.Strings[n]) then
            ResultRank:=ResultRank + 5

          //Проверка на частичное вхождение
          else if Pos(SearchList.Strings[n], CheckList.Strings[j]) > 0 then
            ResultRank:=ResultRank + 3;
        end;

        //Проверка на прямое совпадение расширения с запросом (Запрос + " " + расширение)
        if SearchList.Strings[n] = ResponseNode.ChildNodes[i].Attributes['ext'] then //Расширения в базе уже LowerCase
          ResultRank:=ResultRank + 1;
      end;

    //Проверки на теги
    if TagsList.Text <> '' then
      for j:=0 to TagsList.Count - 1 do begin
        for n:=0 to SearchList.Count - 1 do
          if (Length(SearchList.Strings[n]) > MinCountChars) and (Length(TagsList.Strings[j]) > MinCountChars) then begin

            //Проверка на прямое вхождение
            if SearchList.Strings[n] = TagsList.Strings[j] then
              ResultRank:=ResultRank + 7

            //Проверка на вхождение с ошибками (расстояние Левинштейна)
            else if LevDist(SearchList.Strings[n], TagsList.Strings[j]) < GetWordErrorCount(SearchList.Strings[n]) then
              ResultRank:=ResultRank + 4;
          end;

          //Проверка на прямое совпадение тега и запроса
          if RequestText = TagsList.Strings[j] then
            ResultRank:=ResultRank + 8

          //Проверка на совпадение с ошибками
          else if LevDist(RequestText, TagsList.Strings[j]) < GetWordErrorCount(RequestText) then
            ResultRank:=ResultRank + 5;
        end;

    //Проверка на вхождение рядом стоящих склеенных слов запроса
    for j:=0 to SearchList.Count - 2 do
      for n:=0 to CheckList.Count - 1 do begin

        //Проверка на прямое вхождение склеенных слов запроса
        if Pos(SearchList.Strings[j] + SearchList.Strings[j + 1], CheckList.Strings[n]) > 0 then
          ResultRank:=ResultRank + 3

         //Проверка на вхождение рядом стоящих склеенных слов запроса с ошибками (расстояние Левинштейна)
        else if LevDist(SearchList.Strings[j] + SearchList.Strings[j + 1], CheckList.Strings[n]) < GetWordErrorCount(SearchList.Strings[j] + SearchList.Strings[j + 1]) then
          ResultRank:=ResultRank + 2;

      end;

    //Преобразование пути в список папок
    CheckList.Text:=Copy(Copy(ResponseNode.ChildNodes[i].Attributes['path'], Length(ExtractFileDrive(ResponseNode.ChildNodes[i].Attributes['path'])) + 1, Length(ResponseNode.ChildNodes[i].Attributes['path'])), 2, Length(ResponseNode.ChildNodes[i].Attributes['path']) - Length(ResponseNode.ChildNodes[i].NodeValue + '.' + ResponseNode.ChildNodes[i].Attributes['ext']) - 3);

    //Проверка на частичное вхождение запроса в название всего пути
    if Pos(RequestText, CheckList.Text) > 0 then
      ResultRank:=ResultRank + 3;

    //Разделение папок на строки
    CheckList.Text:=StringReplace(CheckList.Text, '\', #13#10, [rfReplaceAll]);


      for j:=0 to CheckList.Count - 1 do
        for n:=0 to SearchList.Count - 1 do

          if (Length(SearchList.Strings[n]) > MinCountChars) and (Length(CheckList.Strings[j]) > MinCountChars) then begin

            //Проверка на название папок без ошибок
            if SearchList.Strings[n] = CheckList.Strings[j] then
              ResultRank:=ResultRank + 2

            //Проверка на название папок с ошибками (расстояние Левинштейна)
            else if (LevDist(SearchList.Strings[n], CheckList.Strings[j]) < GetWordErrorCount(SearchList.Strings[n])) then
              ResultRank:=ResultRank + 1;

          end; //Конец проверки на совпадения папок


    //Если найдены совпадения
    if ResultRank > 0 then begin

      //Заполнение массива для сортировки по ResultRank
      Inc(ResultsC);
      SetLength(ResultsA, ResultsC);
      ResultsA[ResultsC - 1].Name:=Responsenode.ChildNodes[i].NodeValue;
      ResultsA[ResultsC - 1].Path:=ResponseNode.ChildNodes[i].Attributes['path'];
      ResultsA[ResultsC - 1].Rank:=ResultRank;

    end;

  end; //Конец проверки XML

  //Сортировка результатов по ResultRank, когда-нибудь заменить на quick sort
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
      Results.Add(#9 + '<span style="display:block; color:gray; padding-bottom:12px;">Результатов: '+ IntToStr(ResultsC) + ' ('+ FloatToStr((GetTickCount - TickTime) / 1000) + ' сек.)</span>' + #13#10)
    else
      Results.Add(#9 + '<p>По Вашему запросу <b>' + RequestText + '</b> не найдено соответствующих файлов.</p>' + #13#10);


    //Вывод результатов
    PagesCount:=1;
    Results.Add(#9 + '<div id="page1" style="display:block;">' + #13#10);
    for i:=0 to Length(ResultsA) - 1 do begin
      if (i <> 0) and (i mod MaxPageResults = 0) then begin

        //Ограничить кол-во страниц
        if PagesCount = MaxPages then break;

        Inc(PagesCount);
        Results.Add('</div>' + #13#10#13#10 + '<div id="page' + IntToStr(PagesCount) + '" style="display:none;">');
      end;
      Results.Add(#9#9 + '<div id="item">' + #13#10 +
      #9#9#9 + '<span id="title" onclick="Request(''' + '/?file=' + FixNameURI(ResultsA[i].path) + ''', this);">' + ResultsA[i].Name + ExtractFileExt(ResultsA[i].Path) + '</span>' + #13#10 +
      #9#9#9 + '<!--ResultRank ' + IntToStr(ResultsA[i].Rank) + '-->' + #13#10 +
      #9#9#9 + '<div id="link">' + ResultsA[i].Path + '</div>' + #13#10 +
      //'<div id="description">Пусто</div>' + #13#10 +
      #9#9#9 + '<span id="folder" onclick="Request(''' + '/?folder=' + FixNameURI(ResultsA[i].Path) + ''', this);">Открыть папку</span>' + #13#10 +
      #9#9 + '</div>' + #13#10);

    end;
      Results.Add(#9 + '</div>' + #13#10);

  //Вывод страничной навигации
  if PagesCount > 1 then begin
    Results.Add(#13#10 + '<div id="pages">Страницы: ');
    Results.Text:=Results.Text + #9 + '<span id="nav1" class="active" onclick="ShowResults(1);">1</span>';
    for i:=2 to PagesCount do
       Results.Text:=Results.Text + #9 + '<span id="nav' + IntToStr(i) + '" onclick="ShowResults(' + IntToStr(i) + ');">' + IntToStr(i) + '</span>';
    Results.Add('</div>');
  end;

  Result:=Results.Text;
  Results.Free;
  SearchList.Free;
  CheckList.Free;
  TagsList.Free;
end;

function CutStr(Str: string; CharCount: integer): string;
begin
  if Length(Str) > CharCount then
    Result:=Copy(Str, 1, CharCount - 3) + '...'
  else
    Result:=Str;
end;

procedure TMain.ScanDir(Dir: string);
var
  SR: TSearchRec; i: integer; FileTags: string;
begin
  StatusBar.SimpleText:=CutStr(' Идет сканирование папки: ' + Dir, 70);

  if Dir[Length(Dir)] <> '\' then Dir:=Dir + '\';

  //Игнорируемые папки
  if (Trim(IgnorePaths.Text) <> '') then
    for i:=0 to IgnorePaths.Lines.Count - 1 do
      if Trim(IgnorePaths.Lines.Strings[i]) <> '' then
        if IgnorePaths.Lines.Strings[i] + '\' = Dir then Exit;

  //Теги
  if (TagsCB.Checked) and (FileExists(Dir + 'tags.' + TagsExt)) then
    try
      FileTagsList.LoadFromFile(Dir + 'tags.' + TagsExt);
    except
      FileTagsList.Text:='';
    end;

  //Поиск файлов
  if FindFirst(Dir + '*.*', faAnyFile, SR) = 0 then begin
    repeat
      Application.ProcessMessages;
      if (SR.Name <> '.') and (SR.Name <> '..') then
        if (SR.Attr and faDirectory) <> faDirectory then begin

          if (Pos(AnsiLowerCase(Copy(ExtractFileExt(SR.Name), 2, Length(ExtractFileExt(SR.Name)))), AnsiLowerCase(ExtsEdit.Text)) > 0) or (ExtsEdit.Text = '') and (ExtractFileExt(SR.Name) <> '.' + TagsExt) then begin

            FileTags:='';
            //Теги
            if (TagsCB.Checked) and (FileTagsList.Text <> '') then
              for i:=0 to FileTagsList.Count - 1 do
                if (Trim(FileTagsList.Strings[i]) <> '') and (AnsiLowerCase( Copy(FileTagsList.Strings[i], 1, Pos(#9, FileTagsList.Strings[i]) - 1)) = AnsiLowerCase(SR.Name)) then begin
                  FileTags:=Copy(FileTagsList.Strings[i], Pos(#9, FileTagsList.Strings[i]) + 1, Length(FileTagsList.Strings[i]));
                  FileTags:=StringReplace(FileTags, '  ', ' ', [rfReplaceAll]);
                  FileTags:=StringReplace(FileTags, ', ', ',', [rfReplaceAll]);
                  break;
                end;

            XMLFile.Add('   <file ext="' + AnsiLowerCase(Copy(ExtractFileExt(SR.Name), 2, Length(ExtractFileExt(SR.Name)))) + '" tags="' + AnsiLowerCase(FileTags) + '" path="'+ FixName(Dir + SR.name) + '">'+ FixName(Copy(SR.Name, 1, Length(SR.Name) - Length(ExtractFileExt(SR.Name)))) + '</file>');
          end;
            
        end else ScanDir(Dir + SR.Name + '\');
    until FindNext(SR)<>0;
    FindClose(SR);
  end;
end;

procedure TMain.CreateCatBtnClick(Sender: TObject);
var
  i: integer; DBSaveName: string;
begin
  DBSaveName:='';

  if InputQuery(Caption, 'Введите название базы данных:', DBSaveName) then begin

    if Pos(' ', DBSaveName) > 0 then begin
      Application.MessageBox('Название базы данных не должно содержать пробелов.', PChar(Application.Title), MB_ICONWARNING);
      Exit;
    end;

    //NTFS
    if (Pos('\', DBSaveName) > 0) or (Pos('/', DBSaveName) > 0) or (Pos(':', DBSaveName) > 0) or (Pos('*', DBSaveName) > 0) or
    (Pos('?', DBSaveName) > 0) or (Pos('"', DBSaveName) > 0) or (Pos('<', DBSaveName) > 0) or (Pos('>', DBSaveName) > 0) or
    (Pos('|', DBSaveName) > 0) or

    //FAT
    (Pos('+', DBSaveName) > 0) or (Pos('.', DBSaveName) > 0) or (Pos(';', DBSaveName) > 0) or
    (Pos('=', DBSaveName) > 0) or (Pos('[', DBSaveName) > 0) or (Pos(']', DBSaveName) > 0)

    then begin
      Application.MessageBox('Имя файла не должно содержать запрещенных файловой системой знаков.', PChar(Application.Title), MB_ICONWARNING);
      Exit;
    end;

    //Отключение кнопок
    Paths.Enabled:=false;
    AddPathBtn.Enabled:=false;
    OpenPathsBtn.Enabled:=false;
    SavePathsBtn.Enabled:=false;

    ExtsEdit.Enabled:=false;
    ClearExtsBtn.Enabled:=false;

    AllCB.Enabled:=false;
    TextCB.Enabled:=false;
    PicsCB.Enabled:=false;
    ArchCB.Enabled:=false;

    IgnorePaths.Enabled:=false;
    AddIgnorePathBtn.Enabled:=false;
    OpenIgnorePathsBtn.Enabled:=false;
    SaveIgnorePathsBtn.Enabled:=false;

    CreateCatBtn.Enabled:=false;
    CancelBtn.Enabled:=false;

    if TextCB.Checked then
      if Pos(TextExts, ExtsEdit.Text) = 0 then ExtsEdit.Text:=ExtsEdit.Text + ' ' + TextExts;
    if PicsCB.Checked then
      if Pos(PicExts, ExtsEdit.Text) = 0 then ExtsEdit.Text:=ExtsEdit.Text + ' ' + PicExts;
    if VideoCB.Checked then
      if Pos(VideoExts, ExtsEdit.Text) = 0 then ExtsEdit.Text:=ExtsEdit.Text + ' ' + VideoExts;
    if AudioCB.Checked then
      if Pos(AudioExts, ExtsEdit.Text) = 0 then ExtsEdit.Text:=ExtsEdit.Text + ' ' + AudioExts;
    if ArchCB.Checked then
      if Pos(ArchExts, ExtsEdit.Text) = 0 then ExtsEdit.Text:=ExtsEdit.Text + ' ' + ArchExts;
    if (ExtsEdit.Text <> '') and (ExtsEdit.Text[1] = ' ') then ExtsEdit.Text:=Copy(ExtsEdit.Text, 2, Length(ExtsEdit.Text));


    if AllCB.Checked then ExtsEdit.Text:='';

    FileTagsList:=TStringList.Create;
    XMLFile:=TStringList.Create;
    XMLFile.Add('<?xml version="1.0" encoding="windows-1251" ?>'+#13#10+'<tree>'+#13#10+' <files>');
    for i:=0 to Paths.Lines.Count - 1 do
      if Trim(Paths.Lines.Strings[i]) <> '' then ScanDir(Paths.Lines.Strings[i]);
    XMLFile.Add(' </files>'+#13#10+'</tree>');
    if FileExists(ExtractFilePath(ParamStr(0)) + 'dbs\' + DBSaveName + '.xml') then DeleteFile(ExtractFilePath(ParamStr(0)) + 'dbs\' + DBSaveName + '.xml');
    XMLFile.SaveToFile(ExtractFilePath(ParamStr(0)) + 'dbs\' + DBSaveName + '.xml');
    XMLFile.Free;
    FileTagsList.Free;
    StatusBar.SimpleText:='';
    Application.MessageBox('Готово', PChar(Application.Title), MB_ICONINFORMATION);

    //Включение кнопок
    Paths.Enabled:=true;
    AddPathBtn.Enabled:=true;
    OpenPathsBtn.Enabled:=true;
    SavePathsBtn.Enabled:=true;

    ExtsEdit.Enabled:=true;
    ClearExtsBtn.Enabled:=true;

    AllCB.Enabled:=true;
    TextCB.Enabled:=true;
    PicsCB.Enabled:=true;
    ArchCB.Enabled:=true;

    IgnorePaths.Enabled:=true;
    AddIgnorePathBtn.Enabled:=true;
    OpenIgnorePathsBtn.Enabled:=true;
    SaveIgnorePathsBtn.Enabled:=true;

    CreateCatBtn.Enabled:=true;
    CancelBtn.Enabled:=true;
  end;
end;

procedure TMain.IdHTTPServerCommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  RequestText, RequestType, RequestExt, RequestCategory, TempRequestDocument, TempFilePath, TempDirPath: string; i: integer;
begin
  if (AllowIPs.Count > 0) and (Trim(AnsiUpperCase(AllowIPs.Strings[0])) <> 'ALL') then
    if Pos(AThread.Connection.Socket.Binding.PeerIP, AllowIPs.Text) = 0 then Exit;

  CoInitialize(nil);

  if (ARequestInfo.Document = '') or (ARequestInfo.Document = '/') and (ARequestInfo.Params.Text = '') then
    AResponseInfo.ContentText:=TemplateMain.Text
  else begin
    TempRequestDocument:=StringReplace(ARequestInfo.Document, '/', '\', [rfReplaceAll]);
    TempRequestDocument:=StringReplace(TempRequestDocument, '\\', '\', [rfReplaceAll]);
    if TempRequestDocument[1] = '\' then Delete(TempRequestDocument, 1, 1);

    if FileExists(ExtractFilePath(ParamStr(0)) + TempRequestDocument) then begin
      AResponseInfo.ContentType:=IdHTTPServer.MIMETable.GetDefaultFileExt(ExtractFilePath(ParamStr(0)) + TempRequestDocument);
      IdHTTPServer.ServeFile(AThread, AResponseinfo, ExtractFilePath(ParamStr(0)) + TempRequestDocument);
    end;
  end;


  if ARequestInfo.Params.Count > 0 then begin

    //Открытие файлов по запросу
    if Copy(ARequestInfo.Params.Text, 1, 5) = 'file=' then begin
      AResponseInfo.ContentText:=TemplateOpen.Text;
      TempFilePath:=RevertFixNameURI(Copy(ARequestInfo.Params.Strings[0], 6, Length(ARequestInfo.Params.Strings[0])));
      if FileExists(TempFilePath) then begin
        ShellExecute(0, 'open', PChar(TempFilePath), nil, nil, SW_SHOW);
        AResponseInfo.ContentText:=TemplateOpen.Text;
      end else AResponseInfo.ContentText:=StringReplace(Template404.Text, '[%FILE%]', AnsiToUTF8(TempFilePath), [rfIgnoreCase]);
    end;

    //Открытие папок по запросу
    if Copy(ARequestInfo.Params.Text, 1, 7) = 'folder=' then begin
      TempFilePath:=RevertFixNameURI(Copy(ARequestInfo.Params.Strings[0], 8, Length(ARequestInfo.Params.Strings[0])));
      if FileExists(TempFilePath) then begin
        ShellExecute(0, 'open', 'explorer', PChar('/select, '+ TempFilePath), nil, SW_SHOW);
        AResponseInfo.ContentText:=TemplateOpen.Text;
      end else begin
        TempDirPath:=Copy(TempFilePath, 1, Pos(ExtractFileName(TempFilePath), TempFilePath)-1);
        if DirectoryExists(TempDirPath) then ShellExecute(0, 'open', PChar(TempDirPath), nil, nil, SW_SHOW)
        else AResponseInfo.ContentText:=StringReplace(Template404.Text, '[%FILE%]', UTF8ToAnsi(TempDirPath), [rfIgnoreCase]);
      end;
    end;


    if Copy(ARequestInfo.Params.Text, 1, 2) = 'q=' then begin

      RequestText:=Copy(ARequestInfo.Params.Strings[0], 3, Length(ARequestInfo.Params.Strings[0]));

      RequestText:=StringReplace(RequestText, '  ', ' ', [rfReplaceAll]);
      RequestText:=StringReplace(RequestText, ' type: ', ' type:', [rfIgnoreCase]);
      RequestText:=StringReplace(RequestText, ' ext: ', ' ext:', [rfIgnoreCase]);
      RequestText:=StringReplace(RequestText, ' cat: ', ' cat:', [rfIgnoreCase]);

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
          RequestExt:=RequestExt + AnsiLowerCase(RequestText[i]);
        end;

      //Поиск команды cat (категория)
      if Pos(AnsiLowerCase(' cat:'), AnsiLowerCase(RequestText)) > 0 then
        for i:=Pos(' cat:', AnsiLowerCase(RequestText)) + 5 to Length(RequestText) do begin
          if RequestText[i]=' ' then break;
          RequestCategory:=RequestCategory + AnsiLowerCase(RequestText[i]);
        end;

      //Удаление из запроса команд
      if Pos(' type:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' type:', AnsiLowerCase(RequestText)) - 1);
      if Pos(' ext:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' ext:', AnsiLowerCase(RequestText)) - 1);
      if Pos(' cat:', AnsiLowerCase(RequestText)) > 0 then
        RequestText:=Copy(RequestText, 1, Pos(' cat:', AnsiLowerCase(RequestText)) - 1);

      AResponseInfo.ContentText:=StringReplace( StringReplace(TemplateResults.Text, '[%NAME%]', Copy(ARequestInfo.Params.Strings[0], 3, Length(ARequestInfo.Params.Strings[0])), [rfReplaceAll]),
      '[%RESULTS%]', GetResults(RequestText, RequestType, RequestExt, RequestCategory), [rfIgnoreCase]);
    end;

  end;

  RequestType:='';
  RequestExt:='';
  RequestCategory:='';
  CoUninitialize;
end;

function BrowseFolderDialog(Title: PChar): string;
var
  TitleName: string;
  lpItemid: pItemIdList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of Char;
  TempPath: array[0..MAX_PATH] of Char;
begin
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  BrowseInfo.hwndOwner:=GetDesktopWindow;
  BrowseInfo.pSzDisplayName:=@DisplayName;
  TitleName:=Title;
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
  if Paths.Lines.Strings[Paths.Lines.Count - 1] = '' then
    Paths.Lines.Delete(Paths.Lines.Count - 1);
end;

procedure TMain.ClearExtsBtnClick(Sender: TObject);
begin
  ExtsEdit.Clear;
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
  if TMessage(Message).Msg = WM_TASKBARCREATED then
    Tray(1);
  inherited;
end;

procedure TMain.DBCreateBtnClick(Sender: TObject);
begin
  ShowWindow(Handle, SW_NORMAL);
  SetForegroundWindow(Main.Handle);
end;

procedure TMain.GoToSearchBtnClick(Sender: TObject);
begin
  ShellExecute(Handle, nil, PChar('http://127.0.0.1:' + IntToStr(IdHTTPServer.DefaultPort)), nil, nil, SW_SHOW);
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
    Application.MessageBox('Home Search 0.6' + #13#10 +
    'Последнее обновление: 26.04.2018' + #13#10 +
    'http://r57zone.github.io' + #13#10 +
    'r57zone@gmail.com', 'О программе...', MB_ICONINFORMATION);
end;

procedure TMain.CancelBtnClick(Sender: TObject);
begin
  ShowWindow(Handle, SW_HIDE);
end;

procedure TMain.OpenPathsBtnClick(Sender: TObject);
begin
  OpenDialog.FileName:='';
  OpenDialog.Filter:='Папки Home Search|*.' + PathsExt;
  if OpenDialog.Execute then
    Paths.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TMain.SavePathsBtnClick(Sender: TObject);
begin
  SaveDialog.FileName:='';
  SaveDialog.Filter:='Папки Home Search|*.' + PathsExt;
  SaveDialog.DefaultExt:=SaveDialog.Filter;
  if SaveDialog.Execute then
    Paths.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TMain.OpenIgnorePathsBtnClick(Sender: TObject);
begin
  OpenDialog.FileName:='';
  OpenDialog.Filter:='Папки Home Search|*.' + PathsExt;
  if OpenDialog.Execute then
    IgnorePaths.Lines.LoadFromFile(OpenDialog.FileName);
end;

procedure TMain.SaveIgnorePathsBtnClick(Sender: TObject);
begin
  SaveDialog.FileName:='';
  SaveDialog.Filter:='Папки Home Search|*.' + PathsExt;
  SaveDialog.DefaultExt:=SaveDialog.Filter;
  if SaveDialog.Execute then
    IgnorePaths.Lines.SaveToFile(SaveDialog.FileName);
end;

procedure TMain.DBsOpenClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar(ExtractFilePath(ParamStr(0)) + DataBasesPath), nil, nil, SW_SHOW);
end;

procedure TMain.TagsCreateBtnClick(Sender: TObject);
begin
  TagsForm.Show;
end;

end.
