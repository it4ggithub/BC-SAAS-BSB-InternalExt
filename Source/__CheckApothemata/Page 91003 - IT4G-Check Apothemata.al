namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;

page 91003 "IT4G-Check Apothemata"
{
    ApplicationArea = All;
    Caption = 'IT4G-Check Apothemata';
    PageType = List;
    SourceTable = "IT4G-Check Apothemata";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.', Comment = '%';
                }
                field(Location; Rec.Location)
                {
                    ToolTip = 'Specifies the value of the Location field.', Comment = '%';
                }
                field(Bin; Rec.Bin)
                {
                    ToolTip = 'Specifies the value of the Bin field.', Comment = '%';
                }
                field(SSCC; Rec.SSCC)
                {
                    ToolTip = 'Specifies the value of the SSCC field.', Comment = '%';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of the Variant Code field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the value of the Quantity field.', Comment = '%';
                }
                field("Warehouse Qty"; Rec."Warehouse Qty")
                {
                    ToolTip = 'Specifies the value of the Warehouse Qty field.', Comment = '%';
                }
                field("SSCC Qty"; Rec."SSCC Qty")
                {
                    ToolTip = 'Specifies the value of the SSCC Qty field.', Comment = '%';
                }
                field("SSCC Bin Qty"; Rec."SSCC Bin Qty")
                {
                    ToolTip = 'Specifies the value of the SSCC Bin Qty field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Refresh)
            {
                Caption = 'Refresh';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Apothemata";
                begin
                    cC.RefreshApothemata(Rec);
                end;
            }
            action(Empty)
            {
                Caption = 'Empty';
                Image = Delete;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    clear(rec);
                    rec.Truncate();
                end;
            }
        }
    }
}
