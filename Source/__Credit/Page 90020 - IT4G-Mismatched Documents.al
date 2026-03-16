namespace BCSAASITGBSB.BCSAASITGBSB;

using Microsoft.Sales.Receivables;

page 91020 "IT4G-Missmatched Cust. Docs"
{
    ApplicationArea = All;
    Caption = 'IT4G-Missmatched Cust. Documents';

    PageType = List;
    SourceTable = "Detailed Cust. Ledg. Entry";
    SourceTableView = sorting("Cust. Ledger Entry No.", "Entry Type");
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Cust. Ledger Entry No."; Rec."Cust. Ledger Entry No.")
                {
                    StyleExpr = xStyle;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    StyleExpr = xStyle;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    StyleExpr = xStyle;
                }
                field("Document Type"; Rec."Document Type")
                {
                    StyleExpr = xStyle;
                }
                field("Document No."; Rec."Document No.")
                {
                    StyleExpr = xStyle;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    StyleExpr = xStyle;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    StyleExpr = xStyle;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    StyleExpr = xStyle;
                }
                field(Amount; Rec.Amount)
                {
                    StyleExpr = xStyle;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(FindMismachDocument)
            {
                Caption = 'Find Mismatched Documents';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Calculate;
                trigger OnAction()
                var
                    cC: Codeunit "IT4G-MissMach Doc Mng";
                begin
                    cC.FindWrongDocumentRelations();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if rec."Journal Batch Name" = 'WRONG' then
            xStyle := 'Attention'
        else
            if Rec."Entry Type" = Rec."Entry Type"::"Initial Entry" then
                xStyle := 'Strong'
            else
                xStyle := 'AttentionAccent';

    end;

    var
        xStyle: Text;
}
