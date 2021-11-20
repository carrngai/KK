pageextension 50136 ConfigPackageCardTEC extends "Config. Package Card"
{
    PromotedActionCategories = 'New,Process,Report,Manage,Package,Master Company Function';

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
        addafter("F&unctions")
        {
            group("Master Company Function")
            {
                action("Import from Company")
                {
                    Caption = 'Import Package Records from Company';
                    Promoted = true;
                    Image = Import;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
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

                action("Select Companies")
                {
                    Caption = 'Select Copy To Companies';
                    Promoted = true;
                    Image = Company;
                    PromotedIsBig = true;
                    PromotedCategory = Category6;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        SelectCompanyTEC: Page SelectCompanyTEC;
                        CompanyTEC: Record "Company TEC";
                    begin
                        SelectCompanyTEC.RUNMODAL;

                    end;


                }

                action("Apply to Selected Company")
                {
                    Caption = 'Apply to Selected Companies';
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = Export;
                    PromotedCategory = Category6;
                    ApplicationArea = all;
                    trigger OnAction()
                    var
                        ConfigPackageTable: Record "Config. Package Table";
                        ConfigCompanyExchange: Codeunit "Config. Company Exchange";
                        ConfirmManagement: Codeunit "Confirm Management";
                        Text003: Label 'Apply Package Data from %1 to below companies? %2';
                        TextSelectedCompany: Text;
                        CompanyTEC: Record "Company TEC";


                    begin
                        //Error('hi');
                        Rec.TESTFIELD(Code);

                        CompanyTEC.Reset();
                        CompanyTEC.SetRange(Select, false);
                        if CompanyTEC.FindFirst() then begin
                            CompanyTEC.Reset();
                            CompanyTEC.SetRange(Select, true);
                            if CompanyTEC.Findset() then begin
                                repeat
                                    TextSelectedCompany += '\' + CompanyTEC."Company Name";
                                until CompanyTEC.Next() = 0;
                            end else
                                Error('You must select Copy to Companies ');
                        end else
                            TextSelectedCompany := 'ALL Companies';

                        IF Confirm(STRSUBSTNO(Text003, Rec.Code, TextSelectedCompany), TRUE) THEN BEGIN
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
                                Error('You must select Copy to Companies ');
                        END;

                    end;

                }
                action("Apply Exch. Rate Master to Selected Company")
                {
                    Caption = 'Apply Exch. Rate Master to Selected Companies';
                    Promoted = true;
                    PromotedIsBig = true;
                    Image = Export;
                    PromotedCategory = Category6;
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

    }
    var

}
