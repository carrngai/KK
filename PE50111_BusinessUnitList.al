pageextension 50111 "Business Unit List Ext" extends "Business Unit List"
{
    layout
    {
        // Add changes to page layout here
        modify(Name) { Visible = true; }
        addafter("Last Run")
        {

            field("Income Currency Factor"; Rec."Income Currency Factor")
            {
                ToolTip = 'Specifies the value of the Income Currency Factor field';
                ApplicationArea = All;
            }
            field("Balance Currency Factor"; Rec."Balance Currency Factor")
            {
                ToolTip = 'Specifies the value of the Balance Currency Factor field';
                ApplicationArea = All;
            }
            field("Last Balance Currency Factor"; Rec."Last Balance Currency Factor")
            {
                ToolTip = 'Specifies the value of the Last Balance Currency Factor field';
                ApplicationArea = All;
            }
            field("Parent Company"; Rec."Parent Company")
            {
                ToolTip = 'Specifies the value of the Parent Company field';
                ApplicationArea = All;
            }
            field("Conso Path"; Rec."Conso Path")
            {
                ToolTip = 'Specifies the value of the Conso Path field';
                ApplicationArea = All;
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
                Promoted = true;
                PromotedCategory = Process;
            }
        }
        addafter("Run Consolidation")
        {
            action("Run Consolidation_")
            {
                ApplicationArea = all;
                Image = ImportDatabase;
                RunObject = report "Import Conso. from DB Ext";
                Caption = 'Run Conslidation';
                Promoted = true;
                PromotedCategory = Process;
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