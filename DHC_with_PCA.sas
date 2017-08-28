LIBNAME dhc "/var/blade/data2031/esiblade/zchunyou/Velocity/DHC";
LIBNAME test "/var/blade/data2031/esiblade/zchunyou/Velocity/test";


Data dhc_model (keep=daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg ststg1 ststg2 ststg3 ststg4a ststg4b 
					 ststg5 deal_type ams_asl sold contract_length tcv___m_  DHC_Predictors DHC_Closers LS_Identifier stagenum);
	set dhc.DHC_Model_V3; 
	
	format contract_length sold 8.;
	
		 if status = 'WON' then sold=1;
	else if status = 'OPEN' then delete;
	else sold=0;

	tcv___m_ = total_opportunity_value___m_;

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

	*if ams_asl='P&G' then ams_asl='US - Healthcare-Gvt HHS';
	*if ams_asl='NULL' then ams_asl='US - EMIME';

	if ams_asl = 'Canada-Combined' then ams_asl = 'Canada';
	if ams_asl = 'LA - Brazil' then ams_asl = 'Brazil';

	if ams_asl='OneHP' then ams_asl='US - COM';
	if ams_asl in ('US - Other','not us') then ams_asl = 'Unmapped';

DHC_predictors= WillTheyBuyN + BuyerExperienceWithHPN + ClientRelationshipAndInsightN + CompetitivePositionN+SolutionScopeN;
DHC_Closers= ClientDecisionProcessN + DefferentationN + TeamingN + SalesTeamStaffingN + DealShapeandPricingN + 
			 DeliveryLeadershipTeamN + TermsAndConditionsN;

LS_identifier=1;
if IncludeDaysES=1 and IncludeDaysLS=0 then LS_Identifier=0;

run;


data dhc_model_v3;
	set dhc_model;

	LS_identifier=1;
	if IncludeDaysES=1 and IncludeDaysLS=0 then LS_Identifier=0;
	daysines=daysin01+daysin02+daysin03;
	ststges=ststg1+ststg2+ststg3;
	ststgls=ststg4a+ststg4b+ststg5;

	if tcv___m_ <= 0.000001 then delete;

	moveto02 = 0; moveto03 = 0; moveto04a = 0; moveto04b = 0; moveto05= 0;

	if daysin01 > 0 and daysin02 > 0 then moveto02 = 1;
	if (daysin01 > 0 or daysin02 > 0) and daysin03 > 0 then moveto03 = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 ) and daysin04a > 0 then moveto04a = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0) and daysin04b > 0 then moveto04b = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0 or daysin04b > 0) and daysin05 > 0 then moveto05 = 1;
	
	number_moves = moveto02 + moveto03 + moveto04a + moveto04b + moveto05;
run;



/*
data dhc_model_factor;
	set dhc_model_v3;
	drop IncludeDaysES IncludeDaysLS LS_identifier daysines stagenum ststges ststgls sold;
run;

data dhc_model_factor2;
	set dhc_model_v3;
	keep DHC_predictors DHC_Closers ;
run;
*/

proc factor data=dhc_model_v3 outstat=FAstat msa score;
	var DHC_predictors DHC_Closers;
run;

proc score data=dhc_model_v3 score=FAstat out=dhc_model_scores ;
	var DHC_predictors DHC_Closers;
run;

proc sql;
create table dhc_model_test as 
select *, min(Factor1) as MIN_DHC, max(Factor1) as MAX_DHC
from dhc_model_scores;
quit;

data dhc_model_test (drop= IncludeDaysES IncludeDaysLS);
	set dhc_model_test;
	DHC_Score = 0 + (20 - 0) * (Factor1 - MIN_DHC) / (MAX_DHC - MIN_DHC);

	LS_identifier = 0;
	if Daysin04a + Daysin04b + Daysin05 > 0 then LS_identifier = 1;
	ES_identifier = 1 - LS_identifier;
run;


Proc sort data=dhc_model_test;
	by deal_type ams_asl;
run;


ods graphics on;
PROC logistic data=dhc_model_test plots(only)=(roc oddsratio(range=clip))
						/* outest=test.VelEst_dhc outmodel=dhc.outmodel_dhc*/;  
	class deal_type ams_asl/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05	ststg1 ststg2 ststg3 ststg4a ststg4b contract_length 
							deal_type tcv___m_ ams_asl number_moves moveto02*number_moves moveto03*number_moves moveto04a*number_moves 
							moveto04b*number_moves moveto05*number_moves DHC_predictors*ES_identifier DHC_Score*LS_identifier/firth stb lackfit clparm=pl;
RUN;
QUIT;
ods graphics off;




