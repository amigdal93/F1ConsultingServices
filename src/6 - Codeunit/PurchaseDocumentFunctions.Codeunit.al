codeunit 50100 "Purchase Document Functions"
{
    trigger OnRun()
    begin
        FldRef.Validate(); // Move to codeunit so we can do tryvalidate and rollback when needed
        RecRef.Modify();
    end;

    // scatta la foto da web camera
    procedure TakeNewPicture(var DocType: Enum "Purchase Document Type"; No: Code[20])
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange(PurchaseHeader."Document Type", DocType);
        PurchaseHeader.SetRange(PurchaseHeader."No.", No);
        if PurchaseHeader.FindSet() then begin
            //PurchaseHeader.TestField(PurchaseHeader."No.");
            Camera.AddPicture(PurchaseHeader, PurchaseHeader.FieldNo(Picture));
        end;
    end;

    // importa l'immagine (funzione per Cloud)
    procedure ImportFromDevice(var PicInStream: InStream; FromFileName: Text)
    var
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?', Locked = false, MaxLength = 250;
    begin
        if PurchaseHeader.Picture.Count > 0 then
            if not Confirm(OverrideImageQst) then
                exit;

        if UploadIntoStream('Import', '', 'All Files (*.*)|*.*', FromFileName, PicInStream) then begin
            Clear(PurchaseHeader.Picture);
            PurchaseHeader.Picture.ImportStream(PicInStream, FromFileName);
            PurchaseHeader.Modify(true);
        end;
    end;

    // scarica l'immagine
    procedure ExportToDevice()
    var
        InStream: InStream;
        OutStream: OutStream;
        ToFileName: Text;
        TempBlob: Record TempBlob temporary;
        ExpXMLPort: XmlPort "Export Contact";
    begin
        TempBlob.Blob.CreateOutStream(OutStream, TextEncoding::UTF8);
        ExpXMLPort.SetDestination(OutStream);
        ExpXMLPort.Export();
        TempBlob.Blob.CreateInStream(InStream, TextEncoding::UTF8);
        ToFileName := 'Document Image';

        File.DownloadFromStream(InStream, 'Export', '', 'All Files (*.*)|*.*', ToFileName);

        /*  if DownloadFromStream('Export', '', 'All Files (*.*)|*.*', ToFileName, PicOutStream) then begin
             PurchaseHeader.Picture.ExportStream(PicOutStream, ToFileName);

         end;*/
    end;

    // elimina l'immagine
    procedure DeleteItemPicture()
    begin
        PurchaseHeader.TestField("No.");

        if not Confirm(DeleteImageQst) then
            exit;

        Clear(PurchaseHeader.Picture);
        PurchaseHeader.Modify(true);
    end;

    //// <funzioni gestibili OnPremise

    // importazione dell'immagine per OnPremise
    /* procedure ImportFromDevice()
    var
        FileName: Text;
        ClientFileName: Text;
    begin
        PurchaseHeader.Find();
        PurchaseHeader.TestField("No.");

        if PurchaseHeader.Picture.Count > 0 then
            if not Confirm(OverrideImageQst) then
                Error('');

        ClientFileName := '';
        FileName := UploadFile(SelectPictureTxt, ClientFileName);
        if FileName = '' then
            Error('');

        Clear(PurchaseHeader.Picture);
        PurchaseHeader.Picture.ImportFile(FileName, ClientFileName);
        PurchaseHeader.Modify(true);

        if FileManagement.DeleteServerFile(FileName) then;
    end;

    // gestione per importazione dell'immagine nel campo BLOB
    procedure UploadFile(WindowTitle: Text[50]; ClientFileName: Text) ServerFileName: Text
    var
        "Filter": Text;
    begin
        Filter := GetToFilterText('', ClientFileName);

        if GetFileNameWithoutExtension(ClientFileName) = '' then
            ClientFileName := '';

        ServerFileName := UploadFileWithFilter(WindowTitle, ClientFileName, Filter, AllFilesFilterTxt);
    end;

    procedure GetToFilterText(FilterString: Text; FileName: Text): Text
    var
        OutExt: Text;
    begin
        if FilterString <> '' then
            exit(FilterString);

        case UpperCase(GetExtension(FileName)) of
            'DOC':
                OutExt := WordFileType;
            'DOCX':
                OutExt := Word2007FileType;
            'XLS':
                OutExt := ExcelFileType;
            'XLSX':
                OutExt := Excel2007FileType;
            'XSLT':
                OutExt := XSLTFileType;
            'XML':
                OutExt := XMLFileType;
            'XSD':
                OutExt := XSDFileType;
            'HTM':
                OutExt := HTMFileType;
            'TXT':
                OutExt := TXTFileType;
            'RDL':
                OutExt := RDLFileTypeTok;
            'RDLC':
                OutExt := RDLFileTypeTok;
        end;

        if OutExt = '' then
            exit(AllFilesDescriptionTxt);
        exit(OutExt + '|' + AllFilesDescriptionTxt);  // Also give the option of the general selection
    end;

    procedure GetExtension(Name: Text): Text
    var
        FileExtension: Text;
    begin
        FileExtension := GetExtension(Name);

        if FileExtension <> '' then
            FileExtension := DelChr(FileExtension, '<', '.');

        exit(FileExtension);
    end;

    procedure GetFileNameWithoutExtension(FilePath: Text): Text
    begin
        exit(GetFileNameWithoutExtension(FilePath));
    end;

    procedure UploadFileWithFilter(WindowTitle: Text[50]; ClientFileName: Text; FileFilter: Text; ExtFilter: Text) ServerFileName: Text
    var
        Uploaded: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        if IsHandled then
            exit;

        ClearLastError();

        if (FileFilter = '') xor (ExtFilter = '') then
            Error(SingleFilterErr);

        Uploaded := Upload(WindowTitle, '', FileFilter, ClientFileName, ServerFileName);
        if Uploaded then
            ValidateFileExtension(ClientFileName, ExtFilter);
        if Uploaded then
            exit(ServerFileName);

        if GetLastErrorText <> '' then
            Error('%1', GetLastErrorText);

        exit('');
    end;

    procedure ValidateFileExtension(FilePath: Text; ValidExtensions: Text)
    var
        FileExt: Text;
        LowerValidExts: Text;
    begin
        if StrPos(ValidExtensions, AllFilesFilterTxt) <> 0 then
            exit;

        FileExt := LowerCase(GetExtension(GetFileName(FilePath)));
        LowerValidExts := LowerCase(ValidExtensions);

        if StrPos(LowerValidExts, FileExt) = 0 then
            Error(UnsupportedFileExtErr, FileExt, LowerValidExts);
    end;

    procedure GetFileName(FilePath: Text): Text
    begin
        exit(GetFileName(FilePath));
    end; */

    //// >funzioni gestibili OnPremise
    procedure SetRecordRef(var NewRecRef: RecordRef)
    begin
        RecRef := NewRecRef;
    end;

    procedure SetFieldRef(var NewFldRef: FieldRef)
    begin
        FldRef := NewFldRef;
    end;

    procedure HandleAction(var RecRef: RecordRef; PageAction: JsonObject)
    begin
    end;

    var
        /* PathHelper: DotNet Path;
        ServerFileHelper: DotNet File;
        ServerDirectoryHelper: DotNet Directory;
        Name: Text; */
        FileManagement: Codeunit "File Management";
        PurchaseHeader: Record "Purchase Header";
        AllFilesFilterTxt: Label '*.*', Locked = true;
        Camera: Codeunit Camera;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        DeleteImageQst: Label 'Are you sure you want to delete the picture?';
        SelectPictureTxt: Label 'Select a picture to upload';
        DownloadImageTxt: Label 'Download image';
        InvalidWindowsChrStringTxt: Label '"#%&*:<>?\/{|}~', Locked = true;
        UnsupportedFileExtErr: Label 'Unsupported file extension (.%1). The supported file extensions are (%2).';
        SingleFilterErr: Label 'Specify a file filter and an extension filter when using this function.';
        AllFilesDescriptionTxt: Label 'All Files (*.*)|*.*', Comment = '{Split=r''\|''}{Locked=s''1''}';
        XMLFileType: Label 'XML Files (*.xml)|*.xml', Comment = '{Split=r''\|''}{Locked=s''1''}';
        WordFileType: Label 'Word Files (*.doc)|*.doc', Comment = '{Split=r''\|''}{Locked=s''1''}';
        Word2007FileType: Label 'Word Files (*.docx;*.doc)|*.docx;*.doc', Comment = '{Split=r''\|''}{Locked=s''1''}';
        ExcelFileType: Label 'Excel Files (*.xls)|*.xls', Comment = '{Split=r''\|''}{Locked=s''1''}';
        Excel2007FileType: Label 'Excel Files (*.xlsx;*.xls)|*.xlsx;*.xls', Comment = '{Split=r''\|''}{Locked=s''1''}';
        XSDFileType: Label 'XSD Files (*.xsd)|*.xsd', Comment = '{Split=r''\|''}{Locked=s''1''}';
        HTMFileType: Label 'HTM Files (*.htm)|*.htm', Comment = '{Split=r''\|''}{Locked=s''1''}';
        XSLTFileType: Label 'XSLT Files (*.xslt)|*.xslt', Comment = '{Split=r''\|''}{Locked=s''1''}';
        TXTFileType: Label 'Text Files (*.txt)|*.txt', Comment = '{Split=r''\|''}{Locked=s''1''}';
        RDLFileTypeTok: Label 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FldRef: FieldRef;
        RecRef: RecordRef;
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    procedure ModifyInvoiceNrTo2020()
    var
        SIH: Record "Sales Invoice Header";
        //FormattedString: Text;
        OldNo: Text;
        NewNo: Text;
        FromChar: Text;
        ToChar: Text;
        OldValue: Text;
        NewValue: Text;
        Result: Text;
    begin

        //convert 2021 into 2020 for a year
        OldNo := Format(SIH."No.");
        FromChar := '1';
        ToChar := '0';
        NewNo := CopyStr(OldNo, 4, 1);

        OldValue := '2021';
        NewValue := '2020';

        Result := OldNo.Replace(OldValue, NewValue);

        /* 
                SIH.Reset();
                SIH.SetRange("No.", StrPos(OldNo,));
                IF SIH.Findset() THEN
                    REPEAT
                        SIH2 := SIH;
                        SIH2.RENAME(
                          SIH."No.",
                          );
                    UNTIL SIH.NEXT = 0; */
    end;
}