namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;
using Microsoft.Purchases.History;
using Microsoft.Inventory.Posting;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Inventory.Journal;
using Microsoft.Finance.Currency;
using Microsoft.Inventory.Costing;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Tracking;
using Microsoft.Inventory.Ledger;
using Microsoft.Purchases.Document;


codeunit 91002 "IT4G-Charge Assigment"
{
    Permissions = TableData "Purch. Inv. Line" = RIMD;
    PROCEDURE PostPendingItemChargeLine(PendingAssignment: Record "Pending Item Charge Assignment"; xDate: Date);
    VAR
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        //ItemChargeAssgntPurch: Record "Item Charge Assignment P.Purch";
        ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)";
        PostedItemChargeAssgnt: Record "Post.ItemChargeAssig. RCGRBASE";
    BEGIN
        GLSetup.GET;
        //TODO Check
        PendingAssignment.CALCFIELDS("Qty. to Assign");
        //IF PendingAssignment."Qty. to Assign"<>PendingAssignment.Quantity THEN
        //ERROR(QtyNotAssignedErr,PendingAssignment.Quantity,PendingAssignment."Qty. to Assign");
        PendingAssignment.TESTFIELD("Qty. to Assign", PendingAssignment.Quantity);
        PendingAssignment.TESTFIELD("GR Cancelled", FALSE);

        ItemChargeAssgntPurch.RESET;
        ItemChargeAssgntPurch.SETRANGE("Document Type", PendingAssignment."Document Type");
        ItemChargeAssgntPurch.SETRANGE("Document No.", PendingAssignment."Document No.");
        ItemChargeAssgntPurch.SETRANGE("Document Line No.", PendingAssignment."Document Line No.");
        ItemChargeAssgntPurch.SETFILTER("Qty. to Assign", '<>0');
        IF ItemChargeAssgntPurch.ISEMPTY THEN
            EXIT;

        //ReverseAmount
        if PendingAssignment."Document Type" = PendingAssignment."Document Type"::"Posted Credit Memo" then
            PendingAssignment.Amount := -PendingAssignment.Amount;

        IF ItemChargeAssgntPurch.FINDSET THEN
            REPEAT
                CASE ItemChargeAssgntPurch."Applies-to Doc. Type" OF
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::Receipt:
                        BEGIN
                            PostItemChargePerRcpt(ItemChargeAssgntPurch, PendingAssignment, xDate);
                        END;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Transfer Receipt":
                        BEGIN
                            Error('Not Supported');
                            //PostItemChargePerTransfer(PurchHeader,PurchaseLineBackup);
                        END;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Shipment":
                        BEGIN
                            PostItemChargePerRetShpt(ItemChargeAssgntPurch, PendingAssignment, xDate);
                        END;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Sales Shipment":
                        BEGIN
                            Error('Not Supported');
                            //PostItemChargePerSalesShpt(PurchHeader,PurchaseLineBackup);
                        END;
                    ItemChargeAssgntPurch."Applies-to Doc. Type"::"Return Receipt":
                        BEGIN
                            Error('Not Supported');
                            //PostItemChargePerRetRcpt(PurchHeader,PurchaseLineBackup);
                        END;
                END;
            UNTIL ItemChargeAssgntPurch.NEXT = 0;

        //Update Posted Document
        IF PendingAssignment."Document Type" = PendingAssignment."Document Type"::"Posted Invoice" THEN BEGIN
            PurchInvLine.GET(PendingAssignment."Document No.", PendingAssignment."Document Line No.");
            PurchInvLine."Item Charge Not Assigned" := FALSE;
            PurchInvLine.MODIFY;
        END ELSE
            IF PendingAssignment."Document Type" = PendingAssignment."Document Type"::"Posted Credit Memo" THEN BEGIN
                PurchCrMemoLine.GET(PendingAssignment."Document No.", PendingAssignment."Document Line No.");
                PurchCrMemoLine."Item Charge Not Assigned" := FALSE;
                PurchCrMemoLine.MODIFY;
            END;

        //Move Item Charge Assignment To Posted
        IF ItemChargeAssgntPurch.FINDSET THEN
            REPEAT
                PostedItemChargeAssgnt.INIT;
                PostedItemChargeAssgnt.TransferFields(ItemChargeAssgntPurch);
                PostedItemChargeAssgnt."Applies-to Doc. Type" := Enum::"Post.ItemChargeAssig. Applies-to Doc. Type RCGRBASE".FromInteger(ItemChargeAssgntPurch."Applies-to Doc. Type".AsInteger());

                IF PendingAssignment."Document Type" = PendingAssignment."Document Type"::"Posted Invoice" THEN
                    PostedItemChargeAssgnt."Table ID" := DATABASE::"Purch. Inv. Line"
                ELSE
                    IF PendingAssignment."Document Type" = PendingAssignment."Document Type"::"Posted Credit Memo" THEN
                        PostedItemChargeAssgnt."Table ID" := DATABASE::"Purch. Cr. Memo Line";
                PostedItemChargeAssgnt.INSERT;
            UNTIL ItemChargeAssgntPurch.NEXT = 0;


        ItemChargeAssgntPurch.SETRANGE("Qty. to Assign");
        ItemChargeAssgntPurch.DELETEALL;

        //Delete Pending Assignment
        PendingAssignment.DELETE;

    END;


    LOCAL PROCEDURE PostItemChargePerRcpt(ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; PendingAssign: Record "Pending Item Charge Assignment"; xDate: Date);
    VAR
        PurchRcptLine: Record "Purch. Rcpt. Line";
        TempItemLedgEntry: Record "Item Ledger Entry" TEMPORARY;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Sign: Decimal;
        DistributeCharge: Boolean;
        ReceiptLinesDeletedErr: Label 'Receipt lines have been deleted.';
    BEGIN
        IF NOT PurchRcptLine.GET(
             ItemChargeAssgntPurch."Applies-to Doc. No.", ItemChargeAssgntPurch."Applies-to Doc. Line No.")
        THEN
            ERROR(ReceiptLinesDeletedErr);

        Sign := GetSign(PurchRcptLine."Quantity (Base)");

        IF PurchRcptLine."Item Rcpt. Entry No." <> 0 THEN
            DistributeCharge :=
              CostCalcMgt.SplitItemLedgerEntriesExist(
                TempItemLedgEntry, PurchRcptLine."Quantity (Base)", PurchRcptLine."Item Rcpt. Entry No.")
        ELSE BEGIN
            DistributeCharge := TRUE;
            ItemTrackingMgt.CollectItemEntryRelation(TempItemLedgEntry,
              DATABASE::"Purch. Rcpt. Line", 0, PurchRcptLine."Document No.",
              '', 0, PurchRcptLine."Line No.", PurchRcptLine."Quantity (Base)");
        END;

        IF DistributeCharge THEN
            PostDistributeItemCharge(
              PendingAssign, ItemChargeAssgntPurch, TempItemLedgEntry, PurchRcptLine."Quantity (Base)",
              ItemChargeAssgntPurch."Qty. to Assign", ItemChargeAssgntPurch."Amount to Assign",
              Sign, PurchRcptLine."Indirect Cost %", xDate)
        ELSE
            PostItemCharge(PendingAssign, ItemChargeAssgntPurch,
              PurchRcptLine."Item Rcpt. Entry No.", PurchRcptLine."Quantity (Base)",
              ItemChargeAssgntPurch."Amount to Assign" * Sign,
              ItemChargeAssgntPurch."Qty. to Assign",
              PurchRcptLine."Indirect Cost %", xDate);
    END;

    LOCAL PROCEDURE PostItemChargePerRetShpt(ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; PendingAssign: Record "Pending Item Charge Assignment"; xDate: Date);
    VAR
        ReturnShptLine: Record "Return Shipment Line";
        TempItemLedgEntry: Record "Item Ledger Entry" TEMPORARY;
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        Sign: Decimal;
        DistributeCharge: Boolean;
    BEGIN
        ReturnShptLine.GET(
          ItemChargeAssgntPurch."Applies-to Doc. No.", ItemChargeAssgntPurch."Applies-to Doc. Line No.");
        ReturnShptLine.TESTFIELD("Job No.", '');

        Sign := GetSign(PendingAssign.Amount);
        IF PendingAssign."Document Type" = PendingAssign."Document Type"::"Posted Credit Memo" THEN
            Sign := -Sign;

        IF ReturnShptLine."Item Shpt. Entry No." <> 0 THEN
            DistributeCharge :=
              CostCalcMgt.SplitItemLedgerEntriesExist(
                TempItemLedgEntry, -ReturnShptLine."Quantity (Base)", ReturnShptLine."Item Shpt. Entry No.")
        ELSE BEGIN
            DistributeCharge := TRUE;
            ItemTrackingMgt.CollectItemEntryRelation(TempItemLedgEntry,
              DATABASE::"Return Shipment Line", 0, ReturnShptLine."Document No.",
              '', 0, ReturnShptLine."Line No.", ReturnShptLine."Quantity (Base)");
        END;

        IF DistributeCharge THEN
            PostDistributeItemCharge(
              PendingAssign, ItemChargeAssgntPurch, TempItemLedgEntry, -ReturnShptLine."Quantity (Base)",
              ItemChargeAssgntPurch."Qty. to Assign", ABS(ItemChargeAssgntPurch."Amount to Assign"),
              Sign, ReturnShptLine."Indirect Cost %", xDate)
        ELSE
            PostItemCharge(PendingAssign, ItemChargeAssgntPurch,
              ReturnShptLine."Item Shpt. Entry No.", -ReturnShptLine."Quantity (Base)",
              ABS(ItemChargeAssgntPurch."Amount to Assign") * Sign,
              ItemChargeAssgntPurch."Qty. to Assign",
              ReturnShptLine."Indirect Cost %", xDate);

    END;

    LOCAL PROCEDURE PostItemCharge(PendingAssign: Record "Pending Item Charge Assignment"; ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; ItemEntryNo: Integer; QuantityBase: Decimal; AmountToAssign: Decimal; QtyToAssign: Decimal; IndirectCostPct: Decimal; xDate: Date);
    VAR
        DummyTrackingSpecification: Record "Tracking Specification";
        PurchLineToPost: Record "Purchase Line";
        CurrExchRate: Record "Currency Exchange Rate";
        TotalChargeAmt: Decimal;
        TotalChargeAmtLCY: Decimal;
        ItemJnlLine: Record "Item Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Currency: Record Currency;
        PricesInclVAT: Boolean;
        InvDiscAmt: Decimal;
        LineDiscAmt: Decimal;
        LineAmt: Decimal;
        VATPrc: Decimal;
        CurrencyFactor: Decimal;
        DimSetID: ARRAY[10] OF Integer;
        ItemLedgEntry: Record "Item Ledger Entry";
        cERG: Codeunit "Delayed Item Charge Assignment";
    BEGIN
        //WITH TempItemChargeAssgntPurch DO BEGIN

        SourceCodeSetup.GET;

        CLEAR(ItemJnlLine);

        ItemJnlLineCopyfromPostedDoc(ItemJnlLine, PendingAssign, InvDiscAmt, LineDiscAmt, LineAmt, VATPrc, PricesInclVAT, CurrencyFactor);

        ItemJnlLine."Source Code" := SourceCodeSetup.Purchases;
        ItemJnlLine."Item No." := ItemChargeAssgntPurch."Item No.";
        ItemJnlLine."Applies-to Entry" := ItemEntryNo;
        ItemJnlLine."Indirect Cost %" := IndirectCostPct;
        ItemJnlLine."Document Line No." := ItemChargeAssgntPurch."Document Line No.";


        ItemJnlLine.Amount := AmountToAssign;
        IF PendingAssign."Document Type" = PendingAssign."Document Type"::"Posted Credit Memo" THEN
            ItemJnlLine.Amount := -ItemJnlLine.Amount;

        IF ItemJnlLine."Source Currency Code" <> '' THEN
            Currency.GET(ItemJnlLine."Source Currency Code");

        IF ItemJnlLine."Source Currency Code" <> '' THEN
            ItemJnlLine."Unit Cost (ACY)" := ROUND(
                ItemJnlLine.Amount / QuantityBase, Currency."Unit-Amount Rounding Precision")
        ELSE
            ItemJnlLine."Unit Cost (ACY)" := ROUND(
                ItemJnlLine.Amount / QuantityBase, GLSetup."Unit-Amount Rounding Precision");

        TotalChargeAmt := TotalChargeAmt + ItemJnlLine.Amount;
        IF ItemJnlLine."Source Currency Code" <> '' THEN
            ItemJnlLine.Amount :=
              CurrExchRate.ExchangeAmtFCYToLCY(
                PendingAssign."Posting Date", ItemJnlLine."Source Currency Code", TotalChargeAmt, CurrencyFactor);

        ItemJnlLine.Amount := ROUND(ItemJnlLine.Amount, GLSetup."Amount Rounding Precision") - TotalChargeAmtLCY;
        IF ItemJnlLine."Source Currency Code" <> '' THEN
            TotalChargeAmtLCY := TotalChargeAmtLCY + PurchLineToPost.Amount;
        ItemJnlLine."Unit Cost" :=
          ROUND(
            ItemJnlLine.Amount / QuantityBase, GLSetup."Unit-Amount Rounding Precision");

        InvDiscAmt := ROUND(
            InvDiscAmt / QuantityBase * QtyToAssign,
            GLSetup."Amount Rounding Precision");

        LineDiscAmt := ROUND(
            LineDiscAmt / QuantityBase * QtyToAssign,
            GLSetup."Amount Rounding Precision");

        LineAmt := ROUND(
            LineAmt / QuantityBase * QtyToAssign,
            GLSetup."Amount Rounding Precision");

        //Update Dimension Set ID from Applied Entry
        DimSetID[1] := ItemJnlLine."Dimension Set ID";
        IF ItemJnlLine."Applies-to Entry" <> 0 THEN BEGIN
            ItemLedgEntry.GET(ItemJnlLine."Applies-to Entry");
            DimSetID[2] := ItemLedgEntry."Dimension Set ID";
        END;
        ItemJnlLine."Dimension Set ID" :=
          DimensionMgt.GetCombinedDimensionSetID(DimSetID, ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code");



        //--------------------------
        ItemJnlLine."Invoice No." := PendingAssign."Document No.";

        //CopyTrackingFromSpec(TrackingSpecification);
        ItemJnlLine."Item Shpt. Entry No." := ItemEntryNo;

        //GR New +

        //GR New -

        ItemJnlLine.Quantity := 0;
        ItemJnlLine."Quantity (Base)" := 0;

        ItemJnlLine."Invoiced Quantity" := QuantityBase;
        ItemJnlLine."Invoiced Qty. (Base)" := QuantityBase;

        //IF ItemChargeNo <> '' THEN BEGIN
        ItemJnlLine."Item Charge No." := ItemChargeAssgntPurch."Item Charge No.";
        //PurchLine."Qty. to Invoice" := QtyToBeInvoiced;
        //END;


        ItemJnlLine.Amount := ItemJnlLine.Amount + RemAmt;
        IF PricesInclVAT THEN
            ItemJnlLine."Discount Amount" :=
              (LineDiscAmt + InvDiscAmt) /
              (1 + VATPrc / 100) + RemDiscAmt
        ELSE
            ItemJnlLine."Discount Amount" :=
              (LineDiscAmt + InvDiscAmt) + RemDiscAmt;
        RemAmt := ItemJnlLine.Amount - ROUND(ItemJnlLine.Amount);
        RemDiscAmt := ItemJnlLine."Discount Amount" - ROUND(ItemJnlLine."Discount Amount");
        ItemJnlLine.Amount := ROUND(ItemJnlLine.Amount);
        ItemJnlLine."Discount Amount" := ROUND(ItemJnlLine."Discount Amount");

        //--------------------------





        //PurchLine."Inv. Discount Amount" := PurchLine."Inv. Discount Amount" - PurchLineToPost."Inv. Discount Amount";
        //PurchLine."Line Discount Amount" := PurchLine."Line Discount Amount" - PurchLineToPost."Line Discount Amount";
        //PurchLine."Line Amount" := PurchLine."Line Amount" - PurchLineToPost."Line Amount";
        //PurchLine.Quantity := PurchLine.Quantity - QtyToAssign;
        if xDate <> 0D then
            ItemJnlLine."Posting Date" := xDate;
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    END;

    LOCAL PROCEDURE ItemJnlLineCopyfromPostedDoc(VAR ItemJnlLine: Record "Item Journal Line"; PendingAssignment: Record "Pending Item Charge Assignment"; VAR InvDiscAmt: Decimal; VAR LineDiscAmt: Decimal; VAR LineAmt: Decimal; VAR VATPrc: Decimal; VAR PricesInclVAT: Boolean; VAR CurrencyFactor: Decimal);
    VAR
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
    BEGIN
        CASE PendingAssignment."Document Type" OF
            PendingAssignment."Document Type"::"Posted Invoice":
                BEGIN
                    PurchInvHeader.GET(PendingAssignment."Document No.");
                    PurchInvLine.GET(PendingAssignment."Document No.", PendingAssignment."Document Line No.");

                    PricesInclVAT := PurchInvHeader."Prices Including VAT";
                    VATPrc := PurchInvLine."VAT %";
                    InvDiscAmt := PurchInvLine."Inv. Discount Amount";
                    LineDiscAmt := PurchInvLine."Line Discount Amount";
                    LineAmt := PurchInvLine."Line Amount";
                    CurrencyFactor := PurchInvHeader."Currency Factor";

                    //Document fields
                    ItemJnlLine."Document Type" := ItemJnlLine."Document Type"::"Purchase Invoice";
                    ItemJnlLine."Document No." := PendingAssignment."Document No.";
                    ItemJnlLine."External Document No." := PurchInvHeader."Vendor Invoice No.";
                    //TODO "Source Code" := SourceCode;
                    IF PurchInvHeader."No. Series" <> '' THEN
                        ItemJnlLine."Posting No. Series" := PurchInvHeader."No. Series";

                    //from header
                    ItemJnlLine."Posting Date" := PurchInvHeader."Posting Date";
                    ItemJnlLine."Document Date" := PurchInvHeader."Document Date";
                    ItemJnlLine."Source Posting Group" := PurchInvHeader."Vendor Posting Group";
                    ItemJnlLine."Salespers./Purch. Code" := PurchInvHeader."Purchaser Code";
                    ItemJnlLine."Country/Region Code" := PurchInvHeader."Buy-from Country/Region Code";
                    ItemJnlLine."Reason Code" := PurchInvHeader."Reason Code";
                    ItemJnlLine."Source Currency Code" := PurchInvHeader."Currency Code";
                    ItemJnlLine."Import File ID RCGRBASE" := PurchInvHeader."Import File ID RCGRBASE";
                    ItemJnlLine."Cancellation Type RCGRBASE" := PurchInvHeader."Cancellation Type RCGRBASE";
                    ItemJnlLine."Cancel No. RCGRBASE" := PurchInvHeader."Cancel No. RCGRBASE";

                    //from line
                    //"Item No." := PurchInvLine."No.";
                    ItemJnlLine.Description := PurchInvLine.Description;
                    ItemJnlLine."Shortcut Dimension 1 Code" := PurchInvLine."Shortcut Dimension 1 Code";
                    ItemJnlLine."Shortcut Dimension 2 Code" := PurchInvLine."Shortcut Dimension 2 Code";
                    ItemJnlLine."Dimension Set ID" := PurchInvLine."Dimension Set ID";
                    ItemJnlLine."Location Code" := PurchInvLine."Location Code";
                    ItemJnlLine."Bin Code" := PurchInvLine."Bin Code";
                    //"Variant Code" := PurchInvLine."Variant Code";
                    ItemJnlLine."Item Category Code" := PurchInvLine."Item Category Code";
                    //ItemJnlLine."Product Group Code" := PurchInvLine."Product Group Code"; obsolete
                    ItemJnlLine."Inventory Posting Group" := PurchInvLine."Posting Group";
                    ItemJnlLine."Gen. Bus. Posting Group" := PurchInvLine."Gen. Bus. Posting Group";
                    ItemJnlLine."Gen. Prod. Posting Group" := PurchInvLine."Gen. Prod. Posting Group";
                    ItemJnlLine."Job No." := PurchInvLine."Job No.";
                    ItemJnlLine."Job Task No." := PurchInvLine."Job Task No.";
                    IF ItemJnlLine."Job No." <> '' THEN
                        ItemJnlLine."Job Purchase" := TRUE;
                    ItemJnlLine."Applies-to Entry" := PurchInvLine."Appl.-to Item Entry";
                    ItemJnlLine."Transaction Type" := PurchInvLine."Transaction Type";
                    ItemJnlLine."Transport Method" := PurchInvLine."Transport Method";
                    ItemJnlLine."Entry/Exit Point" := PurchInvLine."Entry Point";
                    ItemJnlLine.Area := PurchInvLine.Area;
                    ItemJnlLine."Transaction Specification" := PurchInvLine."Transaction Specification";
                    //"Drop Shipment" := PurchInvLine."Drop Shipment";
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Purchase;
                    IF PurchInvLine."Prod. Order No." <> '' THEN BEGIN
                        ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Production;
                        ItemJnlLine."Order No." := PurchInvLine."Prod. Order No.";
                        ItemJnlLine."Order Line No." := PurchInvLine."Prod. Order Line No.";
                    END;
                    ItemJnlLine."Unit of Measure Code" := PurchInvLine."Unit of Measure Code";
                    ItemJnlLine."Qty. per Unit of Measure" := PurchInvLine."Qty. per Unit of Measure";
                    //ItemJnlLine."Cross-Reference No." := PurchInvLine."Cross-Reference No."; //ERGRET.001 CM
                    ItemJnlLine."Item Reference No." := PurchCrMemoLine."Item Reference No."; //ERGRET.001
                    ItemJnlLine."Document Line No." := PurchInvLine."Line No.";
                    //"Unit Cost" := PurchInvLine."Unit Cost (LCY)";
                    //"Unit Cost (ACY)" := PurchInvLine."Unit Cost";
                    ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
                    ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Vendor;
                    ItemJnlLine."Source No." := PurchInvLine."Buy-from Vendor No.";
                    ItemJnlLine."Invoice-to Source No." := PurchInvLine."Pay-to Vendor No.";
                    ItemJnlLine."Purchasing Code" := PurchInvLine."Purchasing Code";
                    ItemJnlLine."Indirect Cost %" := PurchInvLine."Indirect Cost %";
                    ItemJnlLine."Overhead Rate" := PurchInvLine."Overhead Rate";
                    ItemJnlLine."Return Reason Code" := PurchInvLine."Return Reason Code";

                END;
            PendingAssignment."Document Type"::"Posted Credit Memo":
                BEGIN
                    PurchCrMemoHeader.GET(PendingAssignment."Document No.");
                    PurchCrMemoLine.GET(PendingAssignment."Document No.", PendingAssignment."Document Line No.");

                    PricesInclVAT := PurchCrMemoHeader."Prices Including VAT";
                    VATPrc := PurchCrMemoLine."VAT %";
                    InvDiscAmt := -PurchCrMemoLine."Inv. Discount Amount";
                    LineDiscAmt := -PurchCrMemoLine."Line Discount Amount";
                    LineAmt := -PurchCrMemoLine."Line Amount";
                    CurrencyFactor := PurchCrMemoHeader."Currency Factor";

                    //Document fields
                    ItemJnlLine."Document Type" := ItemJnlLine."Document Type"::"Purchase Credit Memo";
                    ItemJnlLine."Document No." := PendingAssignment."Document No.";
                    ItemJnlLine."External Document No." := PurchCrMemoHeader."Vendor Cr. Memo No.";
                    //TODO "Source Code" := SourceCode;
                    IF PurchCrMemoHeader."No. Series" <> '' THEN
                        ItemJnlLine."Posting No. Series" := PurchCrMemoHeader."No. Series";

                    //from header
                    ItemJnlLine."Posting Date" := PurchCrMemoHeader."Posting Date";
                    ItemJnlLine."Document Date" := PurchCrMemoHeader."Document Date";
                    ItemJnlLine."Source Posting Group" := PurchCrMemoHeader."Vendor Posting Group";
                    ItemJnlLine."Salespers./Purch. Code" := PurchCrMemoHeader."Purchaser Code";
                    ItemJnlLine."Country/Region Code" := PurchCrMemoHeader."Buy-from Country/Region Code";
                    ItemJnlLine."Reason Code" := PurchCrMemoHeader."Reason Code";
                    ItemJnlLine."Source Currency Code" := PurchCrMemoHeader."Currency Code";
                    ItemJnlLine."Import File ID RCGRBASE" := PurchCrMemoHeader."Import File ID RCGRBASE";
                    ItemJnlLine."Cancellation Type RCGRBASE" := PurchCrMemoHeader."Cancellation Type RCGRBASE";
                    ItemJnlLine."Cancel No. RCGRBASE" := PurchCrMemoHeader."Cancel No. RCGRBASE";

                    //from line
                    //"Item No." := PurchCrMemoLine."No.";
                    ItemJnlLine.Description := PurchCrMemoLine.Description;
                    ItemJnlLine."Shortcut Dimension 1 Code" := PurchCrMemoLine."Shortcut Dimension 1 Code";
                    ItemJnlLine."Shortcut Dimension 2 Code" := PurchCrMemoLine."Shortcut Dimension 2 Code";
                    ItemJnlLine."Dimension Set ID" := PurchCrMemoLine."Dimension Set ID";
                    ItemJnlLine."Location Code" := PurchCrMemoLine."Location Code";
                    ItemJnlLine."Bin Code" := PurchCrMemoLine."Bin Code";
                    //"Variant Code" := PurchCrMemoLine."Variant Code";
                    ItemJnlLine."Item Category Code" := PurchCrMemoLine."Item Category Code";
                    //ItemJnlLine."Product Group Code" := PurchCrMemoLine."Product Group Code"; Obsolete
                    ItemJnlLine."Inventory Posting Group" := PurchCrMemoLine."Posting Group";
                    ItemJnlLine."Gen. Bus. Posting Group" := PurchCrMemoLine."Gen. Bus. Posting Group";
                    ItemJnlLine."Gen. Prod. Posting Group" := PurchCrMemoLine."Gen. Prod. Posting Group";
                    ItemJnlLine."Job No." := PurchCrMemoLine."Job No.";
                    ItemJnlLine."Job Task No." := PurchCrMemoLine."Job Task No.";
                    IF ItemJnlLine."Job No." <> '' THEN
                        ItemJnlLine."Job Purchase" := TRUE;
                    ItemJnlLine."Applies-to Entry" := PurchCrMemoLine."Appl.-to Item Entry";
                    ItemJnlLine."Transaction Type" := PurchCrMemoLine."Transaction Type";
                    ItemJnlLine."Transport Method" := PurchCrMemoLine."Transport Method";
                    ItemJnlLine."Entry/Exit Point" := PurchCrMemoLine."Entry Point";
                    ItemJnlLine.Area := PurchCrMemoLine.Area;
                    ItemJnlLine."Transaction Specification" := PurchCrMemoLine."Transaction Specification";
                    //"Drop Shipment" := PurchLine."Drop Shipment";
                    ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::Purchase;
                    //IF PurchCrMemoLine."Prod. Order No." <> '' THEN BEGIN
                    //   "Order Type" := "Order Type"::Production;
                    //  "Order No." := PurchCrMemoLine."Prod. Order No.";
                    //"Order Line No." := PurchCrMemoLine.P;
                    //END;
                    ItemJnlLine."Unit of Measure Code" := PurchCrMemoLine."Unit of Measure Code";
                    ItemJnlLine."Qty. per Unit of Measure" := PurchCrMemoLine."Qty. per Unit of Measure";
                    //ItemJnlLine."Cross-Reference No." := PurchCrMemoLine."Cross-Reference No."; ERGRET.001 - CM
                    ItemJnlLine."Item Reference No." := PurchCrMemoLine."Item Reference No."; //ERGRET.001
                    ItemJnlLine."Document Line No." := PurchCrMemoLine."Line No.";
                    //"Unit Cost" := PurchCrMemoLine."Unit Cost (LCY)";
                    //"Unit Cost (ACY)" := PurchCrMemoLine."Unit Cost";
                    ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
                    ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Vendor;
                    ItemJnlLine."Source No." := PurchCrMemoLine."Buy-from Vendor No.";
                    ItemJnlLine."Invoice-to Source No." := PurchCrMemoLine."Pay-to Vendor No.";
                    ItemJnlLine."Purchasing Code" := PurchCrMemoLine."Purchasing Code";
                    ItemJnlLine."Indirect Cost %" := PurchCrMemoLine."Indirect Cost %";
                    //"Overhead Rate" := PurchCrMemoLine."Overhead Rate";
                    ItemJnlLine."Return Reason Code" := PurchCrMemoLine."Return Reason Code";
                END;
        END;
    END;

    LOCAL PROCEDURE PostDistributeItemCharge(PendingAssign: Record "Pending Item Charge Assignment"; ItemChargeAssgntPurch: Record "Item Charge Assignment (Purch)"; VAR TempItemLedgEntry: Record "Item Ledger Entry" TEMPORARY; NonDistrQuantity: Decimal; NonDistrQtyToAssign: Decimal; NonDistrAmountToAssign: Decimal; Sign: Decimal; IndirectCostPct: Decimal; xDate: Date);
    VAR
        Factor: Decimal;
        QtyToAssign: Decimal;
        AmountToAssign: Decimal;
    BEGIN
        IF TempItemLedgEntry.FINDSET THEN BEGIN
            REPEAT
                Factor := TempItemLedgEntry.Quantity / NonDistrQuantity;
                QtyToAssign := NonDistrQtyToAssign * Factor;
                AmountToAssign := ROUND(NonDistrAmountToAssign * Factor, GLSetup."Amount Rounding Precision");
                IF Factor < 1 THEN BEGIN
                    PostItemCharge(PendingAssign, ItemChargeAssgntPurch,
                      TempItemLedgEntry."Entry No.", TempItemLedgEntry.Quantity,
                      AmountToAssign * Sign, QtyToAssign, IndirectCostPct, xDate);
                    NonDistrQuantity := NonDistrQuantity - TempItemLedgEntry.Quantity;
                    NonDistrQtyToAssign := NonDistrQtyToAssign - QtyToAssign;
                    NonDistrAmountToAssign := NonDistrAmountToAssign - AmountToAssign;
                END ELSE // the last time
                    PostItemCharge(PendingAssign, ItemChargeAssgntPurch,
                      TempItemLedgEntry."Entry No.", TempItemLedgEntry.Quantity,
                      NonDistrAmountToAssign * Sign, NonDistrQtyToAssign, IndirectCostPct, xDate);
            UNTIL TempItemLedgEntry.NEXT = 0;
        END ELSE
            ERROR(RelatedItemLedgEntriesNotFoundErr)
    END;

    LOCAL PROCEDURE GetSign(Value: Decimal): Integer;
    BEGIN
        IF Value > 0 THEN
            EXIT(1);

        EXIT(-1);
    END;

    var
        GlobalSelection: Integer;
        DimensionMgt: Codeunit DimensionManagement;
        GLSetup: Record "General Ledger Setup";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        RemAmt: Decimal;
        RemDiscAmt: Decimal;
        RelatedItemLedgEntriesNotFoundErr: Label 'Related item ledger entries cannot be found.';
        QtyNotAssignedErr: Label 'You must assign all quantity in order to post. Quantity is %1. Qty. to Assign is %2.';

}
