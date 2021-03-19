page 50100 "Purchase Picture Card"
{
    Caption = 'Purchase Picture';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = "Purchase Header";

    layout
    {
        area(content)
        {
            field(Picture; Rec.Picture)
            {
                ApplicationArea = All;
                ShowCaption = false;
                ToolTip = 'Specifies the picture that has been inserted for the document.';
            }
            usercontrol(PictureAddIn; PictureAddIn)
            {
                ApplicationArea = All;
                trigger OnControlAddInReady()
                begin
                    CurrPage.PictureAddIn.embedPicture();
                    //ControlIsReady := true;
                    //InitControls();
                end;

                trigger HandleAction(Data: JsonArray; PageAction: JsonObject)
                begin
                    HandleAction(Data, PageAction);
                end;

                trigger ValidateField(FieldKey: Integer; Data: JsonArray)
                begin
                    //ValidateData(FieldKey, Data);
                end;

                trigger UpdateRecord(Data: JsonArray)
                begin
                    UpdateRecord(Data);
                end;
            }
        }
    }
    local procedure UpdateRecord(Object: JsonArray)
    begin
    end;

    /*  local procedure InitControls()
     var
         RecRef: RecordRef;
         Data: JsonArray;
         FieldList: JsonArray;
         PageActions: JsonArray;
         FieldObject: JsonObject;
         i: Integer;
     begin
         FieldList := GetArrayFromMetadata('fieldlist');
         PageActions := GetArrayFromMetadata('actions');
         GetRecRef(RecRef);

         for i := 0 to FieldList.Count - 1 do begin
             FieldObject := GetFieldObjectFromFieldList(FieldList, i);
             AddFieldInformation(FieldObject, RecRef, GetFieldNumberFromFieldObject(FieldObject));
             Data.Add(AddFieldData(RecRef, GetFieldNumberFromFieldObject(FieldObject)));
         end;

         // Message('Fieldlist: %1', Format(FieldList));
         // Message('Actions: %1', Format(PageActions));
         // Message('Data: %1', Format(Data));

         CurrPage.PictureAddIn.InitControls(FieldList, Data, PageActions);
     end; */

    /* local procedure ValidateData(FieldKey: Integer; Data: JsonArray)
    var
        PurchaseDocumentFunc: Codeunit "Purchase Document Functions";
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldList: JsonArray;
        FieldObject: JsonObject;
        JToken: JsonToken;
        i: Integer;
        LastError: Text;
    // StreamOut: OutStream;
    begin
        FieldList := GetArrayFromMetadata('fieldlist');
        GetRecRef(RecRef);
        FieldObject := GetFieldObjectFromFieldList(FieldList, FieldKey);
        FldRef := RecRef.Field(GetFieldNumberFromFieldObject(FieldObject));
        Data.Get(FieldKey, JToken);
        JToken.AsObject().Get('fieldvalue', JToken);
        Evaluate(FldRef, JToken.AsValue().AsText());

        PurchaseDocumentFunc.SetRecordRef(RecRef);
        PurchaseDocumentFunc.SetFieldRef(FldRef);
        if not PurchaseDocumentFunc.Run() then
            LastError := GetLastErrorText();
        RecRef.Find();

        Clear(Data);

        for i := 0 to FieldList.Count - 1 do begin
            FieldObject := GetFieldObjectFromFieldList(FieldList, i);
            Data.Add(AddFieldData(RecRef, GetFieldNumberFromFieldObject(FieldObject)));
        end;

        // Message('Field: %1, Data: %2', FieldNo, Data);
        Sleep(1000);

        CurrPage.PictureAddIn.ValidationResult(FieldKey, Data, LastError);
    end;
 */
    local procedure HandleAction(Data: JsonArray; PageAction: JsonObject)
    var
        PurchaseDocumentFunc: Codeunit "Purchase Document Functions";
        RecRef: RecordRef;
    begin
        Message('Action %1, Data %2', PageAction, Data);
        // Handle getting RecRef and add data to that
        PurchaseDocumentFunc.HandleAction(RecRef, PageAction);
    end;

    local procedure AddFieldInformation(var FieldObject: JsonObject; var RecRef: RecordRef; FieldNo: Integer)
    var
        FldRef: FieldRef;
    begin
        FldRef := RecRef.Field(FieldNo);
        FieldObject.Add('fieldcaption', FldRef.Caption);
        if FldRef.Class = FldRef.Class::FlowField then
            FieldObject.Replace('readOnly', true);
        FieldObject.Add('fieldtype', Format(FldRef.Type));
        FieldObject.Add('optioncaption', FldRef.OptionCaption);
        FieldObject.Add('validated', true);
    end;

    local procedure AddFieldData(var RecRef: RecordRef; FieldNo: Integer) FieldData: JsonObject
    var
        FldRef: FieldRef;
        MyValue: JsonValue;
        MyBoolean: Boolean;
        MyOption: Option;
        MyInteger: Integer;
        MyBigInteger: BigInteger;
        MyDecimal: Decimal;
        MyDuration: Duration;
        MyDate: Date;
        MyTime: Time;
        MyDateTime: DateTime;
    begin
        FldRef := RecRef.Field(FieldNo);
        FieldData.Add('fieldno', FieldNo);

        case true of
            FldRef.Class = FldRef.Class::FlowField,
            FldRef.Type = FldRef.Type::Blob:
                FldRef.CalcField();
        end;

        case FldRef.Type of
            FldRef.Type::Option:
                begin
                    MyOption := FldRef.Value;
                    MyValue.SetValue(MyOption);
                end;
            FldRef.Type::Boolean:
                begin
                    MyBoolean := FldRef.Value;
                    MyValue.SetValue(MyBoolean);
                end;
            FldRef.Type::Date:
                begin
                    MyDate := FldRef.Value;
                    MyValue.SetValue(MyDate);
                end;
            FldRef.Type::DateTime:
                begin
                    MyDateTime := FldRef.Value;
                    MyValue.SetValue(MyDateTime);
                end;
            FldRef.Type::Decimal:
                begin
                    MyDecimal := FldRef.Value;
                    MyValue.SetValue(MyDecimal);
                end;
            FldRef.Type::Integer:
                begin
                    MyInteger := FldRef.Value;
                    MyValue.SetValue(MyInteger);
                end;
            FldRef.Type::Time:
                begin
                    MyTime := FldRef.Value;
                    MyValue.SetValue(MyTime);
                end;
            FldRef.Type::Duration:
                begin
                    MyDuration := FldRef.Value;
                    MyValue.SetValue(MyDuration);
                end;
            else
                MyValue.SetValue(Format(FldRef.Value));
        end;
        FieldData.Add('fieldvalue', MyValue);
    end;

    /* local procedure GetArrayFromMetadata(JKey: Text): JsonArray
    var
        JsonContent: JsonObject;
        Token: JsonToken;
    begin
        JsonContent := GetPageMetadata();
        JsonContent.Get(JKey, Token);
        exit(Token.AsArray());
    end;

    local procedure CheckIfRecRefMatchesPageMetadata()
    var
        RecRef: RecordRef;
        JsonContent: JsonObject;
        Token: JsonToken;
    begin
        RecRef := "Source Record Id".GetRecord();
        JsonContent := GetPageMetadata();
        JsonContent.Get('recordno', Token);
        if not (Token.AsValue().AsInteger() = RecRef.Number) then
            error(SourceRecRefDoesNotMatchSetupErr);
    end;

    local procedure SetParentDataLink()
    var
        JsonContent: JsonObject;
        Token: JsonToken;
        StreamOut: OutStream;
    begin
        JsonContent := GetPageMetadata();
        JsonContent.Get('parentDatalink', Token);
        "Parent Data Link".CreateOutStream(StreamOut);
        StreamOut.WriteText(Format(Token.AsArray()));
        Modify();
    end;

    local procedure GetFieldObjectFromFieldList(FieldList: JsonArray; i: Integer): JsonObject
    var
        JsonContent: JsonObject;
        Token: JsonToken;
    begin
        FieldList.Get(i, Token);
        exit(Token.AsObject());
    end;

    local procedure GetFieldNumberFromFieldObject(FieldObject: JsonObject): Integer
    var
        Token: JsonToken;
    begin
        FieldObject.Get('fieldno', Token);
        exit(Token.AsValue().AsInteger());
    end;

    local procedure GetRecRef(var RecRef: RecordRef)
    begin
        RecRef := "Source Record Id".GetRecord();
        RecRef.SetRecFilter();
        RecRef.FindFirst();
    end;

    var
        ControlIsReady: Boolean;
        SourceRecRefDoesNotMatchSetupErr: Label 'The page source does not match the record no. specified in the settings.';
        PostActionMsg: Label 'Post';
        PostPrintActionMsg: Label 'Post & Print';

    local procedure CreateTest()
    var
        SalesHeader: Record "Sales Header";
        RecRef: RecordRef;
        FldRef: FieldRef;
        FieldList: JsonArray;
        PageActions: JsonArray;
        PageMetadata: JsonObject;
        Object: JsonObject;
        DataLinkObject: JsonObject;
        DataLink: JsonArray;
        StreamOut: OutStream;
    begin
        // This is just to create something to test with
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindLast();
        "Source Record Id" := SalesHeader.RecordId;
        RecRef := "Source Record Id".GetRecord();
        Insert();

        FldRef := RecRef.Field(SalesHeader.FieldNo("No."));
        Object.Add('fieldno', FldRef.Number);
        Object.Add('validate', false);
        Object.Add('readOnly', true);
        Object.Add('mandatory', true);
        FieldList.Add(Object);
        Clear(Object);
        FldRef := RecRef.Field(SalesHeader.FieldNo("Document Type"));
        Object.Add('fieldno', FldRef.Number);
        Object.Add('validate', false);
        Object.Add('readOnly', true);
        Object.Add('mandatory', false);
        FieldList.Add(Object);
        Clear(Object);
        FldRef := RecRef.Field(SalesHeader.FieldNo("Bill-to Name"));
        Object.Add('fieldno', FldRef.Number);
        Object.Add('validate', true);
        Object.Add('readOnly', false);
        Object.Add('mandatory', false);
        FieldList.Add(Object);
        Clear(Object);
        FldRef := RecRef.Field(SalesHeader.FieldNo("External Document No."));
        Object.Add('fieldno', FldRef.Number);
        Object.Add('validate', true);
        Object.Add('readOnly', false);
        Object.Add('mandatory', false);
        FieldList.Add(Object);
        Clear(Object);
        FldRef := RecRef.Field(SalesHeader.FieldNo(Amount));
        Object.Add('fieldno', FldRef.Number);
        Object.Add('validate', true);
        Object.Add('readOnly', false);
        Object.Add('mandatory', false);
        FieldList.Add(Object);
        Clear(Object);

        Object.Add('actionText', PostActionMsg);
        Object.Add('action', 'post');
        Object.Add('handleInNav', true);
        PageActions.Add(Object);
        Clear(Object);
        Object.Add('actionText', PostPrintActionMsg);
        Object.Add('action', 'postPrint');
        Object.Add('handleInNav', false);
        PageActions.Add(Object);
        Clear(Object);

        DataLinkObject.Add('parentField', 1);
        DataLinkObject.Add('childField', 1);
        DataLink.Add(DataLinkObject);
        Clear(DataLinkObject);
        DataLinkObject.Add('parentField', 2);
        DataLinkObject.Add('childField', 2);
        DataLink.Add(DataLinkObject);
        Clear(DataLinkObject);
        v

        PageMetadata.Add('recordno', RecRef.Number);
        PageMetadata.Add('parentDatalink', DataLink);
        PageMetadata.Add('fieldlist', FieldList);
        PageMetadata.Add('actions', PageActions);

        "Page Metadata".CreateOutStream(StreamOut);
        StreamOut.WriteText(Format(PageMetadata));

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindFirst();

        Modify();
        // Message(Format(GetPageMetadata()));
    end; */
}