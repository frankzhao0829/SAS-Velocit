LIBNAME velocity "/var/blade/data2031/esiblade/zchunyou/Velocity/Data";
LIBNAME test "/var/blade/data2031/esiblade/zchunyou/Velocity/test";
LIBNAME dhc "/var/blade/data2031/esiblade/zchunyou/Velocity/DHC";

/***************************************************************************************************/
/*** Create macro variable today_date in DDMMMYYYY format to automate SAS program                ***/
/***************************************************************************************************/
%let today_date = %sysfunc(date(),DATE9.);
%put &today_date.;


/*****************************************************************************/
/*** Rename to match current QV data models                                ***/
/*** We need to delete not us and us other labeled deals from GRIP         ***/
/*****************************************************************************/
Data velocity.i&today_date.;
	set velocity.i&today_date.(rename=(AMS_ASL=ams_asl));
	rename status=Last_status;
	if ams_asl in('not us','US - Other') then delete;
run;


Data Renewal&today_date. Add_new&today_date. dhc&today_date. won&today_date.;
	set velocity.i&today_date.;

	format contract_length ststg1 ststg2 ststg3 ststg4a ststg4b ststg5 8.;

/***************************************************************************************************/
/*** Rename to match scoring dataset, keep old name for QV developers                            ***/
/***************************************************************************************************/

tcv___m_ = total_opportunity_value___m_;

/***************************************************************************************************/
/*** We only use OPEN and WON in the Dashboard, they're in pipeline but we need dates going back ***/
/***************************************************************************************************/

	if Last_status = 'LOST' then delete;
	if Last_status = 'CANCELLED' then delete;

/***************************************************************************************************/
/*** Create flags for the stage in which the opportunity began                                   ***/
/*** Create linear ststg variable for interaction term in the model 							 ***/
/***************************************************************************************************/

	if daysin01>0 then ststg1=1;
		 	else ststg1=0;
	if daysin01=0 and daysin02>0 then ststg2=1;
			else ststg2=0;
	if daysin01=0 and daysin02=0 and daysin03>0 then ststg3=1;
			else ststg3=0;
	if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a>0 then ststg4a=1;
			else ststg4a=0;
	if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b>0 then ststg4b=1;
			else ststg4b=0;
	if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b=0 and daysin05>0 then ststg5=1;
			else ststg5=0;
	if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b=0 and daysin05=0 then ststg0=1;
			else ststg0=0;
	
	ststg=0;
	if daysin01>0 then ststg=1;
	else if daysin01=0 and daysin02>0 then ststg=2;
	else if daysin01=0 and daysin02=0 and daysin03>0 then ststg=3;
	else if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a>0 then ststg=4;
	else if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b>0 then ststg=5;
	else if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b=0 and daysin05>0 then ststg=6;
	else if daysin01=0 and daysin02=0 and daysin03=0 and daysin04a=0 and daysin04b=0 and daysin05=0 then ststg=7;

/***************************************************************************************************/
/*** Calculate longevity and recency from first and last win dates                               ***/
/***************************************************************************************************/

	longevity="&today_date."D - amid2_first_win;
	if longevity="." then longevity=1095;
	recency="&today_date."D - amid2_last_win;
	if recency="." then recency=1095;

/***************************************************************************************************/
/*** Rename AMS_ASL variable according to GRIP latest AMS subregion list                         ***/
/***************************************************************************************************/

	if ams_asl = 'Canada-Combined' then ams_asl = 'Canada';
	if ams_asl = 'LA - Brazil' then ams_asl = 'Brazil';

/***************************************************************************************************/
/*** find primary product line by highest TCV per product line                                   ***/
/***************************************************************************************************/

		array maxtcv(13) 
			apps_cloud__mobility_and_transfo 
			apps_development_and_management_ 
			bpo_crm__cards_and_payment_tcv__
			bpo_dps__f_l_and_analytics_tcv__ 
			bpo_f_a__hr_and_payroll_tcv___m_ 
			communications_solutions_tcv___m 
			data_center_services_tcv___m_
			enterprise_applications_services 
			enterprise_cloud_services_tcv___ 
			information_management_and_analy 
			network_services_tcv___m_
			security_services_tcv___m_ 
			workplace_services_tcv___m_;
		do i=1 to 13;
			if maxtcv(i)>highest_val then do;
				highest_val=maxtcv(i);
				proline=i;
			end;
		end;

     if proline = 1 then prodline='appscloud';
else if proline = 2 then prodline='appsdev';
else if proline = 3 then prodline='bpocards';
else if proline = 4 then prodline='aboanalys';
else if proline = 5 then prodline='bpopryroll';
else if proline = 6 then prodline='commsol';
else if proline = 7 then prodline='dcntrserv';
else if proline = 8 then prodline='entappserv';
else if proline = 9 then prodline='entcloud';
else if proline = 10 then prodline='informgmt';
else if proline = 11 then prodline='netserv';
else if proline = 12 then prodline='secser';
else if proline = 13 then prodline='wkplserv';

