pageextension 50121 "Cash Receipt Journal Ext" extends "Cash Receipt Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify("Currency Code") { Visible = true; }
        addafter("Credit Amount")
        {
            field("Amount (LCY)_"; Rec."Amount (LCY)")
            {
                ToolTip = 'Specifies the value of the Amount (LCY) field';
                ApplicationArea = All;
            }
        }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify(Correction) { Visible = false; }
        modify(JournalLineDetails) { Visible = false; }
        modify(IncomingDocAttachFactBox) { Visible = false; }
        modify(Control1900919607) { Visible = true; }     //"Dimension Set Entries FactBox"
    }

    actions
    {
        // Add changes to page actions here
        modify(IncomingDoc) { Visible = false; }
        modify("Renumber Document Numbers")
        {
            Promoted = true;
            PromotedCategory = Process;
        }
        modify("Test Report")
        {
            Promoted = true;
            PromotedCategory = Category6;
        }
    }

    var
        myInt: Integer;
}