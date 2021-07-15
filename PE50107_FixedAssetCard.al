pageextension 50107 FixedAssetCardExt extends "Fixed Asset Card"
{
    layout
    {
        // Add changes to page layout here
        addafter("No.")
        {

            field("No. 2"; Rec."No. 2")
            {
                ToolTip = 'Specifies the value of the No. 2 field';
                ApplicationArea = All;
            }
            field(Remarks; Rec.Remarks)
            {
                ToolTip = 'Specifies the value of the Remarks field';
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