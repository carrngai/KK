table 50131 "Company TEC"
{
    Caption = 'Company TEC';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = ToBeClassified;
        }
        field(2; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Company Name")
        {
            Clustered = true;
        }
    }

}
