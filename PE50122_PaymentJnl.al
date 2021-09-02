pageextension 50122 "Payment Journal Ext" extends "Payment Journal"
{
    layout
    {
        // Add changes to page layout here
        modify("Gen. Posting Type") { Visible = false; }
        modify("Gen. Bus. Posting Group") { Visible = false; }
        modify("Gen. Prod. Posting Group") { Visible = false; }
        modify("Currency Code") { Visible = true; }
        modify("Bal. Account Type") { Visible = false; }
        modify("Bal. Account No.") { Visible = false; }
        modify("Bal. Gen. Posting Type") { Visible = false; }
        modify("Bal. Gen. Bus. Posting Group") { Visible = false; }
        modify("Bal. Gen. Prod. Posting Group") { Visible = false; }
        modify("Recipient Bank Account") { Visible = false; }
        modify("Message to Recipient") { Visible = false; }
        modify("Payment Method Code") { Visible = false; }
        modify("Payment Reference") { Visible = false; }
        modify("Creditor No.") { Visible = false; }
        modify("Bank Payment Type") { Visible = false; }
        modify("Exported to Payment File") { Visible = false; }
        modify(TotalExportedAmount) { Visible = false; }
        modify("Has Payment Export Error") { Visible = false; }
        modify(Correction) { Visible = false; }
        modify(JournalLineDetails) { Visible = false; }
        modify(IncomingDocAttachFactBox) { Visible = false; }
        modify("Payment File Errors") { Visible = false; }
        modify(Control1900919607) { Visible = true; }     //"Dimension Set Entries FactBox"
    }

    actions
    {
        // Add changes to page actions here
        modify(IncomingDoc) { Visible = false; }
        modify("&Payments") { Visible = false; }
        modify(PreCheck) { Visible = false; }
        modify(PreviewCheck) { Visible = false; Promoted = false; }
        modify(PrintCheck) { Visible = false; Promoted = false; }
        modify("Void Check") { Visible = false; Promoted = false; }
        modify("Void &All Checks") { Visible = false; Promoted = false; }
        modify(SuggestEmployeePayments) { Visible = false; Promoted = false; }
        modify(SuggestVendorPayments) { Visible = false; Promoted = false; }
        modify(ExportPaymentsToFile) { Visible = false; Promoted = false; }
        modify(VoidPayments) { Visible = false; Promoted = false; }
        modify(TransmitPayments) { Visible = false; Promoted = false; }
        modify(CreditTransferRegEntries) { Visible = false; Promoted = false; }
        modify(CreditTransferRegisters) { Visible = false; Promoted = false; }
        modify(CalculatePostingDate) { Visible = false; }
        modify("Test Report")
        {
            Promoted = true;
            PromotedCategory = Category8;
        }
    }

    var
        myInt: Integer;
}