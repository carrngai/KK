page 50114 "PMS Import Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "PMS Import Log";
    Editable = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater("PMS Import Log")
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                }
                field("Start Date Time"; Rec."Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("End Date Time"; Rec."End Date Time")
                {
                    ApplicationArea = All;
                }
                field(Job; Rec.Job)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Error Message 2"; Rec."Error Message 2")
                {
                    ApplicationArea = All;
                }
                field("Error Message 3"; Rec."Error Message 3")
                {
                    ApplicationArea = All;
                }
                field("Error Message 4"; Rec."Error Message 4")
                {
                    ApplicationArea = All;
                }
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}