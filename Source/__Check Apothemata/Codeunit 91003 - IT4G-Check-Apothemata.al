namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;
using Microsoft.Inventory.Ledger;
using Microsoft.Warehouse.Ledger;

codeunit 91003 "IT4G-Check Apothemata"
{
    procedure RefreshApothemata(rRec: record "IT4G-Check Apothemata")
    var

    begin
        rRec.Truncate();
        commit;
        CreateILEntry(rRec);
        CreateWHEntry(rRec);
        CreateSSCCEntry(rRec);
    end;

    Procedure CreateILEntry(rRec: record "IT4G-Check Apothemata")
    var
    begin
        rILE.SetCurrentKey("Item No.", "Variant Code");
        rILE.SetRange("Location Code", '200');
        if rILE.FindSet() then begin
            i := 0;
            t := rILE.Count();
            dDLG.Open('Item Ledger Entry #1 of #2', i, t);
            repeat
                i += 1;
                dDLG.Update();
                currKey := rILE."Item No." + rILE."Variant Code";
                if CurrKey <> oldKey then begin
                    if rRec."Variant Code" <> '' then rRec.Insert();
                    clear(rRec);
                    rRec.Type := rRec.Type::"Item Ledger Entry";
                    rRec.Location := rILE."Location Code";
                    rRec."Item No." := rILE."Item No.";
                    rRec."Variant Code" := rILE."Variant Code";
                end;
                rRec.Quantity += rILE.Quantity;

                oldKey := rILE."Item No." + rILE."Variant Code";
            until rILE.Next() = 0;
            if rRec."Variant Code" <> '' then rRec.Insert();
            dDLG.Close();
        end;
    end;

    Procedure CreateWHEntry(rRec: record "IT4G-Check Apothemata")
    var
    begin
        rWHE.SetCurrentKey("Bin Code", "Item No.", "Variant Code");
        rWHE.SetRange("Location Code", '200');
        if rWHE.FindSet() then begin
            i := 0;
            t := rWHE.Count();
            dDLG.Open('Warehouse Entry #1 of #2', i, t);
            repeat
                i += 1;
                dDLG.Update();
                currKey := rWHE."Bin Code" + rWHE."Item No." + rWHE."Variant Code";
                if CurrKey <> oldKey then begin
                    if rRec."Variant Code" <> '' then rRec.Insert();
                    clear(rRec);
                    rRec.Type := rRec.Type::"Warehouse Entry";
                    rRec.Location := rWHE."Location Code";
                    rRec.Bin := rWHE."Bin Code";
                    rRec."Item No." := rWHE."Item No.";
                    rRec."Variant Code" := rWHE."Variant Code";
                end;
                rRec.Quantity += rWHE.Quantity;

                oldKey := rWHE."Bin Code" + rWHE."Item No." + rWHE."Variant Code";
            until rWHE.Next() = 0;
            if rRec."Variant Code" <> '' then if rRec.Insert() then;
            dDLG.Close();
        end;

    end;

    Procedure CreateSSCCEntry(rRec: record "IT4G-Check Apothemata")
    var
    begin
        rSSCCL.SetCurrentKey("Sub SSCC No.", "Bin Code", "Item No.", "Variant Code");
        rSSCCL.SetRange("Location Code", '200');
        if rSSCCL.FindSet() then begin
            i := 0;
            t := rSSCCL.Count();
            dDLG.Open('SSCC Lines #1 of #2', i, t);
            repeat
                i += 1;
                dDLG.Update();
                currKey := rSSCCL."Sub SSCC No." + rSSCCL."Bin Code" + rSSCCL."Item No." + rSSCCL."Variant Code";
                if CurrKey <> oldKey then begin
                    if rRec."Variant Code" <> '' then rRec.Insert();
                    clear(rRec);
                    rRec.Type := rRec.Type::"SSCC";
                    rRec.Location := rSSCCL."Location Code";
                    rRec.SSCC := rSSCCL."Sub SSCC No.";
                    rRec.Bin := rSSCCL."Bin Code";
                    rRec."Item No." := rSSCCL."Item No.";
                    rRec."Variant Code" := rSSCCL."Variant Code";
                end;
                rRec.Quantity += rSSCCL.Quantity;

                oldKey := rSSCCL."Sub SSCC No." + rSSCCL."Bin Code" + rSSCCL."Item No." + rSSCCL."Variant Code";
            until rSSCCL.Next() = 0;
            if rRec."Variant Code" <> '' then if rRec.Insert() then;
            dDLG.Close();
        end;
    end;


    procedure CheckStatus(rRec: record "IT4G-Check Apothemata")
    begin
        if rRec.findset then begin
            i := 0;
            t := rRec.Count();
            dDLG.Open('Check Lines #1 of #2', i, t);
            repeat
                i += 1;
                dDLG.Update();
                rRec.Status := rRec.Status::Match;
                rRec."SSCC Mismatch" := false;
                rRec."Warehouse Mismatch" := false;

                case rRec.Type of
                    rRec.Type::"Item Ledger Entry":
                        begin
                            rRec.CalcFields(rRec."ILE Live", rRec."Warehouse Live", rRec."SSCC Live");
                            if rRec."ILE Live" <> rRec."Warehouse Live" then rRec."Warehouse Mismatch" := true;
                            if rRec."ILE Live" <> rRec."SSCC Live" then rRec."SSCC Mismatch" := true;
                            if rRec."Warehouse Mismatch" or rRec."SSCC Mismatch" then rRec.Status := rRec.Status::Mismatch
                        end;
                    rRec.Type::"Warehouse Entry":
                        begin
                            rRec.CalcFields("Warehouse Bin Live", rRec."SSCC Bin Live");
                            if rRec."Warehouse Bin Live" <> rRec."SSCC Bin Live" then rRec."SSCC Mismatch" := true;
                            if rRec."SSCC Mismatch" then rRec.Status := rRec.Status::Mismatch
                        end;
                end;
                rRec.Modify();

            until rRec.Next() = 0;
            dDLG.Close();
        end;
    end;

    var
        rILE: Record "Item Ledger Entry";
        rWHE: Record "Warehouse Entry";
        rSSCCL: Record "SSCC Line";
        xLoc, xBin, xSSCC, xItem, xVariant : Text;
        currKey, OldKey : Text; rAP: record "IT4G-Check Apothemata" temporary;
        i, t : Integer;
        dDLG: Dialog;
}
