page 50106 "IC Transaction Account Mapping"
{
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Related';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "IC Transaction Account Mapping";
    SourceTableView = sorting("Path Code", "Account Type", "Account No.", "Bal. Account Type", "Bal. Account No.") order(ascending);

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
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = All;
                }
                field("Account No."; Rec."Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field';
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
            part(DimensionFB; "IC Trans. Acc. Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Dimension';
                SubPageLink = ID = field(ID),
                                "Type ID" = const(1);
            }
            part(BalDimensionFB; "IC Trans. Acc. Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Bal. Dimension';
                SubPageLink = ID = field(ID),
                                "Type ID" = const(2);
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Dimensions)
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "IC Trans. Account Mapping Dim.";
                RunPageLink = "ID" = field(ID),
                            "Type ID" = const(1);
            }
            action("Bal. Dimensions")
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Bal. Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "IC Trans. Account Mapping Dim.";
                RunPageLink = "ID" = field(ID),
                            "Type ID" = const(2);
            }

        }
    }

}