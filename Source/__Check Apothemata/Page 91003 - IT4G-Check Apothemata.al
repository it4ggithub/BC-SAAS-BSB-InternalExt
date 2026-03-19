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
            group(Count)
            {
                Caption = 'Count';
                ShowCaption = false;
                field(RowCount; Rec.Count)
                {
                    Editable = false;
                    Caption = 'No. of Records';
                }

            }
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
                field("ILE Live"; Rec."ILE Live")
                {
                    ToolTip = 'Specifies the value of the ILE Live field.', Comment = '%';
                }
                field("Warehouse Live"; Rec."Warehouse Live")
                {
                    ToolTip = 'Specifies the value of the Warehouse Live field.', Comment = '%';
                }
                field("SSCC Live"; Rec."SSCC Live")
                {
                    ToolTip = 'Specifies the value of the SSCC Live field.', Comment = '%';
                }
                field("Warehouse Bin Live"; Rec."Warehouse Bin Live")
                {
                    ToolTip = 'Specifies the value of the Warehouse Bin Live field.', Comment = '%';
                }
                field("SSCC Bin Live"; Rec."SSCC Bin Live")
                {
                    ToolTip = 'Specifies the value of the SSCC Bin Live field.', Comment = '%';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the value of the Status field.', Comment = '%';
                }
                field("Status Text"; Rec."Status Text")
                {
                    ToolTip = 'Specifies the value of the Status Text field.', Comment = '%';
                }
                field("Warehouse Mismatch"; Rec."Warehouse Mismatch")
                {
                    ToolTip = 'Specifies the value of the Warehouse Mismatch field.', Comment = '%';
                }
                field("SSCC Mismatch"; Rec."SSCC Mismatch")
                {
                    ToolTip = 'Specifies the value of the SSCC Mismatch field.', Comment = '%';
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
            action(CheckEntris)
            {
                Caption = 'CheckEntries';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Apothemata";
                begin
                    cC.CheckStatus(Rec);
                end;
            }
            action(ILE)
            {
                Caption = 'Item Ledger Entry';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Apothemata";
                begin
                    cC.CreateILEntry(Rec);
                end;
            }
            action(WH)
            {
                Caption = 'Warehouse Entry';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Apothemata";
                begin
                    cC.CreateWHEntry(Rec);
                end;
            }
            action(SSCCE)
            {
                Caption = 'SSCC Entry';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    cC: Codeunit "IT4G-Check Apothemata";
                begin
                    cC.CreateSSCCEntry(Rec);
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
