namespace BCSAASITGBSB.BCSAASITGBSB;

page 99030 "IT4G-Check Item Sales"
{
    ApplicationArea = All;
    Caption = 'IT4G-Check Item Sales';
    PageType = List;
    SourceTable = "IT4G-Check Item Sales";
    //SourceTableTemporary = true;
    UsageCategory = Administration;
    //InsertAllowed = false;
    //DeleteAllowed = false;
    //ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Status; Rec.Status) { }
                field("Customer No."; Rec."Customer No.") { }
                field("Customer Address"; Rec."Customer Address") { }
                field("Store No."; Rec."Store No.") { }
                field("Location Code"; Rec."Location Code") { }
                field("Item No."; Rec."Item No.") { }
                field("Variant Code"; Rec."Variant Code") { }
                field("Qty on Blanket Order"; Rec."Qty on Blanket Order") { }
                //field("Qty on Blanket Order Calc"; Rec."Qty on Blanket Order Calc") { }
                field("Qty on Sales Order"; Rec."Qty on Sales Order") { }
                //field("Qty on Sales Order Calc"; Rec."Qty on Sales Order Calc") { }
                //field("Qty Shipped Calc"; Rec."Qty Shipped Calc") { }
                field("Qty Picked Take"; Rec."Qty Picked Take") { }
                field("Qty Picked Take Scanned"; Rec."Qty Picked Take Scanned") { }
                field("Qty Picked Place"; Rec."Qty Picked Place") { }
                field("Qty Picked Place Scanned"; Rec."Qty Picked Place Scanned") { }
                field("Qty Packed SSCC"; Rec."Qty Packed SSCC") { }
                field("Qty Shipped"; Rec."Qty Shipped") { StyleExpr = xStyle; }
                field("Qty Posted Warehouse"; Rec."Qty Posted Warehouse") { StyleExpr = xStyle; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Check)
            {
                Caption = 'EMPTY';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                begin
                    rec.Truncate();
                end;
            }
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Item Sales Mng";
                begin
                    cC.CalcView(rec, '', '');
                end;
            }
            action(RefreshItem)
            {
                Caption = 'Refresh Item';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Item Sales Mng";
                begin
                    cC.CalcView(rec, rec."Item No.", '');
                end;
            }
            action(RefreshItemvariant)
            {
                Caption = 'Refresh Item variant';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Item Sales Mng";
                begin
                    cC.CalcView(rec, rec."Item No.", rec."Variant Code");
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        If rec."Qty Shipped" <> Rec."Qty Picked Place Scanned" then
            xStyle := 'Unfavorable'
        else
            xStyle := 'Normal';

    end;

    var
        xStyle: Text;
}