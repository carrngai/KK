pageextension 50115 "Customer Card" extends "Customer Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("IC Partner Code")
        {
            field("Netting Vendor No."; Rec."Netting Vendor No.")
            {
                ToolTip = 'Specifies the value of the Netting Vendor No. field';
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