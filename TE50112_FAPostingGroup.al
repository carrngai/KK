tableextension 50112 FAPostingGroupExt extends "FA Posting Group"
{
    fields
    {
        // field(50100; "Accum. Depr. Acc. on Disposal Dim."; Code[20])
        field(50100; "Accum Depr Acc on Disposal Dim"; Code[20])
        {
            Caption = 'Accum. Depr. Acc. on Disposal Dim.';
            TableRelation = "Dimension Value"."Code" WHERE("Dimension Code" = CONST('FIXED ASSET MOVEMENT'));
        }
    }
}