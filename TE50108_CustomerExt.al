tableextension 50108 "Customer Ext" extends Customer
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Netting Vendor No."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Vendor."No.";
        }
    }

    var
        myInt: Integer;
}