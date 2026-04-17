permissionset 91000 "BSB-Internal"
{
    Assignable = true;
    Permissions = codeunit "BSB-Int-Functions" = X,
        codeunit "IT4G-Check Imported webOrders" = X,
        page "BSB-Trans. AADE for Correction" = X,
        page "IT4G-Temp Cust. Order Header" = X,
        codeunit "IT4G-MissMach Doc Mng" = X,
        page "IT4G-Missmatched Cust. Docs" = X,
        codeunit "IT4G-Charge Assigment" = X,
        page "IT4G-Pending Item Charge Asg" = X,
        page "IT4G-Posted Transfer Shipments" = X,
        tabledata "IT4G-Check Apothemata" = RIMD,
        table "IT4G-Check Apothemata" = X,
        codeunit "IT4G-Check Apothemata" = X,
        page "IT4G-Check Apothemata" = X,
        tabledata "IT4G-Import Order Lines tmp" = RIMD,
        table "IT4G-Import Order Lines tmp" = X,
        report "IT4G-GLE Report" = X,
        codeunit "IT4G-Import lines Management" = X,
        page "IT4G-Fason Shipment" = X,
        tabledata "IT4G-SSCC Content" = RIMD,
        table "IT4G-SSCC Content" = X,
        page "IT4G-SSCC Bin break" = X,
        tabledata "IT4G-Check Item Sales" = RIMD,
        table "IT4G-Check Item Sales" = X,
        codeunit "IT4G-Check Item Sales Mng" = X,
        page "IT4G-Check Item Sales" = X;
}