namespace BCSAASITGBSB.BCSAASITGBSB;

using Microsoft.Inventory.Transfer;

pageextension 91003 "IT4G-Transfer Shipment" extends "Posted Transfer Shipment"
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
