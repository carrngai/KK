page 50105 "IC Transaction Path Details"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Transaction Path Details";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Path Code"; Rec."Path Code")
                {
                    ToolTip = 'Specifies the value of the Path Code field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Sequence; Rec.Sequence)
                {
                    ToolTip = 'Specifies the value of the Sequence field';
                    ApplicationArea = All;
                }
                field("To Company"; Rec."To Company")
                {
                    ToolTip = 'Specifies the value of the To Company field';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {

        }
    }

    trigger OnOpenPage()
    var
        l_ICPath: Record "IC Transaction Path";
    begin
        l_ICPath.Get(Rec."Path Code");
        CurrPage.Caption := CopyStr(l_ICPath."Path Code" + ' - ' + 'IC Trans. Path Detail', 1, MaxStrLen(FormCaption));
    end;

    var
        FormCaption: Text[250];

    // procedure SetFormCaption(NewFormCaption: Text[250])
    // begin
    //     FormCaption := CopyStr(NewFormCaption + ' - ' + CurrPage.Caption, 1, MaxStrLen(FormCaption));
    // end;    
}