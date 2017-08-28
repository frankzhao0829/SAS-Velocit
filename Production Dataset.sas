LIBNAME velocity "/var/blade/data2031/esiblade/zchunyou/Velocity/Data";

/***************************************************************************************************/
/*** Create macro variable today_date in DDMMMYYYY format to automate SAS program                ***/
/***************************************************************************************************/
%let today_date = %sysfunc(date(),DATE9.);
%put &today_date.;

/***************************************************************************************************/
/*** Replace approriate column names based on QV data models             ***/
/***************************************************************************************************/

proc sql;
create table velocity.scored&today_date._forProduction as
(select opportunity_id as opportunity_id
,opportunity_name as opportunity_name 
,customer_profile_name as customer_profile_name
,es_tcv___m_ as es_tcv___m_
,primary_portfolio as primary_portfolio
,Last_status as last_status
,close_date as close_date
,close_qtr as close_qtr
,close_year as close_year
,sales_stage as sales_stage
,deal_type as deal_type
,opportunity_primary_competitor as opportunity_primary_competitor
,total_opportunity_value___m_ as total_opportunity_value___m_
,total_gross_margin___m_ as total_gross_margin___m_
,total_ffyr___m_ as total_ffyr___m_
,total_fygm___m_ as total_fygm___m_
,crp_region_name as crp_region_name
,crp_geography_name as crp_geography_name
,industry_amid_2_segment_name as industry_amid_2_segment_name
,industry_amid_2_vertical_name as industry_amid_2_vertical_name
,managed_by as managed_by
,forecast_category as forecast_category
,current_sales_stage as current_sales_stage
,sales_stage_prior_to_close as sales_stage_prior_to_close
,contract_length as contract_length
,primary_sales_team_member_name as primary_sales_team_member_name
,primary_sales_team_member_employ as primary_sales_team_member_employ
,primary_sales_team_member_sales as primary_sales_team_member_sales_
,direct_sales_organization_leader as direct_sales_organization_leader
,es_reporting_geo as es_reporting_geo
,es_reporting_region as es_reporting_region
,es_reporting_subregion as es_reporting_subregion
,final_stage as final_stage
,apps_cloud__mobility_and_tr_0001 as apps_cloud__mobility_and_tran000
,apps_development_and_manage_0001 as apps_development_and_manageme000
,bpo_crm__cards_and_payment_tcv__ as bpo_crm__cards_and_payment_tcv__
,bpo_dps__f_l_and_analytics_tcv__ as bpo_dps__f_l_and_analytics_tcv__
,bpo_f_a__hr_and_payroll_tcv___m_ as bpo_f_a__hr_and_payroll_tcv___m_
,communications_solutions_tcv___m as communications_solutions_tcv___m
,data_center_services_tcv___m_ as data_center_services_tcv___m_
,enterprise_applications_ser_0001 as enterprise_applications_servi000
,enterprise_cloud_services_tcv___ as enterprise_cloud_services_tcv___
,information_management_and_0001 as information_management_and_an000
,network_services_tcv___m_ as network_services_tcv___m_
,security_services_tcv___m_ as security_services_tcv___m_
,workplace_services_tcv___m_ as workplace_services_tcv___m_
,apps_cloud__mobility_and_tr_0002 as apps_cloud__mobility_and_tran001
,apps_development_and_manage_0002 as apps_development_and_manageme001
,bpo_crm__cards_and_payment_egm__ as bpo_crm__cards_and_payment_egm__
,bpo_dps__f_l_and_analytics_egm__ as bpo_dps__f_l_and_analytics_egm__
,bpo_f_a__hr_and_payroll_egm___m_ as bpo_f_a__hr_and_payroll_egm___m_
,communications_solutions_egm___m as communications_solutions_egm___m
,data_center_services_egm___m_ as data_center_services_egm___m_
,enterprise_applications_ser_0002 as enterprise_applications_servi001
,enterprise_cloud_services_egm___ as enterprise_cloud_services_egm___
,information_management_and_0002 as information_management_and_an001
,network_services_egm___m_ as network_services_egm___m_
,security_services_egm___m_ as security_services_egm___m_
,workplace_services_egm___m_ as workplace_services_egm___m_
,apps_cloud__mobility_and_tr_0003 as apps_cloud__mobility_and_tran002
,apps_development_and_manage_0003 as apps_development_and_manageme002
,bpo_crm__cards_and_payment_ffyr as bpo_crm__cards_and_payment_ffyr_
,bpo_dps__f_l_and_analytics_ffyr as bpo_dps__f_l_and_analytics_ffyr_
,bpo_f_a__hr_and_payroll_ffyr___m as bpo_f_a__hr_and_payroll_ffyr___m
,communications_solutions_ffyr___ as communications_solutions_ffyr___
,data_center_services_ffyr___m_ as data_center_services_ffyr___m_
,enterprise_applications_ser_0003 as enterprise_applications_servi002
,enterprise_cloud_services_ffyr__ as enterprise_cloud_services_ffyr__
,information_management_and_0003 as information_management_and_an002
,network_services_ffyr___m_ as network_services_ffyr___m_
,security_services_ffyr___m_ as security_services_ffyr___m_
,workplace_services_ffyr___m_ as workplace_services_ffyr___m_
,apps_cloud__mobility_and_tr_0004 as apps_cloud__mobility_and_tran003
,apps_development_and_manage_0004 as apps_development_and_manageme003
,bpo_crm__cards_and_payment_fygm as bpo_crm__cards_and_payment_fygm_
,bpo_dps__f_l_and_analytics_fygm as bpo_dps__f_l_and_analytics_fygm_
,bpo_f_a__hr_and_payroll_fygm___m as bpo_f_a__hr_and_payroll_fygm___m
,communications_solutions_fygm___ as communications_solutions_fygm___
,data_center_services_fygm___m_ as data_center_services_fygm___m_
,enterprise_applications_ser_0004 as enterprise_applications_servi003
,enterprise_cloud_services_fygm__ as enterprise_cloud_services_fygm__
,information_management_and_0004 as information_management_and_an003
,network_services_fygm___m_ as network_services_fygm___m_
,security_services_fygm___m_ as security_services_fygm___m_
,workplace_services_fygm___m_ as workplace_services_fygm___m_
,ams_asl as ams_asl
,daysin01 as daysin01
,daysin02 as daysin02
,daysin03 as daysin03
,daysin04a as daysin04a
,daysin04b as daysin04b
,daysin05 as daysin05
,daysines as daysines
,daysinls as daysinls
,daysinall as daysinall
,includedays01 as includedays01
,includedays02 as includedays02
,includedays03 as includedays03
,includedays04a as includedays04a
,includedays04b as includedays04b
,includedays05 as includedays05
,includedayses as includedayses
,includedaysls as includedaysls
,primaryproductline as primaryproductline
,opptyprobability as opptyprobability
,includeinwinrate_num as includeinwinrate_num
,includeinwinrate_den as includeinwinrate_den
,willtheybuyn as willtheybuyn
,buyerexperiencewithhpn as buyerexperiencewithhpn
,clientrelationshipandinsightn as clientrelationshipandinsightn
,clientdecisionprocessn as clientdecisionprocessn
,competitivepositionn as competitivepositionn
,solutionscopen as solutionscopen
,defferentationn as defferentationn
,teamingn as teamingn
,salesteamstaffingn as salesteamstaffingn
,dealshapeandpricingn as dealshapeandpricingn
,deliveryleadershipteamn as deliveryleadershipteamn
,termsandconditionsn as termsandconditionsn
,flyin as flyin
,cal_days as cal_days
,amid2_first_win as amid2_first_win
,amid2_last_win as amid2_last_win
,ststg1 as ststg1
,ststg2 as ststg2
,ststg3 as ststg3
,ststg4a as ststg4a
,ststg4b as ststg4b
,ststg5 as ststg5
,tcv___m_ as tcv___m_
,ststg0 as ststg0
,longevity as longevity
,recency as recency
,P_0 as P_0
,P_1 as P_1
,daystored as daystored
from velocity.scored&today_date.
)
;
quit;



