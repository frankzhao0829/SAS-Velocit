LIBNAME velocity "/var/blade/data2031/esiblade/zchunyou/Velocity/Data";
LIBNAME vel_old "/var/blade/data2031/esiblade/Velocity/Data";


/***************************************************************************************************/
/*** Create macro variable today_date in DDMMMYYYY format to automate SAS program                ***/
/***************************************************************************************************/
%let today_date = %sysfunc(date(),DATE9.);
%put &today_date.;


Data velocity.i&today_date.;
	set velocity.i&today_date.;
	rename status=Last_status;
run;


Data velocity.open&today_date. velocity.won&today_date.;
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

/***************************************************************************************************/
/*** Calculate longevity and recency from first and last win dates                               ***/
/***************************************************************************************************/

	longevity="&today_date."D - amid2_first_win;
	if longevity="." then longevity=0;
	recency="&today_date."D - amid2_last_win;
	if recency="." then recency=0;

/***************************************************************************************************/
/*** Create a temporary flag for missing AMS-ASL and use a medium AMS-ASL for scoring            ***/
/***************************************************************************************************/

	if ams_asl = '.' then do;
		flag = 'am';
		ams_asl = 'SLA';
	end;

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

/***************************************************************************************************/
/*** Calculate flyin and cal_days based on old QV data model           ***/
/***************************************************************************************************/

if win_loss_qtr=created_qtr then flyin=1;
	else flyin=0;
if win_loss_date>created_date then cal_days=created_date - win_loss_date;
	else cal_days=created_date - close_date;


/***************************************************************************************************/
/*** Create a temporary flag for missing AMS-ASL and use a medium AMS-ASL for scoring            ***/
/***************************************************************************************************/

if Last_status = 'OPEN' then output velocity.open&today_date.;
	else output velocity.won&today_date.;


run;	

Proc sort data=velocity.open&today_date. out=open;
	by deal_type ams_asl;
run;

ods graphics on; 

/***************************************************************************************************/
/*** Score the open opportunities                                                                ***/
/***************************************************************************************************/

PROC logistic inmodel=vel_old.outmodel;
	by deal_type;
	score data=open out=velocity.scores&today_date.;
run;

proc sort data= velocity.scores&today_date. out=open;
	by deal_type ams_asl;
run;

/***************************************************************************************************/
/*** Merge open deals with file containing 2(avg+std dev) by deal type and ams asl               ***/
/***************************************************************************************************/

proc sort data= vel_old.maxdays out=maxdays;
	by deal_type ams_asl;
run;


data open;
	merge maxdays open(in=ina);
	by deal_type ams_asl;
	if flag = 'am' then ams_asl = 'Blended';
	daystored = maxdays - daysinall;
	if daystored < 0 then daystored = 0;
	if p_1 <= .5 then daystored = 0;
	if ina;
	if p_1 > .99 then p_1 = .99;
	if p_1 < .01 then p_1 = .01;
run;

/*************************************************************************************************************/
/*** Calculate daystored variable for deals that has P_1>0 and coefficient of daysin(current stage)<0      ***/
/*************************************************************************************************************/

/***Note: Run this part of code only when there is a change in logistic regression model
		  velest is the output of the coefficients of logistic regression model
data velocity.coeff (keep= deal_type stage coeff);
	set velest;
		array salesstage(6)
			daysin01
			daysin02
			daysin03
			daysin04a
			daysin04b
			daysin05;
		array numstage{6} $ a1-a6 ('s01','s02','s03','s04a','s04b','s05');
		do i = 1 to 6;
			stage=numstage(i);
			coeff=salesstage(i);
			output;
		end;
run;
**************************************************************************************/

data open_temp (keep = deal_type maxdays opportunity_id current_stage P_1 daystored);
	set open;
	if current_sales_stage = '01 - Understand Customer' then current_stage='s01';
	if current_sales_stage = '02 - Validate Opportunity' then current_stage='s02';
	if current_sales_stage = '03 - Qualify the Opportunity' then current_stage='s03';
	if current_sales_stage = '04A - Develop Solution' then current_stage='s04a';
	if current_sales_stage = '04B - Propose Solution' then current_stage='s04b';
	if current_sales_stage = '05 - Negotiate & Close' then current_stage='s05';
run;


proc sql;
create table open_cal as (
select a.deal_type, a.maxdays, a.opportunity_id, a.current_stage, a.P_1, a.daystored, b.coeff
from open_temp a left outer join velocity.coeff b 
	on a.deal_type=b.deal_type
	and a.current_stage=b.stage)
;
quit;

data open_cal2;
	set open_cal;
	if P_1>0.5 and coeff<0
		then daystored1= (log((1 - P_1)/P_1))/coeff;
	if daystored1>0
		then daystored=ceil(daystored1);
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
	set velocity.won&today_date.;
	P_1=1;
	P_0=0;

data velocity.scored&today_date.;
	set open won;
	drop flag;

RUN;
QUIT;

ods graphics off;
