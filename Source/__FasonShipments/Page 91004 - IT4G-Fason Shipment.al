namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;

using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Location;

page 91004 "IT4G-Fason Shipment"
{
    ApplicationArea = All;
    Caption = 'IT4G-Fason Shipment';
    PageType = List;
    SourceTable = "Transfer Line";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Fason)
            {
                field("Destination Location Code"; xLoc)
                {
                    ToolTip = 'Specifies the value of the Destination Location Code field.';
                    TableRelation = Location."Code";
                }
                field("No. of Orders"; rTHtmp.Count)
                {
                    ToolTip = 'Specifies the number of orders.';
                    Editable = false;
                }
                field("No. of Items"; gTotalQty)
                {
                    ToolTip = 'Specifies the number of items.';
                    Editable = false;
                }
            }
            repeater(General)
            {
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number that is associated with the line or entry.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item that will be transferred.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the entry.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ToolTip = 'Specifies information in addition to the description of the item being transferred.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of the item that will be processed as the document stipulates.';
                }
                field("Qty. to Ship"; Rec."Qty. to Ship")
                {
                    ToolTip = 'Specifies the quantity of items that remain to be shipped.';
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ToolTip = 'Specifies the quantity of items that remains to be received.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ToolTip = 'Specifies the value of the Prod. Order No. field.', Comment = '%';
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(RefreshList)
            {
                Caption = 'Refresh List';
                ToolTip = 'Refresh the list with the latest data.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    GetLines();
                    rec.calcsums(Quantity);

                    CurrPage.Update(false);
                end;
            }
            action(Post)
            {
                Caption = 'Create Mass Shipment';
                ToolTip = 'Create a mass shipment for the selected location.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    PostShipment(false);
                    CurrPage.Update(false);
                end;
            }
        }
    }
    procedure GetLines();
    var
        rTL: Record "Transfer Line";
    begin
        gTotalQty := 0;
        if Rec.IsTemporary then Rec.DeleteAll();
        if rTHtmp.isTemporary then rTHtmp.DeleteAll();

        clear(rTL);
        rTL.SetRange("Transfer-to Code", xLoc);
        rTL.SetRange("Quantity Shipped", 0);
        rTL.SetFilter("Qty. to Ship", '>0');
        if rTL.Findset then begin
            i := 0;
            t := rTL.Count();
            if GuiAllowed then dDLG.Open('Processing #1# of #2#', i, t);
            repeat
                rTHtmp."No." := rTL."Document No.";
                if rTHtmp.Insert() then;
                clear(Rec);
                Rec.TransferFields(rTL);
                Rec.Insert();
                gTotalQty += Rec.Quantity;
                i += 1;
                if GuiAllowed then dDLG.Update();
            until rTL.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
    end;

    procedure PostShipment(bDelete: Boolean);
    var
        rTHH: Record "Transfer Header";
        rTH: Record "Transfer Header";
        rTL: Record "Transfer Line";
        rTLdel: Record "Transfer Line";
        rTHdel: Record "Transfer Header";
        cPost: Codeunit "TransferOrder-Post Shipment";
        rSetUp: Record "IT4G-Invoicing Setup";
    begin
        If not Confirm(StrSubstNo('Create Massive shipment for location %1?', xLoc)) then exit;
        rTHtmp.FindFirst();
        rTHH.Get(rTHtmp."No.");

        rTH.Init;
        rTH.SetHideValidationDialog(true);
        rTH."No." := '';
        rTH.Insert(true);

        rTH.Validate("Transfer-from Code", rTHH."Transfer-from Code");
        rTH.Validate("Transfer-to Code", rTHH."Transfer-to Code");

        rTH.Validate("Posting Date", Today());
        rTH."Transfer Source Type" := rTHH."Transfer Source Type";
        rTH."Transfer Source No." := rTHH."Transfer Source No.";


        //rTH.Validate("Posting Document Code RCGRBASE", rSetUp."Posting Document Code");

        rTH.Modify(true);
        if rec.FindSet() then begin
            i := 0;
            t := rec.Count();
            if GuiAllowed then dDLG.Open('Creating Transfer Order ... #1############### Processing Lines #2 of #3', rTH."No.", i, t);
            repeat
                i += 100;
                if GuiAllowed then dDLG.Update();
                rTL.Init();
                rTL.TransferFields(Rec);
                rTL."Document No." := rTH."No.";
                rTL."Line No." := i;
                rTL.Insert(true);
                if bDelete then
                    if rTLdel.Get(rec."Document No.", rec."Line No.") then begin
                        rTLdel.Delete(true);
                    end;

            until rec.Next() = 0;
            if GuiAllowed() then dDLG.Close();
        end;

        if bDelete then
            if rTHH.findset then
                repeat
                    if rTHdel.Get(rTHH."No.") then begin
                        rTHdel.CalcFields("Shipped Qty");
                        if rTHdel."Shipped Qty" = 0 then rTHdel.Delete(true);
                    end;
                until rTHH.Next() = 0;

        commit;
        page.Run(Page::"Transfer Order", rTH);

        //Clear(cPost);
        //cPost.SetHideValidationDialog(true);
        //cPost.Run(rTH);

        //UpdateSSCCs(rInv);
        //rInv.Status := rInv.Status::Shipped;
        //rInv.modify;
        //commit;
    end;

    var
        xLoc: code[20];
        i, t : Integer;
        dDLG: Dialog;
        rTHtmp: Record "Transfer Header" temporary;
        gTotalQty: Decimal;
        xrma: Record "RMA Header";

}
