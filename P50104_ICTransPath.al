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
                field("From Company"; Rec."From Company")
                {
                    ToolTip = 'Specifies the value of the From Company field';
                    ApplicationArea = All;
                }
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
                field("Bal. Account Type"; Rec."Bal. Account Type")
                {
                    ToolTip = 'Specifies the value of the Account Type field';
                    ApplicationArea = All;
                }
                field("Bal. Account No."; Rec."Bal. Account No.")
                {
                    ToolTip = 'Specifies the value of the Account No. field';
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            part(DimensionFB; "IC Trans. Default Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Dimensions';
                SubPageLink = "Table ID" = const(50104), "Key 1" = field("Path Code"), "Key 2" = const(0), Type = const(Dimension);
            }

            part(BalDimensionFB; "IC Trans. Default Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Bal. Dimensions';
                SubPageLink = "Table ID" = const(50104), "Key 1" = field("Path Code"), "Key 2" = const(0), Type = const("Bal. Dimension");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Dimensions")
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "IC Trans. Default Dim.";
                RunPageLink = "Table ID" = const(50104), "Key 1" = field("Path Code"), "Key 2" = const(0), Type = filter(Dimension);
            }
            action("Bal. Dimensions")
            {
                AccessByPermission = TableData Dimension = R;
                ApplicationArea = Dimensions;
                Caption = 'Bal. Dimensions';
                Image = Dimensions;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "IC Trans. Default Dim.";

                RunPageLink = "Table ID" = const(50104), "Key 1" = field("Path Code"), "Key 2" = const(0), Type = filter("Bal. Dimension");
            }
            action("IC Trans. Path Details")
            {
                ApplicationArea = All;
                Image = Line;
                RunObject = page "IC Transaction Path Details";
                RunPageLink = "Path Code" = field("Path Code");
                Promoted = true;
                PromotedCategory = Process;

            }

            action("IC Trans. Acc. Mapping")
            {
                ApplicationArea = all;
                Image = MapAccounts;
                RunObject = page "IC Transaction Account Mapping";
                RunPageLink = "Path Code" = field("Path Code");
                Promoted = true;
                PromotedCategory = Process;
            }
        }
    }

    var
        myInt: Integer;
}