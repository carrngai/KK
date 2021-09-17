pageextension 50132 "Stand. Gen. Jnl. Subform Ext" extends "Standard Gen. Journal Subform"
{
    layout
    {
        // Add changes to page layout here
        addafter("ShortcutDimCode[8]")
        {
            field("IC Path Code"; Rec."IC Path Code")
            {
                ToolTip = 'Specifies the value of the IC Path Code field';
                ApplicationArea = All;
            }
        }
        modify("ShortcutDimCode[3]") { Visible = true; }
        modify("ShortcutDimCode[4]") { Visible = true; }
        modify("ShortcutDimCode[5]") { Visible = true; }
        modify("ShortcutDimCode[6]") { Visible = true; }
        modify("ShortcutDimCode[7]") { Visible = true; }
        modify("ShortcutDimCode[8]") { Visible = true; }
        modify("Salespers./Purch. Code") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("Bal. VAT Amount") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify("Bal. VAT Bus. Posting Group") { Visible = false; }
        modify("Bal. VAT Prod. Posting Group") { Visible = false; }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}