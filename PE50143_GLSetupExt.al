pageextension 50143 GLSetupExt extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("PMS Import General Journal Template"; "PMS Import General Journal Template")
            {
                ApplicationArea = all;
            }
            field("PMS Import General Journal Batch"; "PMS Import General Journal Batch")
            {
                ApplicationArea = all;
            }
        }
    }
}