/********************************************************************************************************************/
/*** Create a temporary flag for missing AMS_ASL or missing prodline and use a similar coefficient for scoring    ***/
/********************************************************************************************************************/
	flag=0;
	if ams_asl = 'NULL' and deal_type ='Renewal' then do;
		ams_asl = 'SLA'; flag=1; end;
	if ams_asl = 'P&G' and deal_type in ('New','Renewal') then do; 
		ams_asl = 'SLA'; flag=2; end;
	if ams_asl = 'Unassigned' then do;
		ams_asl = 'SLA'; flag= 6; end;
	if deal_type='Add-On' and ams_asl = 'NULL' then do;
		ams_asl='OneHP'; flag=10; end;

	if deal_type='Renewal' and prodline='aboanalys' then do;
		prodline='appscloud';  flag=3;	end;
	if deal_type='Renewal' and prodline='secser' then do;
		prodline='appscloud';  flag=4;	end;
	if deal_type='Renewal' and prodline='entcloud' then do;
		prodline='commsol';  flag=5; end;
   if deal_type='New' and prodline='bpopryrol' then do;
		prodline='aboanalys'; flag=8; end;
	
	if deal_type ne 'Renewal' then do;
		New_identifier=1;
		if deal_type='New' then New_Identifier=0;
		Add_identifier=1-New_identifier;
	end;

/***************************************************************************************************/
/*** Calculate DHC variables scoring and Late stage deal identifier for DHC_Closers              ***/
/*** Create dhc_flag to differentiate wheter a deal contains DHC information                     ***/
/***************************************************************************************************/
	DHC_predictors= WillTheyBuyN + BuyerExperienceWithHPN + ClientRelationshipAndInsightN + CompetitivePositionN+SolutionScopeN;
	DHC_Closers= ClientDecisionProcessN + DefferentationN + TeamingN + SalesTeamStaffingN + DealShapeandPricingN + 
			 DeliveryLeadershipTeamN + TermsAndConditionsN;

	LS_identifier=1;
	if IncludeDaysES=1 and IncludeDaysLS=0 then LS_Identifier=0;
	
	if WillTheyBuyN ne 0 or BuyerExperienceWithHPN ne 0 or ClientRelationshipAndInsightN ne 0 or CompetitivePositionN ne 0
       or ClientDecisionProcessN ne 0 or SolutionScopeN ne 0 or DefferentationN ne 0 or TeamingN ne 0 or SalesTeamStaffingN ne 0 
       or DealShapeandPricingN ne 0 or DeliveryLeadershipTeamN ne 0 or TermsAndConditionsN ne 0
    then dhc_flag=1;
	
/***************************************************************************************************/
/*** Calculate flyin and cal_days based on old QV data model                                     ***/
/***************************************************************************************************/

if win_loss_qtr=created_qtr then flyin=1;
	else flyin=0;
if win_loss_date>created_date then cal_days=created_date - win_loss_date;
	else cal_days=created_date - close_date;


/***************************************************************************************************/
/***  Output 4 different data set based on last_status, DHC and deal type                        ***/
/***************************************************************************************************/

if Last_status = 'OPEN' and (WillTheyBuyN ne 0 or BuyerExperienceWithHPN ne 0 or ClientRelationshipAndInsightN ne 0 or CompetitivePositionN ne 0
   or ClientDecisionProcessN ne 0 or SolutionScopeN ne 0 or DefferentationN ne 0 or TeamingN ne 0 or SalesTeamStaffingN ne 0 
   or DealShapeandPricingN ne 0 or DeliveryLeadershipTeamN ne 0 or TermsAndConditionsN ne 0) then output dhc&today_date.;
	else if Last_status = 'OPEN' and deal_type='Renewal' then output Renewal&today_date.;
	else if Last_status = 'OPEN' and deal_type in('Add-On','New') then output Add_new&today_date.;
	else output won&today_date.;

run;	

/********************************************************************************************************************/
/*** Create a temporary flag for missing AMS_ASL for DHC data and use a similar coefficient for scoring           ***/
/********************************************************************************************************************/
data dhc&today_date.;
	set dhc&today_date.;

	if ams_asl = 'OneHP' then do; ams_asl = 'Canada'; flag=7; end;
	if ams_asl = 'NULL' then do; ams_asl = 'Canada'; flag=9; end;
run;

Proc sort data=Renewal&today_date. out=renewal;
	by deal_type ams_asl prodline;
Proc sort data=Add_new&today_date. out=Add_new;
	by deal_type ams_asl prodline;
Proc sort data=dhc&today_date. out=dhc;
	by deal_type ams_asl;
run;


/*****************************************************************/
/*** Score the open opportunities                              ***/
/*****************************************************************/

