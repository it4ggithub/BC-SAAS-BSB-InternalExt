namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;
using BSBCustom.BSBCustom;

codeunit 91001 "IT4G-Check Imported webOrders"
{
    //trigger OnRun()
    //begin
    //    DoTheJob()
    //end;

    procedure DoTheJob(var rTMP: Record "Temp Customer Order Header" temporary)
    var
        rCOT: Record "Temp Customer Order Header";
        rCOH: Record "LSC Customer Order Header";
        rCOA: Record "Customer Order Header Archive";
    begin
        if rTMP.IsTemporary then rTMP.DeleteAll();

        if rCOT.FindSet() then begin
            t := rCOT.Count;
            i := 0;
            f := 0;
            if GuiAllowed then dDLG.Open('Checking Temp WEB orders ... #1 of #2# Error Found: #3', i, t, f);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                //if Not rCOH.get(rCOT."Document ID") then
                //    if Not rCOA.get(rCOT."Document ID") then begin
                //        f += 1;
                //        Clear(rTMP);
                //        rTMP.transferFields(rCOT);
                //        rTMP.Insert();
                //    end;
                Clear(rTMP);
                rTMP.transferFields(rCOT);
                rTMP.Insert();

            until rCOT.Next() = 0;
        end;

        if rCOH.FindSet() then begin
            t := rCOH.Count;
            i := 0;
            f := 0;
            if GuiAllowed then dDLG.Open('Checking Active WEB orders ... #1 of #2# Error Found: #3', i, t, f);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if rTMP.get(rCOH."Document ID") then
                    rTMP.Delete();
            until rCOH.Next() = 0;
        end;
        if rCOA.FindSet() then begin
            t := rCOA.Count;
            i := 0;
            f := 0;
            if GuiAllowed then dDLG.Open('Checking Archived WEB orders ... #1 of #2# Error Found: #3', i, t, f);
            repeat
                i += 1;
                if GuiAllowed then dDLG.Update();
                if rTMP.get(rCOA."Document ID") then
                    rTMP.Delete();
            until rCOA.Next() = 0;
        end;
        if GuiAllowed then dDLG.Close();

    end;

    var
        i, t, f : Integer;
        dDLG: Dialog;
}
