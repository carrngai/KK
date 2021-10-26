tableextension 50113 GLSetupExt extends "General Ledger Setup"
{
    fields
    {
        field(50100; "PMS Import General Journal Template"; Code[10])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(50101; "PMS Import General Journal Batch"; Code[10])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("PMS Import General Journal Template"));
        }
    }
}