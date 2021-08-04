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
            field("Parent Company"; Rec."Parent Company")
            {
                ToolTip = 'Specifies the value of the Parent Company field';
                ApplicationArea = All;
            }
        }
        addlast("G/L Accounts")
        {
            group("JV/Asso Adjustment")
            {
                field("Investment Account"; Rec."Investment Account")
                {
                    ToolTip = 'Specifies the value of the Investment Account field';
                    ApplicationArea = All;
                }
                field("Share of Profit Account"; Rec."Share of Profit Account")
                {
                    ToolTip = 'Specifies the value of the Share of Profit Account field';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        // Add changes to page actions here
        addbefore("Run Consolidation")
        {
            action("Calculate Average Rate(Manual)...")
            {
                ApplicationArea = all;
                Image = Calculate;
                RunObject = report "Calculate BU Average Rate";
            }
        }
        addafter("Run Consolidation")
        {
            action("Run Consolidation Ext")
            {
                ApplicationArea = all;
                Image = ImportDatabase;
                RunObject = report "Import Conso. from DB Ext";
            }
        }
        modify("Run Consolidation")
        {
            Visible = false;
        }
    }

    var
        myInt: Integer;
}