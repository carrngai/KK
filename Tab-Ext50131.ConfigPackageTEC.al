tableextension 50131 ConfigPackageTEC extends "Config. Package"
{
    fields
    {
        field(50100; "Copy to Company"; Text[30])
        {
            Caption = 'Copy to Company';
            DataClassification = ToBeClassified;
            TableRelation = Company;
        }
    }
}
