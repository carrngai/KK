page 50103 "List of Director"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "List of Director";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Company; Rec.Company)
                {
                    ToolTip = 'Specifies the value of the Company field';
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = All;
                    Editable = false;

                }
                field(Director; Rec.Director)
                {
                    ToolTip = 'Specifies the value of the Director field';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {

        }
    }

    var
        myInt: Integer;
}