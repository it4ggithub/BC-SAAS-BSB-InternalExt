namespace BCSAASBSBInternalExt.BCSAASBSBInternalExt;

using Microsoft.Finance.GeneralLedger.Ledger;

report 91000 "IT4G-GLE Report"
{
    ApplicationArea = All;
    Caption = 'IT4G-GLE Report';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './source/__GLE Report/GLE REPORT.rdlc';
    //ExcelLayout = './source/__GLE Report/GLE REPORT.xlsx';

    dataset
    {
        dataitem(GLEntry; "G/L Entry")
        {
            DataItemTableView = sorting("Posting Date", "Document No.");
            RequestFilterFields = "Posting Date", "G/L Account No.";
            column(Filters; Getfilters()) { }
            column(PostingDate; "Posting Date") { }
            column(DocumentDate; "Document Date") { }
            column(No_Series; "No. Series") { }
            column(NoSeries; NoSeries) { }
            column(DocumentNo; "Document No.") { }
            column(ExternalDocumentNo; "External Document No.") { }
            column(DocumentType; "Document Type") { }
            column(GlobalDimension1Code; "Global Dimension 1 Code") { }
            column(GlobalDimension2Code; "Global Dimension 2 Code") { }
            column(GLAccountNo; "G/L Account No.") { }
            column(GLAccountName; "G/L Account Name") { }
            column(Description; Description) { }
            column(SourceType; "Source Type") { }
            column(SourceNo; "Source No.") { }
            column(DebitAmount; "Debit Amount") { }
            column(CreditAmount; "Credit Amount") { }
            column(AddCurrencyDebitAmount; "Add.-Currency Debit Amount") { }
            column(AddCurrencyCreditAmount; "Add.-Currency Credit Amount") { }
            column(CurrencyCode; "Currency Code") { }
            column(SourceCode; "Source Code") { }
            column(UserID; "User ID") { }
        }

    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing) { }
        }
    }
    trigger OnPreReport()
    begin
    end;

    var
        Filters: Text;
}
