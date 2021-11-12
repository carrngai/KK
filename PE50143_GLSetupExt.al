pageextension 50143 GLSetupExt extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("PMS Import General Journal Template"; Rec."PMS Import Gen. Jnl. Template")
            {
                ApplicationArea = all;
            }
            field("PMS Import General Journal Batch"; Rec."PMS Import Gen. Jnl. Batch")
            {
                ApplicationArea = all;
            }
        }
    }
}