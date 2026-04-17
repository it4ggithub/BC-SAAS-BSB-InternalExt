table 99022 "IT4G-Check Item Sales"
{
    Caption = 'IT4G-Check Item Sales';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = "Item";
        }
        field(2; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer where("No." = field("Customer No."));
        }
        field(4; "Customer Address"; Code[20])
        {
            Caption = 'Customer Address';
            TableRelation = "Ship-to Address".Code where("Customer No." = field("Customer No."));
        }
        field(5; "Store No."; Code[20])
        {
            Caption = 'Store No.';
            TableRelation = "LSC Store"."No.";
        }
        field(6; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            TableRelation = Location.Code;
        }
        field(100; "Qty on Blanket Order"; Decimal)
        {
            Caption = 'Qty on Blanket Order';
        }
        field(101; "Qty on Blanket Order Calc"; Decimal)
        {
            Caption = 'Qty on Blanket Order Calc';
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Line".Quantity where("Document Type" = const("Blanket Order"), "No." = field("Item No."), "Variant Code" = field("Variant Code"), "Sell-to Customer No." = field("Customer No."), "Ship-to Code RCGRBASE" = field("Customer Address")));
        }
        field(110; "Qty on Sales Order"; Decimal)
        {
            Caption = 'Qty on Sales Order';
        }
        field(111; "Qty on Sales Order Calc"; Decimal)
        {
            Caption = 'Qty on Sales Order Calc';
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Line".Quantity where("Document Type" = const("Order"), "No." = field("Item No."), "Variant Code" = field("Variant Code"), "Sell-to Customer No." = field("Customer No."), "Ship-to Code RCGRBASE" = field("Customer Address")));
        }
        field(120; "Qty Shipped"; Decimal)
        {
            Caption = 'Qty Shipped';
        }
        field(121; "Qty Shipped Calc"; Decimal)
        {
            Caption = 'Qty Shipped Calc';
            FieldClass = FlowField;
            CalcFormula = Sum("Sales Shipment Line".Quantity where("No." = field("Item No."), "Variant Code" = field("Variant Code"), "Sell-to Customer No." = field("Customer No."), "Ship-to Code RCGRBASE" = field("Customer Address")));
        }
        field(130; "Qty Picked Take"; Decimal)
        {
            Caption = 'Qty Picked Take';
        }
        field(131; "Qty Picked Place"; Decimal)
        {
            Caption = 'Qty Picked Place';
        }
        field(132; "Qty Picked Take Scanned"; Decimal)
        {
            Caption = 'Qty Picked Take Scanned';
        }
        field(133; "Qty Picked Place Scanned"; Decimal)
        {
            Caption = 'Qty Picked Place Scanned';
        }
        field(140; "Qty Packed SSCC"; Decimal)
        {
            Caption = 'Qty Packed SSCC';
        }
        field(150; "Qty Posted Warehouse"; Decimal)
        {
            Caption = 'Qty Posted Warehouse';
        }
        field(200; Status; Option)
        {
            Caption = 'Status';
            OptionMembers = Match,Dif;
        }
    }
    keys
    {
        key(PK; "Item No.", "Variant Code", "Customer No.", "Customer Address") { Clustered = true; }
    }
}