PROC logistic inmodel=test.outmodel_add_new;
	by deal_type;
	score data=Add_new out=Add_new_scores&today_date.;
PROC logistic inmodel=test.outmodel_renewal;
	score data=renewal out=renewal_scores&today_date.;
PROC logistic inmodel=dhc.outmodel_dhc;
	score data=dhc out=dhc_scores&today_date.;
run;



proc sort data= Add_new_scores&today_date. out=Add_new;
	by deal_type ams_asl prodline;
proc sort data= renewal_scores&today_date. out=renewal;
	by deal_type ams_asl prodline;
Proc sort data=dhc_scores&today_date. out=dhc;
	by deal_type ams_asl;
run;

/***************************************************************************************************/
/*** Combine three datasets contain open deals into a single dataset called open               ***/
/***************************************************************************************************/

proc append base=Add_new data=renewal force;
run;
proc append base=Add_new data=dhc force;
run;


proc sort data= Add_new out=open;
	by deal_type ams_asl;
run;

/***************************************************************************************************/
/*** Combine maxdays dataset to open deals for calculating days to red variable                  ***/
/*** Rename the ams_asl and prodline to their original values                                    ***/
/***************************************************************************************************/
proc sort data= test.new_maxdays out=maxdays;
	by deal_type;
run;


data open;
	merge maxdays open(in=ina);
	by deal_type;
	if flag = 1 then ams_asl = 'NULL';
	if flag = 2 then ams_asl = 'P&G';
	if flag = 3 then prodline = 'aboanalys';
	if flag = 4 then prodline = 'secser';
	if flag = 5 then prodline = 'entcloud';
	if flag = 6 then ams_asl = 'Unassigned';
	if flag = 7 then ams_asl = 'OneHP';
	if flag = 8 then prodline = 'bpopryrol';
	if flag = 9 then ams_asl = 'NULL';
	if flag = 10 then ams_asl = 'NULL';

	if p_1 <= .5 then daystored = 0;
	if ina;
	if p_1 > .99 then p_1 = .99;
	if p_1 < .01 then p_1 = .01;
run;

/***********************************************************************************************/
/*** Calculate days to red variable using coefficients of days in each stage and max days    ***/
/***********************************************************************************************/

data open_temp (keep = deal_type maxdays opportunity_id current_stage start_stage P_1 daystored daysinall);
	set open;
	if current_sales_stage = '01 - Understand Customer' then current_stage='s01';
	else if current_sales_stage = '02 - Validate Opportunity' then current_stage='s02';
	else if current_sales_stage = '03 - Qualify the Opportunity' then current_stage='s03';
	else if current_sales_stage = '04A - Develop Solution' then current_stage='s04a';
	else if current_sales_stage = '04B - Propose Solution' then current_stage='s04b';
	else current_stage='s05';

	if ststg1=1 then start_stage='ststg1';
	if ststg2=1 then start_stage='ststg2';
	if ststg3=1 then start_stage='ststg3';
	if ststg4a=1 then start_stage='ststg4a';
	if ststg4b=1 then start_stage='ststg4b';
	if ststg5=1 then start_stage='ststg5';
	if ststg0=1 then do; 
		if current_sales_stage = '01 - Understand Customer' then start_stage= 'ststg1';
		else if current_sales_stage = '02 - Validate Opportunity' then start_stage= 'ststg2';
		else if current_sales_stage = '03 - Qualify the Opportunity' then start_stage= 'ststg3';
		else if current_sales_stage = '04A - Develop Solution' then start_stage= 'ststg4a';
		else if current_sales_stage = '04B - Propose Solution'  then start_stage= 'ststg4b';
		else start_stage= 'ststg5';
	end;

run;


proc sql;
create table open_cal as (
select a.deal_type, a.maxdays, a.opportunity_id, a.current_stage, a.P_1, a.daystored, a.daysinall, b.coeff_final
from open_temp a left outer join test.coeff_new_model b 
	on a.deal_type=b.deal_type
	and a.current_stage=b.stage
	and a.start_stage=b.ststg)
;
quit;

data open_cal2;
	set open_cal;
	if P_1 <= 0.5 then daystored = 0;
	if P_1>0.5 and coeff_final<0 then daystored1= (log((1 - P_1)/P_1))/coeff_final;
	if P_1>0.5 and coeff_final>0 then daystored1= maxdays - daysinall;
	if daystored1>0	then daystored = ceil(daystored1);
	if daystored1<0 then daystored = 0;
run;


proc sql;
update open a
	set daystored= (select daystored 
					from open_cal2 b 
					where a.opportunity_id=b.opportunity_id);
quit;

/************************************************************************/
/*** Merge open and won deals to final dataset.                       ***/
/************************************************************************/

data won;
	set won&today_date.;
	P_1=1;
	P_0=0;

data velocity.scored&today_date.;
	set open won;
	drop flag;

RUN;
QUIT;

ods graphics off;
