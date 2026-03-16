namespace BCSAASITGBSB.BCSAASITGBSB;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;

codeunit 91020 "IT4G-MissMach Doc Mng"
{
    procedure FindWrongDocumentRelations()
    var
        rCLE: Record "Cust. Ledger Entry";
        rCLEtmp: Record "Cust. Ledger Entry" temporary;
        rDCLE: Record "Detailed Cust. Ledg. Entry";
        rDCLEInit: Record "Detailed Cust. Ledg. Entry";

        rDCLEtmp: Record "Detailed Cust. Ledg. Entry" temporary;
    begin
        i := 0;
        t := 0;
        if rCLE.FindSet() then begin
            t := rCLE.Count();
            if GuiAllowed then dDLG.Open('Finding wrong document relations... #1############### #2###### of #3######', rCLE."Entry No.", i, t);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                rDCLE.SetRange("Cust. Ledger Entry No.", rCLE."Entry No.");
                if rDCLE.FindSet() then
                    repeat
                        //if (rDCLE."Customer No." <> rCLE."Customer No.") or (rDCLE."Ship-to Code" <> rCLE."Ship-to Code") then begin
                        clear(rCLEtmp);
                        rCLEtmp.TransferFields(rCLE);
                        if rCLEtmp.Insert() then;

                    /*
                    Clear(rDCLEtmp);
                    rDCLEtmp.TransferFields(rDCLE);
                    if rDCLEtmp.Insert() then;
                    rDCLEInit.SetRange("Cust. Ledger Entry No.", rCLE."Entry No.");
                    rDCLEInit.SetRange("Entry Type", rDCLE."Entry Type"::"Initial Entry");
                    if rDCLEInit.FindFirst() then begin
                        Clear(rCLEtmp);
                        rCLEtmp.TransferFields(rCLE);
                        if rCLEtmp.Insert() then;
                    end;
                    */
                    //end;
                    until rDCLE.next() = 0;

            until rCLE.Next() = 0;
            if GuiAllowed then dDLG.Close();

            if rCLEtmp.findset then begin
                i := 0;
                t := rCLE.Count();
                if GuiAllowed then dDLG.Open('Finalizing relations... #1############### #2 of #3', rCLEtmp."Document No.", i, t);
                repeat
                    i += 1;
                    if GuiAllowed then dDLG.Update();

                    clear(rDCLE);
                    rDCLE.SetRange("Cust. Ledger Entry No.", rCLEtmp."Entry No.");
                    if rDCLE.FindSet() then
                        repeat
                            Clear(rDCLEtmp);
                            rDCLEtmp.TransferFields(rDCLE);
                            if (rDCLE."Customer No." <> rCLEtmp."Customer No.") or (rDCLE."Ship-to Code" <> rCLEtmp."Ship-to Code") then begin
                                rDCLEtmp."Journal Batch Name" := 'WRONG';
                            end;
                            if rDCLEtmp.Insert() then;
                        until rDCLE.next() = 0;

                until rCLEtmp.Next() = 0;
                if GuiAllowed then dDLG.Close();

                page.Run(90014, rDCLEtmp);

            end;

        end;
    end;

    var
        i, t, iTSE, tTSE : Integer;
        dDLG: Dialog;
        rStore: Record "LSC Store";
        dDLGText: Text;


}
