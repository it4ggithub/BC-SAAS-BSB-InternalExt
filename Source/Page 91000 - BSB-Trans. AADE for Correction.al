page 91000 "BSB-Trans. AADE for Correction"
{
    ApplicationArea = All;
    Caption = 'BSB-Trans. AADE for Correction';
    PageType = List;
    SourceTable = "LSC Transaction Header";
    SourceTableView = where("Entry Status" = filter(" " | Posted), "Post Infocode" = filter(<> ''));
    UsageCategory = Administration;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Store No."; Rec."Store No.")
                {
                    ToolTip = 'Specifies the value of the Store No. field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ToolTip = 'Specifies the value of the POS Terminal No. field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ToolTip = 'Specifies the value of the Transaction No. field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Date"; Rec."Date")
                {
                    ToolTip = 'Specifies the value of the Date field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Post Series"; Rec."Post Series")
                {
                    ToolTip = 'Specifies the value of the Post Series field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Post Infocode"; Rec."Post Infocode")
                {
                    ToolTip = 'Specifies the value of the Post Infocode field.', Comment = '%';
                }
                field("Description"; xDocDescr)
                {
                    ToolTip = 'Specifies the description of the Post Infocode.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ToolTip = 'Specifies the value of the Net Amount field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ToolTip = 'Specifies the value of the VAT Amount field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("Gross Amount"; Rec."Gross Amount")
                {
                    ToolTip = 'Specifies the value of the Gross Amount field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }

                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field.', Comment = '%';
                    StyleExpr = xStyle;
                }
                field("VAT Bus.Posting Group"; Rec."VAT Bus.Posting Group")
                {
                    ToolTip = 'Specifies the value of the VAT Bus.Posting Group field.', Comment = '%';
                    StyleExpr = xStyle;
                }
                field("Posting Status"; Rec."Posting Status")
                {
                    ToolTip = 'Specifies the value of the Posting Status field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("myData Uid"; Rec."myData Uid")
                {
                    ToolTip = 'Specifies the value of the myData Uid field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("myData MarkId"; Rec."myData MarkId")
                {
                    ToolTip = 'Specifies the value of the myData MarkId field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
                field("myData Transaction Errors"; Rec."myData Transaction Errors")
                {
                    ToolTip = 'Specifies the value of the myData Transaction Errors field.', Comment = '%';
                    Editable = false;
                    StyleExpr = xStyle;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Send Electronic Invoice Manually")
            {
                ApplicationArea = All;
                Caption = 'Send Electronic Invoice Manually';
                Image = CoupledPurchaseInvoice;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = bAADEEnabled;
                trigger OnAction()
                var
                    TransactionHeader: Record "LSC Transaction Header";
                    ElectronicInvoicing: Codeunit "Electronic Invoicing";
                    rRec: Record "LSC Transaction Header";
                begin
                    CurrPage.SetSelectionFilter(rRec);
                    if rec.FindSet() then begin
                        repeat
                            TransactionHeader.Get(rRec."Store No.", rRec."POS Terminal No.", rRec."Transaction No.");
                            if not TransactionHeader."Sale Is Return Sale" then
                                ElectronicInvoicing.SendInvoice(TransactionHeader)
                            else
                                ElectronicInvoicing.SendCredit(TransactionHeader);
                        until rRec.Next() = 0;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        rinfo: Record "LSC Infocode";
    begin
        if rInfo.Get(Rec."Post Infocode") then
            xDocDescr := rInfo."Description"
        else
            xDocDescr := '';
        if Rec."myData MarkId" = 0 then begin
            xStyle := 'Unfavorable';
            bAADEEnabled := true;
        end else begin
            xStyle := '';
            bAADEEnabled := false;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec."myData MarkId" = 0 then begin
            bAADEEnabled := true;
        end else begin
            bAADEEnabled := false;
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec."myData MarkId" <> 0 then
            Error('The transaction cannot be modified as it allready send to myData. Please contact your administrator for more details.');
    end;

    var
        bAADEEnabled: Boolean;
        xDocDescr: Text;
        xStyle: Text;
}