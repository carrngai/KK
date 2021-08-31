
pageextension 50140 AccountantRC_Ext extends "Accountant Role Center"
{
    layout
    {

        //modify(Control1902304208) { Visible = false; } //"Accountant Activities"
        modify("User Tasks Activities") { Visible = false; }
        modify(Emails) { Visible = false; } //"Email Activities"
        modify(Control123) { Visible = false; } //"Team Member Activities"
        modify(Control100) { Visible = false; } //"Cash Flow Forecast Chart"
        modify(Control122) { Visible = false; } //"Power BI Report Spinner Part"
        modify(Control9) { Visible = false; } //"Help And Chart Wrapper"
        //modify(Control1907692008) { Visible = false; } //"My Accounts"
        modify(ApprovalsActivities) { Visible = false; }
    }
    actions
    {
        //action
        modify("Incoming Documents") { Visible = false; }
        modify("Sales &Credit Memo") { Visible = false; }
        modify("P&urchase Credit Memo") { Visible = false; }
        modify("VAT Reports") { Visible = false; }
        modify("Cash Flow Setup") { Visible = false; }
        modify("Cost Accounting Setup") { Visible = false; }
        modify("P&ost Inventory Cost to G/L") { Visible = false; }
        modify("Calc. and Pos&t VAT Settlement") { Visible = false; }
        modify(Action60) { Visible = false; }
        modify("Cash Flow") { Visible = false; }

        modify("G/L Journal Entry") { Visible = true; }
        modify("Payment Journal Entry") { Visible = true; }
        addafter("Payment Journal Entry")
        {
            action("Cash Receipt Journal Entry")
            {
                AccessByPermission = TableData "Gen. Journal Batch" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'Cash Receipt Journal Entry';
                RunObject = Page "Cash Receipt Journal";
                ToolTip = 'Register received payments by manually applying them to the related customer, vendor, or bank ledger entries. Then, post the payments to G/L accounts and thereby close the related ledger entries.';
            }
        }


        //Embedding
        modify("EC Sales List") { Visible = false; }
        modify("VAT Returns") { Visible = false; }
        modify("VAT Statements") { Visible = false; }
        modify(Intrastat) { Visible = false; }
        modify("Purchase Orders") { Visible = false; }
        modify("Purchase Invoices") { Visible = false; }
        modify(Action171) { Visible = false; }  //"IC Chart of Accounts"
        modify(Action173) { Visible = false; }  //"IC Dimensions"
        modify(Partners) { Caption = 'IC Partners'; }

        //Cost Accounting
        modify("Cost Accounting") { Visible = false; } //group
        modify("Cost Types") { Visible = false; }
        modify("Cost Centers") { Visible = false; }
        modify("Cost Objects") { Visible = false; }
        modify("Cost Allocations") { Visible = false; }
        modify("Cost Budgets") { Visible = false; }
        modify("Cost Accounting Registers") { Visible = false; }
        modify("Cost Accounting Budget Registers") { Visible = false; }

        //Finance
        modify(Employees) { Visible = false; }
        modify("Intrastat Journals") { Visible = false; }
        modify("General Journals") { Visible = false; }
        modify("Recurring General Journals") { Visible = false; }
        modify(Deferrals) { Visible = false; }
        modify(Action14) { Visible = false; } //'VAT Statements'
        modify("Bank Account Posting Groups") { Visible = false; }
        modify(Action116) { Visible = false; } //'G/L Account Categories'
        addlast(Action172)
        {
            action(Customer)
            {
                ApplicationArea = All;
                RunObject = page "Customer List";
            }
            action(Vendor)
            {
                ApplicationArea = All;
                RunObject = page "Vendor List";
            }
        }

        //Journal
        modify(Action1102601002) { Visible = false; }
        modify(PostedGeneralJournals) { Visible = false; }

        //Cash Management
        modify("Cash Flow Forecasts") { Visible = false; }
        modify("Chart of Cash Flow Accounts") { Visible = false; }
        modify("Cash Flow Manual Expenses") { Visible = false; }
        modify("Cash Flow Manual Revenues") { Visible = false; }
        modify("Statement of Cash Flows") { Visible = false; }
        modify("Direct Debit Collections") { Visible = false; }
        modify("Payment Recon. Journals") { Visible = false; }
        addafter(Action164)
        {
            action("Bank Account Posting Groups_")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Bank Account Posting Groups';
                RunObject = Page "Bank Account Posting Groups";
                ToolTip = 'Set up posting groups, so that payments in and out of each bank account are posted to the specified general ledger account.';
            }
        }

        //FA
        modify(Insurance) { Visible = false; }
        modify("Insurance Journals") { Visible = false; }
        modify("Recurring Fixed Asset Journals") { Visible = false; }

        //Posted Document
        modify("Posted Sales Invoices") { Visible = false; }
        modify("Posted Sales Credit Memos") { Visible = false; }
        modify("Posted Purchase Invoices") { Visible = false; }
        modify("Posted Purchase Credit Memos") { Visible = false; }
        addafter("G/L Registers")
        {
            action("General Ledger Entries")
            {
                ApplicationArea = all;
                RunObject = page "General Ledger Entries";
            }
            action("Customer Ledger Entries")
            {
                ApplicationArea = all;
                RunObject = page "Customer Ledger Entries";
            }
            action("Vendor Ledger Entries")
            {
                ApplicationArea = all;
                RunObject = page "Vendor Ledger Entries";
            }
        }

    }
}