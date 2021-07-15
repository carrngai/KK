pageextension 50101 BankAccCardExt extends "Bank Account Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
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