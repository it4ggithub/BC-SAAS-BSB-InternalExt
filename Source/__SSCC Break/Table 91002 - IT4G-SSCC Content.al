table 91002 "IT4G-SSCC Content"
{
    Caption = 'IT4G-SSCC Content';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
        }
        field(2; SSCC; Code[20])
        {
            Caption = 'SSCC';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(4; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
        }
        field(5; Inventory; Decimal)
        {
            Caption = 'Inventory';
        }
        field(6; "SSCC Qty"; Decimal)
        {
            Caption = 'SSCC Qty';
        }
        field(50; "Inventory Calc"; Decimal)
        {
            Caption = 'Inventory Calc.';
            FieldClass = FlowField;
            CalcFormula = Sum("Warehouse Entry".Quantity where("Bin Code" = field("Bin Code"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        field(60; "SSCC Inv. Calc"; Decimal)
        {
            Caption = 'SSCC Inv. Calc';
            FieldClass = FlowField;
            CalcFormula = Sum("SSCC Line".Quantity where("Bin Code" = field("Bin Code"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        field(61; "SSCC Qty Calc"; Decimal)
        {
            Caption = 'SSCC Qty Calc';
            FieldClass = FlowField;
            CalcFormula = Sum("SSCC Line".Quantity where("SSCC No." = field(SSCC), "Bin Code" = field("Bin Code"), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
    }
    keys
    {
        key(PK; "Bin Code", SSCC, "Item No.", "Variant Code") { Clustered = true; }
    }
}
