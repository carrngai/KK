pageextension 50116 "G/L Account List Ext" extends "G/L Account List"
{

    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;

    procedure ChangeToCompany(CompanyName: Code[50])
    begin
        Rec.ChangeCompany(CompanyName);
    end;
}