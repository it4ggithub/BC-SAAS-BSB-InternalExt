table 91001 "e-Mail Log"
{
    Caption = 'e-Mail Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            Caption = 'Entry No';
            AutoIncrement = true;

        }
        field(2; "Sender Address"; Text[100])
        {
            Caption = 'Sender Address';
        }
        field(3; Recipients; Text[200])
        {
            Caption = 'Recipients';
        }
        field(4; Subject; Text[250])
        {
            Caption = 'Subject';
        }
        field(5; Body; Text[250])
        {
            Caption = 'Body';
        }
        field(6; Attachment; Text[100])
        {
            Caption = 'Attachment';
        }
        field(7; "eMail Date"; Date)
        {
            Caption = 'eMail Date';
        }
        field(8; "eMail Time"; Time)
        {
            Caption = 'eMail Time';
        }
        field(9; "eMail Date Sent"; Date)
        {
            Caption = 'eMail Date Sent';
        }
        field(10; "eMail Time Sent"; Time)
        {
            Caption = 'eMail Time Sent';
        }
        field(11; "Document No"; Code[20])
        {
            Caption = 'Document No';
        }
        field(12; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(13; "Customer No"; Code[20])
        {
            Caption = 'Customer No';
        }
        field(14; "Vendor No"; Code[20])
        {
            Caption = 'Vendor No';
        }
    }
    keys
    {
        key(PK; "Entry No")
        {
            Clustered = true;
        }
    }

}
