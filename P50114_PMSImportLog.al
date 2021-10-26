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
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Start Date Time"; "Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("End Date Time"; "End Date Time")
                {
                    ApplicationArea = All;
                }
                field(Job; Job)
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                }
                field("Error Message 2"; "Error Message 2")
                {
                    ApplicationArea = All;
                }
                field("Error Message 3"; "Error Message 3")
                {
                    ApplicationArea = All;
                }
                field("Error Message 4"; "Error Message 4")
                {
                    ApplicationArea = All;
                }
                field("File Name"; "File Name")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}