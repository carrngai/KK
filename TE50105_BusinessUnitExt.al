tableextension 50105 "Business Unit Ext" extends "Business Unit"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Parent Company"; Boolean)
        {
            DataClassification = ToBeClassified;

            trigger OnValidate()
            var
                l_bu: Record "Business Unit";
            begin
                l_bu.Reset();
                l_bu.SetRange("Parent Company", true);
                if l_bu.FindFirst() then
                    Error('Only 1 Business Unit can be setup as Parent Company');
            end;
        }
        field(50101; "Conso Path"; Text[1000])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
}