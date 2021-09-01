pageextension 50124 "Accounting Periods Ext" extends "Accounting Periods"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        addafter("C&lose Year")
        {
            action("Close Income Statement")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                Image = TransferToGeneralJournal;
                RunObject = report "Close Income Statement";
            }
        }
    }

    var
        myInt: Integer;
}