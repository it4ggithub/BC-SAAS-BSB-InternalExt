namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;

page 91001 "IT4G-Temp Cust. Order Header"
{
    //ERGRET.001 - 28.11.2024 - dionysisp - Creation
    ApplicationArea = All;
    Caption = 'IT4G - Temp Customer Order Header';
    PageType = List;
    SourceTable = "Temp Customer Order Header";
    SourceTableTemporary = true;
    UsageCategory = Lists;
    SourceTableView = sorting("Document Id")
                      order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Document ID"; Rec."Document ID")
                {
                    ApplicationArea = All;
                }
                field("Eshop Document ID"; Rec."Eshop Document ID")
                {
                    ApplicationArea = All;
                }
                field("Created at Store"; Rec."Created at Store")
                {
                    ApplicationArea = All;
                }
                field(Created; Rec.Created)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                }
                field(County; Rec.County)
                {
                    ApplicationArea = All;
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                }
                field("Ship-to County"; Rec."Ship-to County")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                }
                field(Website; Rec.Website)
                {
                    ApplicationArea = All;
                }
                field("Transaction Id"; Rec."Transaction Id")
                {
                    ApplicationArea = All;
                }
                field(Promo; Rec.Promo)
                {
                    ApplicationArea = All;
                }
                field(StatusId; Rec.StatusId)
                {
                    ApplicationArea = All;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = All;
                }
                field(BlackListed; Rec.BlackListed)
                {
                    ApplicationArea = All;
                }
                field(SameBilling; Rec.SameBilling)
                {
                    ApplicationArea = All;
                }
                field(From_call_center; Rec.From_call_center)
                {
                    ApplicationArea = All;
                }
                field(Invoice; Rec.Invoice)
                {
                    ApplicationArea = All;
                }
                field(Paid; Rec.Paid)
                {
                    ApplicationArea = All;
                }
                field(Locale; Rec.Locale)
                {
                    ApplicationArea = All;
                }
                field(Invoice_number; Rec.Invoice_number)
                {
                    ApplicationArea = All;
                }
                field("Company name"; Rec."Company name")
                {
                    ApplicationArea = All;
                }
                field(ShippingFixedLocationID; Rec.ShippingFixedLocationID)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                field(User_id; Rec.User_id)
                {
                    ApplicationArea = All;
                }
                field(Profession; Rec.Profession)
                {
                    ApplicationArea = All;
                }
                field(Tax_office; Rec.Tax_office)
                {
                    ApplicationArea = All;
                }
                field(Tracking_Number; Rec.Tracking_Number)
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = all;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = all;
                }
                field(Payment_Method; Rec.Payment_Method)
                {
                    ApplicationArea = All;
                }
                field("Alt. Shipping Voucher Code"; Rec."Alt. Shipping Voucher Code")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Mobile Prefix"; Rec."Bill-to Mobile Prefix")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Extra Info"; Rec."Bill-to Extra Info")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Mobile Phone No."; Rec."Ship-to Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Mobile Prefix"; Rec."Ship-to Mobile Prefix")
                {
                    ApplicationArea = All;
                }
                field("Ship-to Extra Info"; Rec."Ship-to Extra Info")
                {
                    ApplicationArea = All;
                }
                field("Store No. Erg"; Rec."Store No. Erg")
                {
                    ApplicationArea = All;
                }
                field("Total Amount Eshop"; Rec."Total Amount Eshop")
                {
                    ApplicationArea = All;
                }
                field("Total Quantity Eshop"; Rec."Total Quantity Eshop")
                {
                    ApplicationArea = All;
                }
                field("Logged In"; Rec."Logged In")
                {
                    ApplicationArea = All;
                }
                field(Loyalty; Rec.Loyalty)
                {
                    ApplicationArea = All;
                }
                field("Phone Order"; Rec."Phone Order")
                {
                    ApplicationArea = All;
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = All;
                }
                field("Eshop Member Id"; Rec."Eshop Member Id")
                {
                    ApplicationArea = All;
                }
                field("Total Discount Erg"; Rec."Total Discount Erg")
                {
                    ApplicationArea = All;
                }
                field("First Requested Date"; Rec."First Requested Date")
                {
                    ApplicationArea = all;
                }
                field("Second Requested Date"; Rec."Second Requested Date")
                {
                    ApplicationArea = all;
                }
                field(customerTrns; Rec.customerTrns)
                {
                    ApplicationArea = all;
                }
                field(sourceCode; Rec.sourceCode)
                {
                    ApplicationArea = all;
                }
                field(Inserted; Rec.Inserted)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Check)
            {
                ApplicationArea = All;
                Caption = 'Check';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Process;
                trigger OnAction()
                var
                    cu: Codeunit "IT4G-Check Imported webOrders";
                begin
                    cu.DoTheJob(Rec);
                end;
            }
        }
    }
}
