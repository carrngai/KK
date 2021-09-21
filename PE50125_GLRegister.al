pageextension 50125 "G/L Registers Ext" extends "G/L Registers"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addbefore("G/L Register")
        {
            action("G/L Register_")
            {
                ApplicationArea = All;
                RunObject = report "G/L Register Ext";
                Image = GLRegisters;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Caption = 'G/L Register';
            }
            action("G/L Sales Document")
            {
                ApplicationArea = All;
                RunObject = report "G/L Sales Document";
                Image = SalesInvoice;
                Promoted = true;
                PromotedCategory = Report;
                PromotedIsBig = true;
                Caption = 'G/L Sales Document';
            }
        }
        modify("G/L Register") { Visible = false; }
    }

    var
        myInt: Integer;
}