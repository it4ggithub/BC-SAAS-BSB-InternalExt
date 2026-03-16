namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;

using Microsoft.Inventory.Transfer;

page 91002 "IT4G-Posted Transfer Shipments"
{
    ApplicationArea = All;
    Caption = 'IT4G-Posted Transfer Shipments';
    PageType = List;
    SourceTable = "Transfer Shipment Header";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                    Editable = false;
                }
                field("No. Series"; Rec."No. Series")
                {
                    ToolTip = 'Specifies the value of the No. Series field.', Comment = '%';
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date for this document.';
                    Editable = false;
                }
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ToolTip = 'Specifies the code of the location that items are transferred from.';
                    Editable = false;
                }
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the name of the sender at the location that the items are transferred from.';
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ToolTip = 'Specifies the code of the location that the items are transferred to.';
                    Editable = false;
                }
                field("Transfer-to Name"; Rec."Transfer-to Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the name of the recipient at the location that the items are transferred to.';
                }
                field("Transfer Reason RCGRBASE"; Rec."Transfer Reason RCGRBASE")
                {
                    ToolTip = 'Specifies the value of the Transfer Reason field.', Comment = '%';
                }
                field("myData MarkId"; Rec."myData MarkId")
                {
                    ToolTip = 'Specifies the value of the myData MarkId field.', Comment = '%';
                    Editable = false;
                }
                field("myData Transaction Errors"; Rec."myData Transaction Errors")
                {
                    ToolTip = 'Specifies the value of the myData Transaction Errors field.', Comment = '%';
                    Editable = false;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                    Editable = false;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ToolTip = 'Specifies the delivery conditions of the related shipment, such as free on board (FOB).';
                    Editable = false;
                }
                field("Shipment Reason RCGRBASE"; Rec."Shipment Reason RCGRBASE")
                {
                    ToolTip = 'Specifies the value of the Shipment Reason field.', Comment = '%';
                    Editable = false;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the code for the shipping agent who is transporting the items.';
                    Editable = false;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ToolTip = 'Specifies the code for the service, such as a one-day delivery, that is offered by the shipping agent.';
                    Editable = false;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    TransferShipmentHeader: Record "Transfer Shipment Header";
                    ElectronicInvoicing: Codeunit "Electronic Invoicing";
                begin
                    if rec."myData MarkId" <> 0 then Error('Electronic Invoice has already been sent for this document.');
                    TransferShipmentHeader.Get(Rec."No.");
                    ElectronicInvoicing.SendTransfer(TransferShipmentHeader);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
