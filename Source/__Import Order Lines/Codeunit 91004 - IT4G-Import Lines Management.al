namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;
using System.IO;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using Microsoft.Inventory.Transfer;
using Microsoft.Inventory.Item;

codeunit 91004 "IT4G-Import lines Management"
{
    procedure ImportExcel(rRec: RecordId)
    var
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        FromFile: Text;
        excelRec: Variant;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FileName, SheetName : Text;
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        xDate: DateTime;
        xItem: Code[20];
        xBarcode: Text;
        xVariant: Code[20];
        xQty: Decimal;
        rL: Record "IT4G-Import Order Lines tmp";
        rTH: Record "Transfer Header";
        rSH: Record "Sales Header";
        rPH: Record "Purchase Header";
        bBarCode: Boolean;
        rI: Record Item;
        rIV: Record "Item Variant";
        rB: Record "LSC Barcodes";
    begin
        if rRec.TableNo in [Database::"Transfer Header", Database::"Sales Header", Database::"Purchase Header"] then begin

        end else
            error('Record variable expected');

        rL.DeleteAll();

        commit;

        UploadIntoStream('Import Excel...', '', '', FromFile, IStream);
        if FromFile <> '' then begin
            FileName := FileMgt.GetFileName(FromFile);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(IStream);
        end else
            Error('File not found ...');
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(IStream, SheetName);
        TempExcelBuffer.ReadSheet();

        RowNo := 0;
        ColNo := 0;
        MaxRowNo := 0;
        LineNo := 0;
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetCurrentKey("Column No.");
        if TempExcelBuffer.FindLast() then begin
            bBarCode := false;
            if TempExcelBuffer."Column No." > 3 then error('Excel file must have \a. 3 columns: Item No., Variant Code, Quantity \b. 2 Columns Barcode and Quantity');
            if TempExcelBuffer."Column No." = 2 then bBarCode := true;
            if TempExcelBuffer."Column No." = 3 then bBarCode := false;

        end;
        if TempExcelBuffer.FindLast() then begin
            MaxRowNo := TempExcelBuffer."Row No.";
        end;

        if GuiAllowed then dDLG.Open('Importing Excel Lines: #1#\Total: #2#', RowNo, MaxRowNo);

        for RowNo := 2 to MaxRowNo do begin
            if GuiAllowed then dDLG.Update();
            if bBarcode then begin
                xBarcode := GetValueAtCell(RowNo, 1, TempExcelBuffer);
                rB.Get(xBarcode);
                xItem := rB."Item No.";
                xVariant := rB."Variant Code";
                xQty := GetValueAtCell(RowNo, 2, TempExcelBuffer);
            end else begin
                xItem := GetValueAtCell(RowNo, 1, TempExcelBuffer);
                xVariant := GetValueAtCell(RowNo, 2, TempExcelBuffer);
                xQty := GetValueAtCell(RowNo, 3, TempExcelBuffer);
            end;

            if not rL.Get(xItem, xVariant) then begin
                clear(rL);
                rL."Item No." := xItem;
                rL."Variant Code" := xVariant;
                rL.Quantity := xQty;
                rL.Insert();
            end else begin
                rL.Quantity += xQty;
                rL.Modify();
            end;
        end;
        Case rRec.TableNo of
            Database::"Transfer Header":
                begin
                    rTH.get(rRec);
                    CreateTransferLine(rL, rTH);
                end;
            Database::"Sales Header":
                begin
                    rSH.get(rRec);
                    CreateSaleLine(rL, rSH);
                end;
            Database::"Purchase Header":
                begin
                    rPH.get(rRec);
                    CreatePurchaseLine(rL, rPH);
                end;
        End;
    end;

    procedure CreateTransferLine(var rL: Record "IT4G-Import Order Lines tmp"; rTH: Record "Transfer Header");
    var
        TransferLine: Record "Transfer Line";
        OldItemNo: Code[20];
        LineNo: Integer;
        ColLineNo: Integer;
    begin
        if rTH.Status = rTH.Status::Released then Error('Transfer Order is released. Please change status to create lines.');
        rTH.SetHideValidationDialog(true);
        TransferLine.SetRange("Document No.", rTH."No.");
        if not TransferLine.IsEmpty() then
            error('Transfer Lines already exist for this Transfer Order.');
        if rL.Findset() then begin
            t := rL.Count();
            i := 0;
            dDLG.Open('Creating Transfer Lines... #1# of #2#', i, t);
            repeat
                i += 1;
                dDLG.Update();
                If OldItemNo <> rL."Item No." then begin
                    ColLineNo += 10000;
                    LineNo := ColLineNo;
                    TransferLine.Init();
                    TransferLine."Document No." := rTH."No.";
                    TransferLine."Line No." := ColLineNo;
                    TransferLine.Validate("Item No.", rL."Item No.");
                    TransferLine."ERG Collection Item No." := rL."Item No.";
                    TransferLine.Insert();
                end;
                TransferLine.INIT;
                LineNo += 10;
                TransferLine."Document No." := rTH."No.";
                TransferLine."Line No." := LineNo;
                TransferLine.INSERT();
                TransferLine."Variant Code" := '';
                TransferLine.Quantity := 0;
                TransferLine."ERG Collection Line No." := ColLineNo;
                TransferLine.VALIDATE("Item No.", rL."Item No.");
                TransferLine.VALIDATE("Variant Code", rL."Variant Code");
                TransferLine.VALIDATE(Quantity, rL.Quantity);
                TransferLine.Modify(true);
                OldItemNo := rL."Item No.";

            until rL.Next = 0;
            dDLG.Close();
        end;
    end;

    procedure CreateSaleLine(var rL: Record "IT4G-Import Order Lines tmp"; rSH: Record "Sales Header");
    var
        SalesLine: Record "Sales Line";
        OldItemNo: Code[20];
        LineNo: Integer;
        ColLineNo: Integer;
    begin
        if rSH.Status = rSH.Status::Released then Error(format(rSH."Document Type") + ' is released. Please change status to create lines.');
        rSH.SetHideValidationDialog(true);

        SalesLine.SetRange("Document Type", rSH."Document Type");
        SalesLine.SetRange("Document No.", rSH."No.");
        if not SalesLine.IsEmpty() then
            error('Sales Lines already exist for this ' + format(rSH."Document Type"));

        if rL.Findset() then begin
            t := rL.Count();
            i := 0;
            dDLG.Open('Creating Sale Lines... #1# of #2#', i, t);
            repeat
                i += 1;
                dDLG.Update();
                If OldItemNo <> rL."Item No." then begin
                    ColLineNo += 10000;
                    LineNo := ColLineNo;
                    SalesLine.init();
                    SalesLine."Document No." := rSH."No.";
                    SalesLine."Document Type" := rSH."Document Type";
                    SalesLine."Line No." := ColLineNo;
                    SalesLine.Validate(Type, SalesLine.Type::Item);
                    SalesLine.Validate("No.", rL."Item No.");
                    SalesLine.Type := SalesLine.Type::" ";
                    SalesLine."No." := '';
                    SalesLine."LSC Collection Item No." := rL."Item No.";
                    SalesLine."Starting Order" := rSH."Starting Order";
                    SalesLine.Validate("LSC Collection Item No.");
                    SalesLine.Insert(true);
                end;
                LineNo := LineNo + 10;
                SalesLine.INIT;
                SalesLine."Document No." := rSH."No.";
                SalesLine."Document Type" := rSH."Document Type";
                SalesLine."Line No." := LineNo;
                SalesLine."LSC Collection Line No." := ColLineNo;
                SalesLine.VALIDATE("Sell-to Customer No.", rSH."Sell-to Customer No.");
                SalesLine.Type := SalesLine.Type::Item;
                SalesLine.VALIDATE("No.", rL."Item No.");
                SalesLine.VALIDATE("Variant Code", rL."Variant Code");
                SalesLine.VALIDATE("Location Code", rSH."Location Code");
                SalesLine.Validate(Quantity, rL.Quantity);
                SalesLine.VALIDATE("Shipment Date");
                SalesLine."Planned Delivery Date" := rSH."Promised Delivery Date";
                SalesLine."Planned Shipment Date" := rSH."Shipment Date";
                SalesLine."Starting Order" := rSH."Starting Order";
                SalesLine.INSERT(TRUE);
            until rL.Next = 0;
            dDLG.Close();
        end;
    end;

    procedure CreatePurchaseLine(var rL: Record "IT4G-Import Order Lines tmp"; rPH: Record "Purchase Header");
    var
        PurchaseLine: Record "Purchase Line";
        OldItemNo: Code[20];
        LineNo: Integer;
        ColLineNo: Integer;
    begin
        /*
        if rL.Findset() then begin
            t := rL.Count();
            i := 0;
            dDLG.Open('Creating Purchase Lines... #1# of #2#', i, t);
            repeat
                i += 1;
                dDLG.Update();
                If OldItemNo <> rL."Item No." then begin
                    ColLineNo += 10000;
                    LineNo := ColLineNo;
                    PurchaseLine.Init();
                    PurchaseLine."Document No." := rPH."No.";
                    PurchaseLine."Line No." := ColLineNo;
                    PurchaseLine.Validate("Item No.", rL."Item No.");
                    PurchaseLine."ERG Collection Item No." := rL."Item No.";
                    PurchaseLine.Insert();
                end;
                PurchaseLine.INIT;
                LineNo += 10;
                PurchaseLine."Document No." := rPH."No.";
                PurchaseLine."Line No." := LineNo;
                PurchaseLine."Variant Code" := '';
                PurchaseLine.Quantity := 0;
                PurchaseLine."ERG Collection Line No." := ColLineNo;
                PurchaseLine.VALIDATE("Item No.", rL."Item No.");
                PurchaseLine.VALIDATE("Variant Code", rL."Variant Code");
                PurchaseLine.VALIDATE(Quantity, rL.Quantity);
                //PurchaseLine.Status := PurchaseLine.Status::Released;
                //PurchaseLine.Validate("Transfer-To Bin Code", BinTo); //TODOERG

                // IF not TransferH.GET(TransferHNo) THEN TransferH.Init();

                // if TransferH.Status = TransferH.Status::Released then begin
                //     TransferH.Status := TransferHeader.Status::Open;
                //     TransferH.MODIFY;
                // end;
                PurchaseLine.INSERT(TRUE);
                OldItemNo := rL."Item No.";
            until rL.Next = 0;
            dDLG.Close();
        end;
        */
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer; var TempExcelBuffer: Record "Excel Buffer" temporary) RetVal: Variant
    var
        xRetVal: Text;
        RetDec: Decimal;
        RetText: Text;
        RetDate: Date;
        RetTime: Time;
    begin

        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            xRetval := TempExcelBuffer."Cell Value as Text"
        else
            xRetVal := '';
        case TempExcelBuffer."Cell Type" of
            TempExcelBuffer."Cell Type"::Date:
                begin
                    Evaluate(RetDate, xRetVal);
                    retVal := RetDate;
                end;
            TempExcelBuffer."Cell Type"::Time:
                begin
                    Evaluate(RetTime, xRetVal);
                    retVal := RetTime;
                end;
            TempExcelBuffer."Cell Type"::Number:
                begin
                    Evaluate(RetDec, xRetVal);
                    retVal := RetDec;
                end;
            TempExcelBuffer."Cell Type"::Text:
                begin
                    RetText := xRetVal;
                    retVal := RetText;
                end;
        end;
    end;

    var
        i, t : Integer;
        dDLG: Dialog;

}
