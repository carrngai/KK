pageextension 50119 "Purchase Journal Ext" extends "Purchase Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify(DocumentAmount) { Visible = false; }
        modify("Currency Code") { Visible = true; }
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
        modify(IncomingDocument) { Visible = false; }
    }

    var
        myInt: Integer;
}