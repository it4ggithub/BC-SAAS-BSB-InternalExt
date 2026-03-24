namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;

using Microsoft.Sales.Document;

pageextension 91008 "IT4G-Sales Cr. Memo" extends "Sales Credit Memo"
{
    actions
    {
        addlast(Processing)
        {
            action(ImportLines)
            {
                Caption = 'Import Lines';
                Image = Import;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ImportLinesMgt: Codeunit "IT4G-Import Lines Management";
                begin
                    ImportLinesMgt.ImportExcel(Rec.RecordId);
                end;
            }
        }
    }
}
