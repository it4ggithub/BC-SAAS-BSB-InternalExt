namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;

using Microsoft.Sales.Document;

pageextension 91007 "IT4G-Sales Invoice" extends "Sales Invoice"
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
