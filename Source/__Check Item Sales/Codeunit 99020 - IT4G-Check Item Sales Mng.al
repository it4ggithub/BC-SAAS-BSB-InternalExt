namespace BCSAASITGBSB.BCSAASITGBSB;
using Microsoft.Sales.Document;
using Microsoft.Warehouse.Activity.History;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Location;
using Microsoft.Warehouse.History;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Item;
using Microsoft.Sales.History;

codeunit 99020 "IT4G-Check Item Sales Mng"
{
    procedure CalcView(var rTempCheckItemSales: Record "IT4G-Check Item Sales"; xItemFilter: Text; xVariantFilter: Text)
    var
    begin

        if rSTA.FindSet() then
            repeat
                rSTAtmp.Init();
                rSTAtmp.TransferFields(rSTA);
                rSTAtmp.Insert();
            until rSTA.Next() = 0;
        if rS.FindSet() then
            repeat
                rSS.Init();
                rSS.TransferFields(rS);
                rSS.Insert();
                rSTA.SetRange("Store No.", rS."No.");
                if rSTA.FindFirst() then begin
                    rLL.Init();
                    rLL."Code" := rS."Location Code";
                    rLL."Customer No.  RCGRBASE" := rSTA."Customer No.";
                    rLL."LSC Customer No." := rSTA.Code;
                    if rLL.Insert() then;
                end;

            until rS.Next() = 0;

        clear(rTempCheckItemSales);
        if xItemFilter <> '' then
            rTempCheckItemSales.SetFilter("Item No.", xItemFilter);
        if xVariantFilter <> '' then
            rTempCheckItemSales.SetFilter("Variant Code", xVariantFilter);
        rTempCheckItemSales.DeleteAll();

        TempCheckItemSales.DeleteAll();

        CheckSalesLine(xItemFilter, xVariantFilter);
        CheckPickingLine(xItemFilter, xVariantFilter);
        CheckPackagingLine(xItemFilter, xVariantFilter);
        CheckTransferShipLines(xItemFilter, xVariantFilter);
        CheckSalesShipLines(xItemFilter, xVariantFilter);
        CheckWSLine(xItemFilter, xVariantFilter);

        i := 0;
        t := TempCheckItemSales.Count();
        dDLG.Open('Finalizing...|Processed #1###### of #2######', i, t);
        if TempCheckItemSales.FindSet() then
            repeat
                i += 1;
                dDLG.Update();
                rTempCheckItemSales.TransferFields(TempCheckItemSales);
                if rSTAtmp.Get(rTempCheckItemSales."Customer No.", rTempCheckItemSales."Customer Address") then begin
                    rTempCheckItemSales."Store No." := rSTAtmp."Store No.";
                    if rSS.Get(rTempCheckItemSales."Store No.") then
                        rTempCheckItemSales."Location Code" := rSS."Location Code";
                end;
                rTempCheckItemSales.Insert();
            until TempCheckItemSales.Next() = 0;
        dDLG.Close();
        exit;

    end;

    procedure CheckSalesLine(xItemFilter: Text; xVariantFilter: Text)
    var
        rSL: Record "Sales Line";
    begin
        begin
            t := 0;
            i := 0;
            rSL.Setfilter("Document Type", '%1|%2', rSL."Document Type"::"Blanket Order", rSL."Document Type"::"Order");
            if xItemFilter <> '' then
                rSL.SetFilter("No.", xItemFilter);
            if xVariantFilter <> '' then
                rSL.SetFilter("Variant Code", xVariantFilter);


            if rSL.FindSet() then begin
                t := rSL.Count();
                if GuiAllowed then dDLG.Open('Checking Sales Line...#1######## of #2########', i, t);
                repeat
                    i += 1;
                    if GuiAllowed then dDLG.Update();
                    if rSL.Type = rSL.Type::Item then
                        if rSL."No." <> '' then begin
                            if rSL."Document Type" = rSL."Document Type"::"Blanket Order" then
                                UpdateLine(rSL."Sell-to Customer No.", rSL."Ship-to Code RCGRBASE", rSL."No.", rSL."Variant Code", rSL."Quantity", 1);
                            if rSL."Document Type" = rSL."Document Type"::"Order" then
                                UpdateLine(rSL."Sell-to Customer No.", rSL."Ship-to Code RCGRBASE", rSL."No.", rSL."Variant Code", rSL."Quantity", 2);
                        end;
                until rSL.Next() = 0;
                if GuiAllowed then dDLG.Close();
            end;

        end;
    end;

    procedure CheckPickingLine(xItemFilter: Text; xVariantFilter: Text)
    var
        rSL: Record "Registered Whse. Activity Line";
        xCust, xShip : Code[20];
    begin
        t := 0;
        i := 0;
        if xItemFilter <> '' then
            rSL.SetFilter("Item No.", xItemFilter);
        if xVariantFilter <> '' then
            rSL.SetFilter("Variant Code", xVariantFilter);


        if rSL.FindSet() then begin
            t := rSL.Count();
            if GuiAllowed then dDLG.Open('Checking Sales Picking Lines...#1######## of #2########', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();

                if rSL."Destination Type" = rSL."Destination Type"::Customer then begin
                    xCust := rSL."Destination No.";
                    xShip := rSL."Destination-Ship to";
                end;

                if rSL."Destination Type" = rSL."Destination Type"::Location then begin
                    if rLL.Get(rSL."Destination No.") then begin
                        xCust := rLL."Customer No.  RCGRBASE";
                        xShip := rLL."LSC Customer No.";
                    end;
                end;

                if rSL."Action Type" = rSL."Action Type"::Take then begin
                    UpdateLine(xCust, xShip, rSL."Item No.", rSL."Variant Code", rSL.Quantity, 130);
                    if rSL."Scanned Qty." <> 0 then
                        UpdateLine(xCust, xShip, rSL."Item No.", rSL."Variant Code", rSL."Scanned Qty.", 132);
                end;

                if rSL."Action Type" = rSL."Action Type"::Place then begin
                    UpdateLine(xCust, xShip, rSL."Item No.", rSL."Variant Code", rSL.Quantity, 131);
                    if rSL."Scanned Qty." <> 0 then
                        UpdateLine(xCust, xShip, rSL."Item No.", rSL."Variant Code", rSL."Scanned Qty.", 133);
                end;

            until rSL.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
    end;

    procedure CheckSalesShipLines(xItemFilter: Text; xVariantFilter: Text)
    var
        rSL: Record "Sales Shipment Line";
    begin
        t := 0;
        i := 0;
        if xItemFilter <> '' then
            rSL.SetFilter("No.", xItemFilter);
        if xVariantFilter <> '' then
            rSL.SetFilter("Variant Code", xVariantFilter);


        if rSL.FindSet() then begin
            t := rSL.Count();
            if GuiAllowed then dDLG.Open('Checking Sales Shipments...#1######## of #2########', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if rSL.Type = rSL.Type::Item then
                    if rSL."No." <> '' then begin
                        UpdateLine(rSL."Sell-to Customer No.", rSL."Ship-to Code RCGRBASE", rSL."No.", rSL."Variant Code", rSL."Quantity", 3);
                    end;
            until rSL.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
    end;

    procedure CheckTransferShipLines(xItemFilter: Text; xVariantFilter: Text)
    var
        rTSL: Record "Transfer Shipment Line";
        rSTA: Record "Ship-to Address";
        LocFilter: Text;
        rS: Record "LSC Store";
    begin
        rSTA.SetRange("Type Of Replenishment ERG", rSTA."Type Of Replenishment ERG"::"Transfer Shipment");
        if rSTA.FindSet() then
            repeat
                rS.Get(rSTA."Store No.");
                if LocFilter = '' then
                    LocFilter := rS."Location Code"
                else
                    LocFilter += '|' + rS."Location Code";
            until rSTA.Next() = 0;


        rS.Get(rSTA."Store No.");
        rTSL.SetFilter("Transfer-from Code", '200');
        rTSL.SetFilter("Transfer-to Code", LocFilter);
        if xItemFilter <> '' then
            rTSL.SetFilter("Item No.", xItemFilter);
        if xVariantFilter <> '' then
            rTSL.SetFilter("Variant Code", xVariantFilter);

        i := 0;
        if rTSL.FindSet() then begin
            t := rTSL.Count();
            if GuiAllowed then dDLG.Open('Checking Transfer Shipment Line...#1######## of #2########', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                rLL.Get(rTSL."Transfer-to Code");
                if rTSL."Item No." <> '' then begin
                    UpdateLine(rLL."Customer No.  RCGRBASE", rLL."LSC Customer No.", rTSL."Item No.", rTSL."Variant Code", rTSL."Quantity", 3);
                end;
            until rTSL.Next() = 0;
        end;
        if GuiAllowed then dDLG.Close();
    end;

    procedure CheckPackagingLine(xItemFilter: Text; xVariantFilter: Text)
    var
        rSL: Record "Sub SSCC Line";
        rSH: Record "Sub SSCC Header";
        rHtmp: Record "Sub SSCC Header" temporary;
        xCustNo: Code[20];
        xCustAddress: Code[20];
        rSSH: Record "Sales Shipment Header";
        rTSH: Record "Transfer Shipment Header";
    begin
        t := 0;
        i := 0;
        If rSH.FindSet() then
            repeat
                if rSH."Status SSCC" in [rSH."Status SSCC"::Invoiced, rSH."Status SSCC"::Shipped] then begin
                    rHtmp.Init();
                    rHtmp.TransferFields(rSH);
                    if rHtmp."Posted Shipment Type" = rHtmp."Posted Shipment Type"::Sales then
                        if rSSH.Get(rSH."Posted Shipment No.") then begin
                            rHtmp."Source No." := rSSH."Sell-to Customer No.";
                            rHtmp."Ship To Code" := rSSH."Ship-to Code";
                        end;
                    if rHtmp."Posted Shipment Type" = rHtmp."Posted Shipment Type"::Transfer then
                        if rTSH.Get(rSH."Posted Shipment No.") then begin
                            if rLL.Get(rTSH."Transfer-to Code") then begin
                                rHtmp."Source No." := rLL."Customer No.  RCGRBASE";
                                rHtmp."Ship To Code" := rLL."LSC Customer No.";
                            end;
                        end;
                    if rHtmp.Insert() then;
                end;
            until rSH.Next() = 0;

        if xItemFilter <> '' then
            rSL.SetFilter("Item No.", xItemFilter);
        if xVariantFilter <> '' then
            rSL.SetFilter("Variant Code", xVariantFilter);

        if rSL.FindSet() then begin
            t := rSL.Count();
            if GuiAllowed then dDLG.Open('Checking Packaging Line...#1######## of #2########', i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if rHtmp.Get(rSL."Sub SSCC No.", rSL."SSCC No.") then
                    UpdateLine(rHtmp."Source No.", rHtmp."Ship To Code", rSL."Item No.", rSL."Variant Code", rSL."Quantity", 500);
            until rSL.Next() = 0;
            if GuiAllowed then dDLG.Close();
        end;
    end;

    procedure CheckWSLine(xItemFilter: Text; xVariantFilter: Text)
    var
        rSL: Record "Posted Whse. Shipment Line";
        rSH: Record "Posted Whse. Shipment Header";
    begin
        begin
            t := 0;
            i := 0;
            if xItemFilter <> '' then
                rSL.SetFilter("No.", xItemFilter);
            if xVariantFilter <> '' then
                rSL.SetFilter("Variant Code", xVariantFilter);


            if rSL.FindSet() then begin
                t := rSL.Count();
                if GuiAllowed then dDLG.Open('Checking Posted Warehouse Shipment Lines...#1######## of #2########', i, t);
                repeat
                    rSH.Get(rSL."No.");
                    i += 1;
                    if GuiAllowed then dDLG.Update();
                //UpdateLine(rSH.sou, rSL."Ship-to Code RCGRBASE", rSL."No.", rSL."Variant Code", rSL."Quantity", 600);
                until rSL.Next() = 0;
                if GuiAllowed then dDLG.Close();
            end;

        end;
    end;

    procedure UpdateLine(xCustNo: Code[20]; xCustAddress: Code[20]; xItemNo: Code[20]; xVariantCode: Code[20]; xQty: Decimal; xType: Integer)
    var
    begin
        if xItemNo = '' then exit;
        if xVariantCode = '' then exit;

        if TempCheckItemSales.Get(xItemNo, xVariantCode, xCustNo, xCustAddress) then begin
            UpdateLineQty(TempCheckItemSales, xQty, xType);
            TempCheckItemSales.Modify();
        end else begin
            clear(TempCheckItemSales);
            TempCheckItemSales."Item No." := xItemNo;
            TempCheckItemSales."Variant Code" := xVariantCode;
            TempCheckItemSales."Customer No." := xCustNo;
            TempCheckItemSales."Customer Address" := xCustAddress;
            UpdateLineQty(TempCheckItemSales, xQty, xType);
            TempCheckItemSales.Insert();
        end;
    end;

    procedure UpdateLineQty(var xTempCheckItemSales: Record "IT4G-Check Item Sales"; xQty: Decimal; xType: Integer)
    var
    begin
        case
            xType of
            1:
                xTempCheckItemSales."Qty on Blanket Order" += xQty;
            2:
                xTempCheckItemSales."Qty on Sales Order" += xQty;
            3:
                xTempCheckItemSales."Qty Shipped" += xQty;
            130:
                xTempCheckItemSales."Qty Picked Take" += xQty;
            131:
                xTempCheckItemSales."Qty Picked Place" += xQty;
            132:
                xTempCheckItemSales."Qty Picked Take Scanned" += xQty;
            133:
                xTempCheckItemSales."Qty Picked Place Scanned" += xQty;
            500:
                xTempCheckItemSales."Qty Packed SSCC" += xQty;
            600:
                xTempCheckItemSales."Qty Posted Warehouse" += xQty;
        end;
    end;

    Var
        i, t : Integer;
        dDLG: Dialog;
        TempCheckItemSales: Record "IT4G-Check Item Sales" temporary;
        RegisteredPickSubform: Page "Registered Pick Subform";
        rSTA: Record "Ship-to Address";
        rSTAtmp: Record "Ship-to Address" temporary;
        rI: Record Item;
        rS: Record "LSC Store";
        rSS: Record "LSC Store" temporary;
        rL: Record "Location";
        rLL: Record Location temporary;
}
