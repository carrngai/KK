page 50106 "IC Transaction Account Mapping"
{
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Related';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Transaction Account Mapping";
    SourceTableView = sorting("Path Code", "Bal. Account Type", "Bal. Account No.") order(ascending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Path Code"; Rec."Path Code")
                {
                    ToolTip = 'Specifies the value of the Path Code field';
                    ApplicationArea = All;
                }
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ToolTip = 'Specifies the value of the Bal. Account Type field';
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Bal. Account No. field';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            part(BalDimensionFB; "IC Trans. Default Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Bal. Dimension';
                SubPageLink = "Table ID" = const(50106), "Key 1" = const(''), "Key 2" = field(ID), Type = filter("Bal. Dimension");
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action("Bal. Dimensions")
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Bal. Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "IC Trans. Account Mapping Dim.";
                RunPageLink = "Table ID" = const(50106), "Key 1" = const(''), "Key 2" = field(ID), Type = filter("Bal. Dimension");
            }

        }
    }

}