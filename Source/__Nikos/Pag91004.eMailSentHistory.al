namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;

page 91004 "e-Mail Sent History"
{
    ApplicationArea = All;
    Caption = 'e-Mail Sent History';
    PageType = List;
    SourceTable = "91001";
    UsageCategory = History;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
            }
        }
    }
}
