unit uMainForm;

interface

{$WARN SYMBOL_PLATFORM OFF}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GenericsUtils, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.CheckLst, Masks, System.StrUtils, Vcl.AppEvnts, Vcl.Menus,
  DragDrop, DropSource, DragDropFile;

const
  RequiresSectionName = 'requires';

type
  TFormMain = class(TForm)
    edtFolderName: TEdit;
    btnSelectFolder: TButton;
    btnFindDPK: TButton;
    pcLog: TPageControl;
    tsLogError: TTabSheet;
    tsLogWarning: TTabSheet;
    tsLogHint: TTabSheet;
    tsLogInfo: TTabSheet;
    dlgFolder: TFileOpenDialog;
    lstFiles: TListBox;
    ApplicationEvents: TApplicationEvents;
    mmoLogError: TMemo;
    mmoLogWarning: TMemo;
    mmoLogHint: TMemo;
    mmoLogInfo: TMemo;
    tsPkgNotFound: TTabSheet;
    lstPkgNotFound: TListBox;
    pmFiles: TPopupMenu;
    edtMask: TEdit;
    lblDefaultExt: TLabel;
    procedure btnSelectFolderClick(Sender: TObject);
    procedure edtFolderNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFindDPKClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure lstFilesMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    FDropFileSource: TDropFileSource;
    procedure ProcessControls;
    procedure PrepareControls;
    function FormatLogMessage(Filename: string; const Message: string): string;
    procedure log(const Filename: string; Message: string);
    procedure log_h(const Filename: string; Message: string);
    procedure log_w(const Filename: string; Message: string);
    procedure log_e(const Filename: string; Message: string);
    procedure log_NotFoundPkg(const Filename: string; PackageName: string);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.PrepareControls;
begin
  lstFiles.Clear;

  mmoLogError.Clear;
  mmoLogWarning.Clear;
  mmoLogHint.Clear;
  mmoLogInfo.Clear;

  lstPkgNotFound.Clear;
end;

procedure TFormMain.ProcessControls;
begin
  btnFindDPK.Enabled := DirectoryExists(edtFolderName.Text);
end;

procedure TFormMain.ApplicationEventsException(Sender: TObject; E: Exception);
begin
  log_e('', Format('Exception: %s %s', [E.ClassName, E.Message]));
end;

procedure TFormMain.btnFindDPKClick(Sender: TObject);
  procedure ExtractRequiredSection(const Filename: string;
    const Items: TStrings);
  var
    PSectBegin, PSectEnd: Integer;
    Text, Sect: string;
    I: Integer;
  begin
    Items.LoadFromFile(Filename);
    Text := Items.Text;
    Items.Clear;
    PSectBegin := Pos(UpperCase(RequiresSectionName), UpperCase(Text));
    if PSectBegin > 0 then
    begin
      PSectEnd := Pos(';', Text, PSectBegin);
      if PSectEnd > PSectBegin then
      begin
        Sect := Copy(Text, PSectBegin + Length(RequiresSectionName), PSectEnd - PSectBegin - Length(RequiresSectionName));
        Items.Delimiter := ',';
        Items.DelimitedText := Sect;
        for I := 0 to Items.Count - 1 do
          Items[I] := Trim(Items[I]);
      end
      else
        log_e(Filename, 'Bad required section');
    end;
  end;
  procedure _Find(Path: string; const Items: TStrings;
    const FileMask: string);
  var
    SearchRec: TSearchRec;
    Res: Integer;
  begin
    Path := IncludeTrailingPathDelimiter(Path);
    Res := FindFirst(Path + '*', faAnyFile, SearchRec);
    if Res = 0 then
      try
        repeat
          if ((SearchRec.Attr and faDirectory) = faDirectory) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
            _Find(Path + SearchRec.Name, Items, FileMask)
          else if MatchesMask(SearchRec.Name, FileMask) then
            Items.Add(Path + SearchRec.Name);

          Res := FindNext(SearchRec);
        until Res <> 0;
      finally
        FindClose(SearchRec);
      end;

    if (Res <> 0) and (Res <> ERROR_FILE_NOT_FOUND) and (Res <> ERROR_NO_MORE_FILES) then
      RaiseLastOSError;
  end;
  function GetFileIndex(const Package: string; const Items: TStrings): Integer;
  var
    I: Integer;
  begin
    for I := 0 to Items.Count - 1 do
      if SameText(ReplaceText(ExtractFileName(Items[I]), ExtractFileExt(Items[I]), ''), Package) then
        Exit(I);

    Result := -1;
  end;
