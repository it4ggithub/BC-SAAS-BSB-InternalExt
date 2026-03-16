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
        page "IT4G-Posted Transfer Shipments" = X;
}