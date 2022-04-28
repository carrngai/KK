pageextension 50112 "General Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Description 2"; Rec."Description 2")
            {
                ToolTip = 'Specifies the value of the Description 2 field';
                ApplicationArea = All;
                Editable = false;
            }
        }
        addafter("Credit Amount")
        {
            field("Netting Source No."; Rec."Netting Source No.")
            {
                ToolTip = 'Specifies the value of the Netting Source No. field';
                ApplicationArea = All;
                Editable = false;
            }
            field("Business Unit Code"; Rec."Business Unit Code")
            {
                ToolTip = 'Specifies the value of the Business Unit Code field';
                ApplicationArea = All;
                Editable = false;
            }
            field("Conso. Exch. Adj."; Rec."Conso. Exch. Adj.")
            {
                ToolTip = 'Specifies the value of the Conso. Exch. Adj. field';
                ApplicationArea = All;
                Editable = false;
            }
            field("IC Path Code"; Rec."IC Path Code")
            {
                ToolTip = 'Specifies the value of the IC Path Code field.';
                ApplicationArea = All;
                Editable = false;
            }
            field("IC Source Document No."; Rec."IC Source Document No.")
            {
                ToolTip = 'Specifies the value of the IC Source Document No. field.';
                ApplicationArea = All;
                Editable = false;
            }
        }
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        addafter("Business Unit Code")
        {
            field("Business Unit Name"; Rec."Business Unit Name")
            {
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