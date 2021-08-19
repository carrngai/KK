pageextension 50131 ConfigPackageCardTEC extends "Config. Package Card"
{
    layout
    {
        addlast(General)
        {
            field("Copy to Company"; rec."Copy to Company")
            {
                ApplicationArea = all;
                Visible = false;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action("Select Companies")
            {
                Caption = 'Copy To Companies';
                Promoted = true;
                Image = Company;
                PromotedIsBig = true;
                PromotedCategory = New;
                ApplicationArea = all;
                trigger OnAction()
                var
                    SelectCompanyTEC: Page SelectCompanyTEC;
                    CompanyTEC: Record "Company TEC";
                begin
                    SelectCompanyTEC.RUNMODAL;

                end;


            }


            action("Import from Company")
            {
                Caption = 'Import from Company';
                Promoted = true;
                Image = Import;
                PromotedIsBig = true;
                PromotedCategory = New;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                    CompanyTEC: Record "Company TEC";
                begin
                    CompanyTEC.Reset();
                    CompanyTEC.SetRange(Select, true);

                    If Not CompanyTEC.FindFirst() then
                        Error('You Must Select Copy to Companies ');
                    //ConfigCompanyExchange.FunHideDialog();
                    ConfigCompanyExchange.fn_ExportRecordsFromCompany(Rec.Code);

                end;

            }
            action("Export to Selected Company")
            {
                Caption = 'Export to Selected Company';
                Promoted = true;
                PromotedIsBig = true;
                Image = Export;
                PromotedCategory = New;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ConfigPackageTable: Record "Config. Package Table";
                    ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                    ConfirmManagement: Codeunit "Confirm Management";
                    Text003: Label 'Apply data from package %1?';
                    CompanyTEC: Record "Company TEC";


                begin
                    //Error('hi');
                    Rec.TESTFIELD(Code);
                    IF Confirm(STRSUBSTNO(Text003, Rec.Code), TRUE) THEN BEGIN
                        CompanyTEC.Reset();
                        CompanyTEC.SetRange(Select, true);

                        If CompanyTEC.FindFirst() then begin
                            repeat

                                Rec."Copy to Company" := CompanyTEC."Company Name";
                                Rec.Modify();
                                //ConfigCompanyExchange.FunHideDialog();
                                ConfigPackageTable.Reset();
                                ConfigPackageTable.SETRANGE("Package Code", Rec.Code);

                                //ConfigCompanyExchange.FunHideDialog();
                                ConfigCompanyExchange.fn_ApplyCompanyPackage(Rec, ConfigPackageTable, TRUE);
                                ConfigCompanyExchange.fn_ExportRecordsFromCompany(Rec.Code);
                                Rec."Copy to Company" := '';
                                Rec.Modify();
                            //ConfigCompanyExchange.FunHideDialog();
                            //ConfigCompanyExchange.fn_ExportRecordsFromCompany(Code);

                            until CompanyTEC.Next() = 0;

                            CompanyTEC.Reset();
                            CompanyTEC.SetRange(Select, true);
                            If CompanyTEC.FindFirst() then begin
                                repeat
                                    CompanyTEC.Select := false;
                                    CompanyTEC.Modify();
                                until CompanyTEC.Next() = 0;
                            end;
                        end else
                            Error('You Must Select Copy to Companies ');
                    END;

                end;

            }
            action("Apply Currency Exchange Rates")
            {
                Caption = 'Apply Currency Exchange Rates';
                Promoted = true;
                PromotedIsBig = true;
                Image = Export;
                PromotedCategory = New;
                ApplicationArea = all;
                trigger OnAction()
                var
                    ConfigPackageTable: Record "Config. Package Table";
                    ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                    ConfirmManagement: Codeunit "Confirm Management";
                    Text003: Label 'Apply data from package %1?';
                    CompanyTEC: Record "Company TEC";

                begin
                    Rec.TESTFIELD(Code);
                    IF Confirm(STRSUBSTNO(Text003, Rec.Code), TRUE) THEN BEGIN
                        CompanyTEC.Reset();
                        CompanyTEC.SetRange(Select, true);

                        If CompanyTEC.FindFirst() then begin
                            repeat
                                ConfigCompanyExchange.ApplyCurrencyExchangeRates(CompanyTEC."Company Name");
                            until CompanyTEC.Next() = 0;
                        end else
                            Error('You Must Select Copy to Companies ');
                    END;

                end;

            }
        }
    }
    var

}
