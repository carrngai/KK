pageextension 50102 BankAccListExt extends "Bank Account List"
{
    layout
    {
        // Add changes to page layout here
        addafter(Contact)
        {
            field("Sort Code"; Rec."Sort Code")
            {
                ToolTip = 'Specifies the value of the Sort Code field';
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}