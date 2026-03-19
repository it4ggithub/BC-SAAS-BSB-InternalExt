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

        Field(100; "ILE Live"; decimal)
        {
            Caption = 'ILE Live';
            fieldClass = FlowField;
            CalcFormula = Sum("Item Ledger Entry"."Quantity" where("Location Code" = field(Location), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(101; "Warehouse Live"; decimal)
        {
            Caption = 'Warehouse Live';
            fieldClass = FlowField;
            CalcFormula = Sum("Warehouse Entry"."Quantity" where("Location Code" = field(Location), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(102; "SSCC Live"; decimal)
        {
            Caption = 'SSCC Live';
            fieldClass = FlowField;
            CalcFormula = Sum("SSCC Line"."Quantity" where("Location Code" = field(Location), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(120; "Warehouse Bin Live"; decimal)
        {
            Caption = 'Warehouse Bin Live';
            fieldClass = FlowField;
            CalcFormula = Sum("Warehouse Entry"."Quantity" where("Location Code" = field(Location), "Bin Code" = field(Bin), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(121; "SSCC Bin Live"; decimal)
        {
            Caption = 'SSCC Bin Live';
            fieldClass = FlowField;
            CalcFormula = Sum("SSCC Line"."Quantity" where("Location Code" = field(Location), "Bin Code" = field(Bin), "Item No." = field("Item No."), "Variant Code" = field("Variant Code")));
        }
        Field(20; "Status"; Option)
        {
            Caption = 'Status';
            OptionMembers = Match,Mismatch;
        }
        Field(21; "Status Text"; Text[100])
        {
            Caption = 'Status Text';
        }
        Field(22; "Warehouse Mismatch"; Boolean)
        {
            Caption = 'Warehouse Mismatch';
        }
        Field(23; "SSCC Mismatch"; Boolean)
        {
            Caption = 'SSCC Mismatch';
        }
    }
    keys
    {
        key(PK; "Type", Location, Bin, SSCC, "Item No.", "Variant Code")
        {
            Clustered = true;
            SumIndexFields = Quantity;
        }
        key(IX; Status) { SumIndexFields = Quantity; }
    }
}
