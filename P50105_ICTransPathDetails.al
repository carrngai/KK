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
            part(DimensionFB; "IC Trans. Default Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Dimensions';
                SubPageLink = "Table ID" = const(50105), "Key 1" = field("Path Code"), "Key 2" = field(Sequence), Type = const(Dimension);
            }

            part(BalDimensionFB; "IC Trans. Default Dim. FactBox")
            {
                ApplicationArea = all;
                Caption = 'Bal. Dimensions';
                SubPageLink = "Table ID" = const(50105), "Key 1" = field("Path Code"), "Key 2" = field(Sequence), Type = const("Bal. Dimension");
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
                RunPageLink = "Table ID" = const(50105), "Key 1" = field("Path Code"), "Key 2" = field(Sequence), Type = filter(Dimension);
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
                RunPageLink = "Table ID" = const(50105), "Key 1" = field("Path Code"), "Key 2" = field(Sequence), Type = filter("Bal. Dimension");
            }
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