var
  I: Integer;
  SL: TStringList;
  J: Integer;
  FileIndex: Integer;
begin
  PrepareControls;

  Screen.Cursor := crHourGlass;
  try
    lstFiles.Items.BeginUpdate;
    try
      _Find(edtFolderName.Text, lstFiles.Items, edtMask.Text + '.dpk');
    finally
      lstFiles.Items.EndUpdate;
    end;

    //Sorting...
    SL := TStringList.Create;
    try
      I := 0;
      while I <= lstFiles.Count - 1 do
      begin
        ExtractRequiredSection(lstFiles.Items[I], SL);
        for J := 0 to SL.Count - 1 do
        begin
          FileIndex := GetFileIndex(SL[J], lstFiles.Items);
          if FileIndex >= 0 then
          begin
            if FileIndex > I then
            begin
              lstFiles.Items.Move(FileIndex, I);
              log('', Format('Package %s moved from %d to %d', [SL[J], FileIndex, I]));
              I := 0;
              Continue;
            end;
          end
          else
            log_NotFoundPkg(lstFiles.Items[I], SL[J]);

          Application.ProcessMessages;
        end;

        Inc(I);
      end;
    finally
      SL.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  Application.MessageBox('Sortion completed!', '', MB_OK or MB_ICONINFORMATION);
end;

procedure TFormMain.btnSelectFolderClick(Sender: TObject);
begin
  if dlgFolder.Execute then
    edtFolderName.Text := dlgFolder.FileName;
end;

procedure TFormMain.edtFolderNameChange(Sender: TObject);
begin
  ProcessControls;
end;

function TFormMain.FormatLogMessage(Filename: string;
  const Message: string): string;
begin
  Filename := ExtractFileName(Filename);
  if Filename <> '' then
    Filename := Format('[%s]', [Filename]);

  Result := Format('%s - %s', [Filename, Message]);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FDropFileSource := TDropFileSource.Create(Self);
  ProcessControls;
end;

procedure TFormMain.log(const Filename: string; Message: string);
begin
  mmoLogInfo.Lines.Add(FormatLogMessage(Filename, Message));
end;

procedure TFormMain.log_h(const Filename: string; Message: string);
begin
  mmoLogHint.Lines.Add(FormatLogMessage(Filename, Message));
end;

procedure TFormMain.log_NotFoundPkg(const Filename: string; PackageName: string);
begin
  log_w(Filename, Format('Package %s not found', [PackageName]));
  if lstPkgNotFound.Items.IndexOf(PackageName) < 0 then
    lstPkgNotFound.Items.Add(PackageName);
end;

procedure TFormMain.log_w(const Filename: string; Message: string);
begin
  mmoLogWarning.Lines.Add(FormatLogMessage(Filename, Message));
end;

procedure TFormMain.lstFilesMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  i: Integer;
begin
  if (lstFiles.SelCount > 0) and (DragDetectPlus(TWinControl(Sender))) then
  begin
    // Delete anything from a previous drag.
    FDropFileSource.Files.Clear;
    // Fill DropSource1.Files with selected files from ListView1.
    for i := 0 to lstFiles.Count - 1 do
      if lstFiles.Selected[i] then
        FDropFileSource.Files.Add(lstFiles.Items[i]);

    // Start the drag operation.
    FDropFileSource.Execute;
  end;
end;

procedure TFormMain.log_e(const Filename: string; Message: string);
begin
  mmoLogError.Lines.Add(FormatLogMessage(Filename, Message));
end;

end.
