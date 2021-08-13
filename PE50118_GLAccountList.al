pageextension 50118 "Chart of Accounts Ext" extends "Chart of Accounts"
{
    layout
    {
        // Add changes to page layout here
        addafter("Account Type")
        {

            field("Netting Type"; Rec."Netting Type")
            {
                ToolTip = 'Specifies the value of the Netting Type field';
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