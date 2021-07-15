page 50104 "IC Transaction Path"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "IC Transaction Path";

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
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = All;
                }
                field("From Company"; Rec."From Company")
                {
                    ToolTip = 'Specifies the value of the From Company field';
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Details)
            {
                ApplicationArea = All;
                RunObject = page "IC Transaction Path Details";
                RunPageLink = "Path Code" = field("Path Code");

            }
        }
    }

    var
        myInt: Integer;
}