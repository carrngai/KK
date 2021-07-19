pageextension 50110 "Business Unit Card Ext" extends "Business Unit Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("Currency Exchange Rate Table")
        {
            field("Income Currency Factor"; Rec."Income Currency Factor")
            {
                ToolTip = 'Specifies the value of the Income Currency Factor field';
                ApplicationArea = All;
                Editable = false;
            }
            field("Balance Currency Factor"; Rec."Balance Currency Factor")
            {
                ToolTip = 'Specifies the value of the Balance Currency Factor field';
                ApplicationArea = All;
                Editable = false;
            }
            field("Last Balance Currency Factor"; Rec."Last Balance Currency Factor")
            {
                ToolTip = 'Specifies the value of the Last Balance Currency Factor field';
                ApplicationArea = All;
                Editable = false;
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