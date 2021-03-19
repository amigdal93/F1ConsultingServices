pageextension 50100 PagExtPurchaseInvoice extends "Purchase Invoice"
{
    layout
    {
        addafter("Invoice Details")
        {
            group("Purchase Picture")
            {
                ShowCaption = false;
                /*                 field(PurchPicture; Rec.Picture)
                                {
                                    ApplicationArea = All;
                                } */
                part(PictureCardPart; "Purchase Picture Card")
                {
                    ApplicationArea = All;
                    SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
                }
            }
        }
        addafter(IncomingDocAttachFactBox)
        {
            part(PictureCardPart2; "Purchase Picture Card")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = FIELD("Document Type"),
                              "No." = FIELD("No.");
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            group("PurchasePicture")
            {
                Caption = 'Purchase picture';

                action(TakePicture)
                {
                    ApplicationArea = All;
                    Caption = 'Take';
                    Image = Camera;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Activate the camera on the device.';
                    Visible = CameraAvailable AND (HideActions = FALSE);

                    trigger OnAction()
                    begin
                        PurchDocFunc.TakeNewPicture(Rec."Document Type", Rec."No.");
                    end;
                }
                action(ImportPicture)
                {
                    ApplicationArea = All;
                    Caption = 'Import';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Import a picture file.';
                    Visible = HideActions = FALSE;

                    trigger OnAction()
                    var
                        PicInStream: InStream;
                        FromFileName: Text;
                    begin
                        PurchDocFunc.ImportFromDevice(PicInStream, FromFileName);
                    end;
                }
                action(ExportFile)
                {
                    ApplicationArea = All;
                    Caption = 'Export';
                    Enabled = DeleteExportEnabled;
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Export the picture to a file.';
                    Visible = HideActions = FALSE;

                    trigger OnAction()
                    var
                        //FileManagement: Codeunit "File Management";
                        PicOutStream: OutStream;
                        ToFileName: Text;
                    begin
                        //FileManagement.BLOBExport(Rec.Picture, Name, true);
                        PurchDocFunc.ExportToDevice();
                    end;
                }
                action(DeletePicture)
                {
                    ApplicationArea = All;
                    Caption = 'Delete';
                    Enabled = DeleteExportEnabled;
                    Image = Delete;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Delete the record.';
                    Visible = HideActions = FALSE;

                    trigger OnAction()
                    begin
                        PurchDocFunc.DeleteItemPicture();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetEditableOnPictureActions();
    end;

    trigger OnOpenPage()
    begin
        CameraAvailable := Camera.IsAvailable();
    end;

    var
        Camera: Codeunit Camera;
        PurchDocFunc: Codeunit "Purchase Document Functions";
        //[InDataSet]
        CameraAvailable: Boolean;
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;

    local procedure SetEditableOnPictureActions()
    begin
        DeleteExportEnabled := Rec.Picture.Count <> 0;
    end;

    procedure IsCameraAvailable(): Boolean
    begin
        exit(Camera.IsAvailable());
    end;

    procedure SetHideActions()
    begin
        HideActions := true;
    end;
}