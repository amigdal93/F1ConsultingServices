controladdin PictureAddIn
{
    RequestedHeight = 400;
    MinimumHeight = 400;
    MaximumHeight = 400;
    RequestedWidth = 300;
    MinimumWidth = 300;
    MaximumWidth = 300;
    VerticalStretch = true;
    VerticalShrink = true;
    HorizontalStretch = true;
    HorizontalShrink = true;
    Scripts =
        'scripts/procedure.js';
    StyleSheets =
        'scripts/style.css';
    StartupScript =
        'scripts/start.js';

    procedure InitControls(FieldList: JsonArray; Data: JsonArray; PageActions: JsonArray);
    procedure ValidationResult(FieldKey: Integer; Data: JsonArray; LastError: Text);
    event OnControlAddInReady();
    // connettore tra JavaScript e Business Central

    //procedure createIframe();
    // creation of Iframe to the BC page and BC cardx
    event ValidateField(FieldKey: Integer; Data: JsonArray)
    // validation of the field

    event HandleAction(Data: JsonArray; PageAction: JsonObject);
    event UpdateRecord(Data: JsonArray);
    // update the record

    procedure embedPicture()
    //embed

    procedure SaveImage(Image: Text);
    procedure Clear()
    procedure Undo()


}