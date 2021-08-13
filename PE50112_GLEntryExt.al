pageextension 50112 "General Ledger Entries Ext" extends "General Ledger Entries"
{
    layout
    {
        // Add changes to page layout here
        addafter(Amount)
        {
            field("Business Unit Code"; Rec."Business Unit Code")
            {
                ToolTip = 'Specifies the value of the Business Unit Code field';
                ApplicationArea = All;
            }
            field("Conso. Exch. Adj."; Rec."Conso. Exch. Adj.")
            {
                ToolTip = 'Specifies the value of the Conso. Exch. Adj. field';
                ApplicationArea = All;
            }
            field("Source Type"; Rec."Source Type")
            {
                ToolTip = 'Specifies the value of the Source Type field';
                ApplicationArea = All;
            }
            field("Source No."; Rec."Source No.")
            {
                ToolTip = 'Specifies the value of the Source No. field';
                ApplicationArea = All;
            }
            field("Netting Source No."; Rec."Netting Source No.")
            {
                ToolTip = 'Specifies the value of the Netting Source No. field';
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