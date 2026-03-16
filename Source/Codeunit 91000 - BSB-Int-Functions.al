codeunit 91000 "BSB-Int-Functions"
{
    Procedure GetVendorFile(var rV: Record Vendor)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FileName: Text;
        SheetName: Text;
        xItem: Text;
        cF: Codeunit "IT4G-Functions";
        rPM: Record "Payment Method";
        rEPM: Record "Extended Payment Header";
        rVBA: Record "Vendor Bank Account";
    begin
        FileName := 'Vendors';
        SheetName := 'Vendors';
        if rV.FindSet() then begin
            TempExcelBuffer.Reset();
            TempExcelBuffer.DeleteAll();

            // 1. Create Header
            TempExcelBuffer.AddColumn('Κωδικός Προμηθευτή', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Όνομα Προμηθευτή', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('ΑΦΜ Προμηθευτή', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Κωδικός Μεθόδου Πληρωμής - Κωδικός', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Κωδικός Μεθόδου Πληρωμής - Περιγραφή', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Πιστωτική Μέθοδος Πληρωμής', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Επεκταμένες Πληρωμές – Κωδικός', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Επεκταμένες Πληρωμές – Περιγραφή', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Τραπεζικός Λογαριασμός - IBAN', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Αριθμός Τραπεζικού Λογαριασμού – κωδικός', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            TempExcelBuffer.AddColumn('Αριθμός Τραπεζικού Λογαριασμού – Ονομασία', false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);


            repeat
                TempExcelBuffer.NewRow();
                TempExcelBuffer.AddColumn(rV."No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(rV."Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(rV."VAT Registration No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(rV."Payment Method Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                if rPM.Get(rV."Payment Method Code") then
                    TempExcelBuffer.AddColumn(rPM.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
                else
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(rV."Credit Payment Method", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                TempExcelBuffer.AddColumn(rV."Extended Payments", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                if rEPM.Get(rV."Extended Payments") then
                    TempExcelBuffer.AddColumn(rEPM.Description, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text)
                else
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

                rVBA.SetRange("Vendor No.", rV."No.");
                if rVBA.FindFirst() then begin
                    TempExcelBuffer.AddColumn(rVBA.IBAN, false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(rVBA."Bank Account No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn(rVBA."Name", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end else begin
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                    TempExcelBuffer.AddColumn('', false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
                end;

            //TempExcelBuffer.AddColumn(rI."Country/Region of Origin Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);

            until rV.Next() = 0;
            TempExcelBuffer.CreateNewBook(SheetName);
            TempExcelBuffer.WriteSheet(SheetName, CompanyName, UserId);
            TempExcelBuffer.CloseBook();
            TempExcelBuffer.OpenExcel();
        end;
    end;



    procedure ApplyCustEntries()
    var
        cC: Page "Customer Ledger Entries";
    begin

    end;
}
