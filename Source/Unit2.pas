unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TTagsForm = class(TForm)
    AddBtn: TButton;
    RemBtn: TButton;
    ClearBtn: TButton;
    SaveBtn: TButton;
    CancelBtn: TButton;
    FilesTagsLB: TListBox;
    Label2: TLabel;
    Label1: TLabel;
    OpenBtn: TButton;
    EditBtn: TButton;
    procedure CancelBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SaveBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure ClearBtnClick(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure EditBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TagsForm: TTagsForm;
  TagsList: TStringList;

implementation

uses Unit1;

{$R *.dfm}

procedure TTagsForm.CancelBtnClick(Sender: TObject);
begin
  FilesTagsLB.Clear;
  Close;
end;

procedure TTagsForm.AddBtnClick(Sender: TObject);
var
  Value: string;
begin
  Main.OpenDialog.FileName:='';
  Main.OpenDialog.Filter:='Все файлы|*.*';
  if (Main.OpenDialog.Execute) and (Main.OpenDialog.FileName <> '') and (FileExists(Main.OpenDialog.FileName)) then begin

    if (FilesTagsLB.Items.Count > 0) and (ExtractFilePath( Copy(TagsList.Strings[0], 1, Pos(#9, TagsList.Strings[0]) - 1) ) <> ExtractFilePath(Main.OpenDialog.FileName)) then begin
      Application.MessageBox('Файлы должны быть только из этой папки.' + #13#10 + 'Для каждой папки свой файл тегов.', PChar(Application.Title), MB_ICONWARNING);
      Exit;
    end;

    if (InputQuery(Caption, 'Введите тег или теги (через запятую)', Value)) then begin
      FilesTagsLB.Items.Add(ExtractFileName(Main.OpenDialog.FileName) + ^I + Value);
      if FilesTagsLB.Items.Text <> '' then TagsList:=TStringList.Create;
      TagsList.Add(Main.OpenDialog.FileName + #9 + Value);
    end;
  end;
end;

procedure TTagsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(TagsList) then
    TagsList.Free;
end;

procedure TTagsForm.SaveBtnClick(Sender: TObject);
begin
  TagsList.SaveToFile(ExtractFilePath(Main.OpenDialog.FileName) + 'tags.' + TagsExt);
  Application.MessageBox('Файл с тегами сохранен.', PChar(Application.Title), MB_ICONINFORMATION);
end;

procedure TTagsForm.RemBtnClick(Sender: TObject);
begin
  if FilesTagsLB.ItemIndex <> -1 then begin
    TagsList.Delete(FilesTagsLB.ItemIndex);
    FilesTagsLB.Items.Delete(FilesTagsLB.ItemIndex);
  end;
end;

procedure TTagsForm.ClearBtnClick(Sender: TObject);
begin
  FilesTagsLB.Clear;
  TagsList.Clear;
end;

procedure TTagsForm.OpenBtnClick(Sender: TObject);
var
  i: integer;
begin
  Main.OpenDialog.FileName:='tags';
  Main.OpenDialog.Filter:='Теги Home Search|*.' + TagsExt;
  if (Main.OpenDialog.Execute) and (Main.OpenDialog.FileName <> '') and (FileExists(Main.OpenDialog.FileName)) then begin
    TagsList:=TStringList.Create;
    TagsList.LoadFromFile(Main.OpenDialog.FileName);
    FilesTagsLB.Clear;
    for i:=0 to TagsList.Count - 1 do
      FilesTagsLB.Items.Add( ExtractFileName( Copy(TagsList.Strings[i], 1, Pos(#9, TagsList.Strings[i]) - 1) ) + ^I +  Copy(TagsList.Strings[i], Pos(#9, TagsList.Strings[i]) + 1, Length(TagsList.Strings[i])) );
  end;
end;

procedure TTagsForm.EditBtnClick(Sender: TObject);
var
  FileName, Value: string;
begin
  if FilesTagsLB.ItemIndex <> -1 then begin
    Value:=Copy(TagsList.Strings[FilesTagsLB.ItemIndex], Pos(#9, TagsList.Strings[FilesTagsLB.ItemIndex]) + 1, Length(TagsList.Strings[FilesTagsLB.ItemIndex]));
    InputQuery(Caption, 'Тег или теги (через запятую)', Value);
    FileName:=Copy(TagsList.Strings[FilesTagsLB.ItemIndex], 1, Pos(#9, TagsList.Strings[FilesTagsLB.ItemIndex]) - 1);
    FilesTagsLB.Items.Strings[FilesTagsLB.ItemIndex]:=ExtractFileName(FileName) + #9 + Value;
    TagsList.Strings[FilesTagsLB.ItemIndex]:=FileName + #9 + Value;
  end;
end;

end.
