pageextension 50142 FAPostingGroupExt extends "FA Posting Group Card"
{
    layout
    {
        addafter("Accum. Depr. Acc. on Disposal")
        {
            field("Accum. Depr. Acc. on Disposal Dim."; Rec."Accum Depr Acc on Disposal Dim")
            {
                ApplicationArea = All;
            }
        }
    }
}