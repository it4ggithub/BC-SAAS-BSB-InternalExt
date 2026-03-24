table 91001 "IT4G-Import Order Lines tmp"
{
    Caption = 'IT4G-Import Order Lines tmp';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(2; "Variant Code"; Code[20])
        {
            Caption = 'Variant Code';
        }
        field(3; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
    }
    keys
    {
        key(PK; "Item No.", "Variant Code")
        {
            Clustered = true;
        }
    }
}
