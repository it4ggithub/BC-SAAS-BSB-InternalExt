pageextension 91000 "BSB_Int-Vendor List" extends "Vendor List"
{
    actions
    {
        addlast(Processing)
        {
            action("BSB-Vendor Excel")
            {
                ApplicationArea = All;
                Caption = 'Get Vendor Excel';
                Promoted = true;
                PromotedIsBig = true;

                Image = Excel;
                trigger OnAction()
                var
                    rV: Record Vendor;
                    cF: Codeunit "BSB-Int-Functions";
                begin
                    cF.GetVendorFile(rV);
                end;
            }
        }
    }
}
