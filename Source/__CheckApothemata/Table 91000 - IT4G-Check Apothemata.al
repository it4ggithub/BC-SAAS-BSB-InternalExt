table 91000 "IT4G-Check Apothemata"
{
    Caption = 'IT4G-Check Apothemata';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Type"; Option)
        {
            Caption = 'Type';
            OptionMembers = "Item Ledger Entry","Warehouse Entry",SSCC;
        }
        field(2; Location; Code[20])
        {
            Caption = 'Location';
        }
        field(3; Bin; Code[20])
        {
            Caption = 'Bin';
        }
        field(4; SSCC; Code[20])
        {
            Caption = 'SSCC';
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(6; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        Field(10; "Warehouse Qty"; decimal)
        {
            Caption = 'Warehouse Qty';
            fieldClass = FlowField;
            CalcFormula = Sum("IT4G-Check Apothemata"."Quantity" where("Type" = Const("Warehouse Entry"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(11; "SSCC Qty"; decimal)
        {
            Caption = 'SSCC Qty';
            fieldClass = FlowField;
            CalcFormula = Sum("IT4G-Check Apothemata"."Quantity" where("Type" = Const("SSCC"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(12; "SSCC Bin Qty"; decimal)
        {
            Caption = 'SSCC Bin Qty';
            fieldClass = FlowField;
            CalcFormula = Sum("IT4G-Check Apothemata"."Quantity" where("Type" = Const("SSCC"), "Bin" = field("Bin"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
    }
    keys
    {
        key(PK; "Type", Location, Bin, SSCC, "Item No.", "Variant Code")
        {
            Clustered = true;
            SumIndexFields = Quantity;
        }
    }
}
