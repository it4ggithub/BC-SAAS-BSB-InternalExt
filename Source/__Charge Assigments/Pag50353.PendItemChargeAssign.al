//ERGRET.001 - 31.05.2024 - nancyk - Creation Transfer functionality
//#IF TODO
page 91353 "IT4G-Pending Item Charge Asg"
{

    ApplicationArea = All;
    Caption = 'IT4G-Pending Item Charge Assignment';
    PageType = List;
    SourceTable = "Pending Item Charge Assignment";
    UsageCategory = Documents;
    Editable = true;
    DeleteAllowed = False;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            group(XXX)
            {
                ShowCaption = false;
                field("PostingDate"; gDate)
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                }
            }

            repeater(General)
            {
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GR Cancelled"; Rec."GR Cancelled")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Import File ID"; Rec."Import File ID")
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field("Item Charge No."; Rec."Item Charge No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. To Assign"; Rec."Qty. To Assign")
                {
                    ApplicationArea = All;
                    StyleExpr = ItemChargeStyleExpression;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowItemChargeAssgnt;
                        CurrPage.UPDATE(FALSE);
                    end;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Document)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Document';
                Image = ItemCosts;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                //PromotedOnly = true;
                trigger OnAction()
                var
                    PurchInvHeader: Record "Purch. Inv. Header";
                    PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
                begin
                    CASE Rec."Document Type" OF
                        Rec."Document Type"::"Posted Invoice":
                            BEGIN
                                PurchInvHeader.GET(Rec."Document No.");
                                PAGE.RUN(138, PurchInvHeader);
                            END;
                        Rec."Document Type"::"Posted Credit Memo":
                            BEGIN
                                PurchCrMemoHeader.GET(Rec."Document No.");
                                PAGE.RUN(140, PurchCrMemoHeader);
                            END;
                    END;
                end;
            }
        }
        area(processing)
        {


            action(assign)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Item Charge Assignemts';
                Image = ItemCosts;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                //PromotedOnly = true;
                Enabled = Not Rec."GR Cancelled";
                trigger OnAction()
                begin
                    Rec.ShowItemChargeAssgnt;
                    SetItemChargeFieldsStyle;
                end;
            }
            action(Post)
            {
                ApplicationArea = ItemCharges;
                Caption = 'Post';
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                //PromotedOnly = true;
                Enabled = Not Rec."GR Cancelled";
                trigger OnAction()
                var
                    DelayedAssignt: Codeunit "IT4G-Charge Assigment";
                begin
                    if not confirm('Post Entries on ' + format(gDate) + '?') then
                        exit;
                    DelayedAssignt.PostPendingItemChargeLine(Rec, gDate);
                end;
            }
        }

    }
    var
        ItemChargeStyleExpression: Text;
        gDate: Date;

    local procedure SetItemChargeFieldsStyle()
    begin
        ItemChargeStyleExpression := '';
        IF (Rec."Qty. to Assign" < Rec.Quantity) THEN
            ItemChargeStyleExpression := 'Unfavorable';
    end;

    trigger OnOpenPage()
    begin
        gDate := WorkDate();
    end;

}
//#ENDIF