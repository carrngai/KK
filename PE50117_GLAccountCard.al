pageextension 50117 "G/L Account Card Ext" extends "G/L Account Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Netting Type"; Rec."Netting Type")
            {
                ToolTip = 'Specifies the value of the Netting Type field';
                ApplicationArea = All;
            }
        }
        modify("Cost Accounting") { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}