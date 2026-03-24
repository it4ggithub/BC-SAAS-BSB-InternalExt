namespace BCSAASITGBSBInternalExt.BCSAASITGBSBInternalExt;

using Microsoft.Inventory.Transfer;

pageextension 91002 "IT4G-Transfer Order Import" extends "Transfer Order"
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
