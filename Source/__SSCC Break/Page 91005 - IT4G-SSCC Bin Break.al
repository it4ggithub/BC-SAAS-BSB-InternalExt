namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;
using Microsoft.Warehouse.Structure;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.Ledger;

page 91005 "IT4G-SSCC Bin break"
{
    ApplicationArea = All;
    Caption = 'IT4G-SSCC Bin break';
    PageType = List;
    SourceTable = "IT4G-SSCC Content";
    SourceTableTemporary = true;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(filter)
            {
                field("BinCode"; gBin)
                {
                    ToolTip = 'Specifies the value of the Bin Code field.', Comment = '%';
                    TableRelation = Bin."Code";
                }
            }
            repeater(General)
            {
                field("Bin Code"; Rec."Bin Code")
                {
                    ToolTip = 'Specifies the value of the Bin Code field.', Comment = '%';
                }
                field("SSCC No."; Rec."SSCC")
                {
                    ToolTip = 'Specifies the value of the SSCC No. field.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.';
                }
                field(Quantity; Rec.Inventory)
                {
                    ToolTip = 'Specifies the value of the Inventory field.';
                }
                field("SSCC Qty"; Rec."SSCC Qty")
                {
                    ToolTip = 'Specifies the value of the SSCC Qty field.';
                }
                field("Inventory Calc"; Rec."Inventory Calc")
                {
                    ToolTip = 'Specifies the value of the Inventory Calc. field.', Comment = '%';
                }
                field("SSCC Inv. Calc"; Rec."SSCC Inv. Calc")
                {
                    ToolTip = 'Specifies the value of the SSCC Inv. Calc field.', Comment = '%';
                }
                field("SSCC Qty Calc"; Rec."SSCC Qty Calc")
                {
                    ToolTip = 'Specifies the value of the SSCC Qty Calc field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                ToolTip = 'Refreshes the SSCC Bin break.';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                begin
                    rec.Copy(RefreshBin(gBin), true);
                    CurrPage.Update();
                end;
            }
        }
    }

    procedure RefreshBin(xBin: Code[20]) rC: Record "IT4G-SSCC Content" temporary;
    var
        rSSCCL: Record "SSCC Line";
        rWE: Record "Warehouse Entry";

    begin
        if rC.IsTemporary then rC.DeleteAll();

        clear(rSSCCL);

        if xbin <> '' then
            rWE.SetRange("Bin Code", xBin);

        if rWE.FindSet() then begin
            i := 0;
            t := rWE.Count();
            if GuiAllowed then dDLG.Open('Processing Warehouse Entry #1# of #2#', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if not rC.Get(rWE."Bin Code", '', rWE."Item No.", rWE."Variant Code") then begin
                    rC."Bin Code" := rWE."Bin Code";
                    rC.SSCC := '';
                    rC."Item No." := rWE."Item No.";
                    rC."Variant Code" := rWE."Variant Code";
                    rC.Inventory := rWE.Quantity;
                    rC."SSCC Qty" := 0;
                    rC.Insert();
                end else begin
                    rC.Inventory += rWE.Quantity;
                    rC.Modify();
                end;
            until rWE.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
        IF xBin <> '' THEN rSSCCL.SetRange("Bin Code", xBin);
        if rSSCCL.FindSet() then begin
            i := 0;
            t := rSSCCL.Count();
            if GuiAllowed then dDLG.Open('Processing SSCC Lines #1# of #2#', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if not rC.Get(rSSCCL."Bin Code", rSSCCL."SSCC No.", rSSCCL."Item No.", rSSCCL."Variant Code") then begin
                    rC."Bin Code" := rSSCCL."Bin Code";
                    rC.SSCC := rSSCCL."SSCC No.";
                    rC."Item No." := rSSCCL."Item No.";
                    rC."Variant Code" := rSSCCL."Variant Code";
                    rC.Inventory := 0;
                    rC."SSCC Qty" := rSSCCL.Quantity;
                    rC.Insert();
                end else begin
                    rC."SSCC Qty" += rSSCCL.Quantity;
                    rC.Modify();
                end;
            until rSSCCL.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
        rC.SetRange(Inventory, 0);
        rC.SetRange("SSCC Qty", 0);
        rC.DeleteAll();
        clear(rC);
    end;

    var
        gBin: Code[20];
        rBin: Record Bin;
        rBinC: Record "Bin Content";
        xLoc: Record Location;
        i, t : Integer;
        dDLG: Dialog;
}
