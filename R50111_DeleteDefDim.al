report 50111 DeleteDefDim
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    trigger OnPreReport()
    var
        defdim: Record "Default Dimension";
    begin
        defdim.Reset();
        defdim.SetRange("No.", '');
        defdim.DeleteAll();
        defdim.SetRange("Table ID", 0);
        defdim.DeleteAll();
    end;
}