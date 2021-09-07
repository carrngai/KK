pageextension 50118 "Chart of Accounts Ext" extends "Chart of Accounts"
{
    layout
    {
        // Add changes to page layout here
        addafter("Account Type")
        {

            field("Netting Type"; Rec."Netting Type")
            {
                ToolTip = 'Specifies the value of the Netting Type field';
                ApplicationArea = All;
            }
        }
        modify("Cost Type No.") { Visible = false; }
        modify("Default Deferral Template Code") { Visible = false; }
        modify(Balance) { Visible = false; }
        modify("Balance at Date") { Visible = true; }
        modify("Direct Posting") { Visible = true; }
    }

    actions
    {
        // Add changes to page actions here
        modify("General Journal") { Promoted = false; }
        addbefore("Close Income Statement")
        {
            action(ARAPNetting)
            {
                ApplicationArea = All;
                RunObject = report ARAPNetting;
                Caption = 'AR/AP Netting';
                Promoted = true;
                PromotedCategory = Process;
                Image = MoveNegativeLines;
            }
            action(ExchNetting)
            {
                ApplicationArea = All;
                RunObject = report "Exch. Rate Gain/Loss Netting";
                Caption = 'Exch. Rate Gain/Loss Netting';
                Promoted = true;
                PromotedCategory = Process;
                Image = MoveNegativeLines;
            }
        }
    }

    var
        myInt: Integer;
}