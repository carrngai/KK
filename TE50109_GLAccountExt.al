tableextension 50109 "G/L Account Ext" extends "G/L Account"
{
    fields
    {
        // Add changes to table fields here
        field(50100; "Netting Type"; Option) //G025
        {
            OptionMembers = " ","AR","AP","Exch. Rate Gain","Exch. Rate Loss";

            trigger OnValidate()
            var
                l_COA: Record "G/L Account";
            begin
                if ("Netting Type" = "Netting Type"::"Exch. Rate Gain") or ("Netting Type" = "Netting Type"::"Exch. Rate Loss") then begin
                    l_COA.Reset();
                    l_COA.SetRange("Netting Type", "Netting Type");
                    if l_COA.FindSet() then
                        Error('Only 1 Account can select %1 as Netting Type', "Netting Type");
                end;
            end;
        }
    }

    var
        myInt: Integer;
}