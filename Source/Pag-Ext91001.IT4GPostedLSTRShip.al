namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;
using BCSAASITGBSB.BCSAASITGBSB;
using Microsoft.Inventory.Transfer;

pageextension 91001 "IT4G-Posted LS TR Ship" extends "LSC Store P. Transfer Shipment"
{
    actions
    {
        addlast(Processing)
        {
            action(GetBoxes)
            {
                Caption = 'IT4G Get Transfer Boxes';
                ApplicationArea = All;
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    cIT4G: Codeunit "IT4G-Transfer Events";
                    rTSH: Record "Transfer Shipment Header";

                begin
                    rTSH.SetRange("Transfer Order No.", Rec."Transfer Order No.");
                    if rTSH.FindLast() then
                        cIT4G.GetTRShipBoxes(rTSH."No.", false);
                end;
            }
        }
    }
}
