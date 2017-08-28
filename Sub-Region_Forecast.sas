/*
LIBNAME velocity "/var/blade/data2031/esiblade/zchunyou/Velocity/Data"; 
LIBNAME test "/var/blade/data2031/esiblade/zchunyou/Velocity/test"; 
LIBNAME dhc "/var/blade/data2031/esiblade/zchunyou/Velocity/DHC"; 
LIBNAME forecast "/var/blade/data2031/esiblade/zchunyou/Velocity/forecast"; 
*/
/*
%macro forecast_Subregion_Q2;
	%do week_num = 15 %to 27;
*/
%let week_num = 25;
/***************************************************************************************************/ 
/*** Rename to match current QV data models                                                      ***/ 
/***************************************************************************************************/ 
Data  week&week_num.; 
	set  forecast.week&week_num.(rename=(AMS_ASL=ams_asl)); 
	rename status=Last_status; 
run; 

Data dhc_week&week_num. MLE_week&week_num. Unmapped_week&week_num. EMIME_SLA_week&week_num. HH_PB_week&week_num. Firth_week&week_num. won_week&week_num.; 
	set  week&week_num.; 
 
	format contract_length ststg1 ststg2 ststg3 ststg4a ststg4b ststg5 8.; 
	format Deal_Size $ 15.;
/***************************************************************************************************/ 
/*** Rename to perform data cleansing and to match QV code                                       ***/ 
/***************************************************************************************************/ 
 	
	tcv___m_ = total_opportunity_value___m_; 

	if Last_status in ('Won','won') then Last_status = 'WON';
	if Last_status in ('Open','open') then Last_status = 'OPEN';

	if ams_asl in ('not us','LA - Mexico','US - Other','Do Not Map','NULL','xUS - Other') then ams_asl='Unmapped'; 
 	if ams_asl = 'Canada-Combined' then ams_asl = 'Canada'; 
	if ams_asl = 'LA - Brazil' then ams_asl = 'Brazil'; 
	if ams_asl in ('US - Fin Svcs', 'US - FIN SVCS', 'BofA','Bofa','us - FIN Svcs') then ams_asl = 'US - FIN Svcs';
	if ams_asl = 'us - com' then ams_asl = 'US - COM';
	if ams_asl = 'General Motors' then ams_asl = 'US - EMIME';
  	
	if ES_TCV___M_ < 10 then Deal_Size = '<$10M';
	else Deal_Size = '$10M and above';

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
 
	DaysinALL= daysin01 + daysin02 + daysin03 + daysin04a + daysin04b + daysin05; 
 
	if Updated_ES_FFYR < 0 then Updated_ES_FFYR = Updated_ES_FFYR*(-1);
	if ES_FFYR___M_ < 0 then ES_FFYR___M_ = ES_FFYR___M_*(-1);
	if Total_FFYR___M_ < 0 then Total_FFYR___M_ = Total_FFYR___M_*(-1);
/***************************************************************************************************/ 
/*** find primary product line by highest TCV per product line                                   ***/ 
/***************************************************************************************************/ 
 
		array maxtcv(13)  
 			Apps_Cloud__Mobility_and_Transfo 
			Apps_Development_and_Management	 
			BPO_CRM__Cards_and_Payment_TCV__	 
			BPO_DPS__F_L_and_Analytics_TCV__	 
			BPO_F_A__HR_and_Payroll_TCV___M_	 
			Communications_Solutions_TCV___M	 
			Data_Center_Services_TCV___M_	 
			Enterprise_Applications_Services	 
			Enterprise_Cloud_Services_TCV___	 
			Information_Management_and_Analy	 
			Network_Services_TCV___M_	 
			Security_Services_TCV___M_	 
			Workplace_Services_TCV___M_; 
 

/*			Apps_Cloud__Mobility_and_Tr_0001 
			Apps_Development_and_Manage_0001 
			BPO_CRM__Cards_and_Payment_TCV__ 
			BPO_DPS__F_L_and_Analytics_TCV__ 
			BPO_F_A__HR_and_Payroll_TCV___M_ 
			Communications_Solutions_TCV___M 
			Data_Center_Services_TCV___M_ 
			Enterprise_Applications_Ser_0001 
			Enterprise_Cloud_Services_TCV___ 
			Information_Management_and_0001 
			Network_Services_TCV___M_ 
			Security_Services_TCV___M_ 
			Workplace_Services_TCV___M_; 
*/
		do i=1 to 13; 
			if maxtcv(i)>highest_val then do; 
				highest_val=maxtcv(i); 
				proline=i; 
			end; 
		end; 
 
     if proline = 1 then prodline='appscloud'; 
else if proline = 2 then prodline='appsdev'; 
else if proline = 3 then prodline='bpocards'; 
else if proline = 4 then prodline='bpoanalys'; 
else if proline = 5 then prodline='bpopryrol'; 
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
	PL_flag = 0;

	if ams_asl = 'Brazil' and prodline = 'commsol' then do; prodline = 'bpocards'; PL_flag=6; end;
    else if ams_asl in ('OneHP','US - COM') and prodline = 'bpoanalys' then do; prodline = 'bpocards'; PL_flag=4; end;
	else if ams_asl = 'Unmapped' then do;
		if prodline = 'bpoanalys' then do; prodline = 'bpocards'; PL_flag=4; end; 
		if prodline = 'bpopryrol' then do; prodline = 'informgmt'; PL_flag=5; end;
		if prodline = 'entcloud' then do; prodline = 'entappser'; PL_flag=9; end; end;
	else if ams_asl in ('US - Cons & Trans','US - EMIME') and prodline = 'commsol' then do; prodline = 'informgmt'; PL_flag=6; end;
	else if ams_asl = 'Canada' and prodline = 'bpoanalys' then do; prodline = 'commsol'; PL_flag=4; end;
	else if ams_asl = 'P&G' then do;
		if prodline = 'bpoanalys' then do; prodline = 'bpopryrol'; PL_flag=4; end;
		if prodline = 'bpocards' then do; prodline = 'bpopryrol'; PL_flag=3; end;
		if prodline = 'commsol' then do; prodline = 'bpopryrol'; PL_flag=6; end; end;
		
	flag = 0;
	if ams_asl = 'OneHP' then flag = 1;
	else if ams_asl = 'US - COM' then flag = 2;

	if Last_status = 'OPEN' and ams_asl in ('OneHP','US - COM') then ams_asl = 'OneHP & US - COM';
	if ams_asl = 'P&G' then deal_type = 'Add-On';

/****************************************************************************************************************/ 
/*** Create New and Add-On deals identifier to force longevity and recency equal to 0 for New deals           ***/ 
/****************************************************************************************************************/
	if Sales_Motion in ('Motion 01 - Regional Backlog','Motion 03 - Global Strategic Megadeals')
	then Sales_Motion = 'Motion 02 - Reactive Revenue';

	Add_identifier=0;
	if deal_type='Add-On' then Add_identifier=1;

	if WillTheyBuyN = 5 then WillTheyBuyN = 0;
	else if WillTheyBuyN = 3 then WillTheyBuyN = -2;
	else if WillTheyBuyN = 1 then WillTheyBuyN = -4;

	dhc_flag=0;
	if WillTheyBuyN ne 0 or BuyerExperienceWithHPN ne 0 or ClientRelationshipAndInsightN ne 0 
	   or CompetitivePositionN ne 0 or SolutionScopeN ne 0 then dhc_flag=1; 

	DHC_predictors= WillTheyBuyN + BuyerExperienceWithHPN + ClientRelationshipAndInsightN + CompetitivePositionN+SolutionScopeN; 

	if ams_asl = 'US - Healthcare-Gvt HHS' and dhc_flag=1 then do; ams_asl = 'US - FIN Svcs'; flag = 3; end;

/****************************************************************************************************************/ 
/*** Calculate Number of stage movements and move to each stages variables                                    ***/ 
/****************************************************************************************************************/
    number_moves = 0; moveto02 = 0; moveto03 = 0; moveto04a = 0; moveto04b = 0; moveto05= 0;
	if daysin01 > 0 and daysin02 > 0 then moveto02 = 1;
	if (daysin01 > 0 or daysin02 > 0) and daysin03 > 0 then moveto03 = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 ) and daysin04a > 0 then moveto04a = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0) and daysin04b > 0 then moveto04b = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0 or daysin04b > 0) and daysin05 > 0 then moveto05 = 1;

	number_moves = moveto02 + moveto03 + moveto04a + moveto04b + moveto05;

	if daysin01 + daysin02 + daysin03 > 0 then IncludeDaysES=1;
	else IncludeDaysES = 0;
	if daysin04a + daysin04b + daysin05 > 0 then IncludeDaysLS=1;
	else IncludeDaysLS = 0;

	LS_identifier=1; 
	if IncludeDaysES=1 and IncludeDaysLS=0 then LS_Identifier=0; 

	if Close_QTR ne 'FY2014Q2' then delete;

	if Last_status = 'OPEN' and dhc_flag = 1 then output dhc_week&week_num.;
 	else if Last_status = 'OPEN' and ams_asl = 'US - Cons & Trans' then output MLE_week&week_num.; 
 	else if Last_status = 'OPEN' and ams_asl='Unmapped' then output Unmapped_week&week_num.; 
	else if Last_status = 'OPEN' and ams_asl in ('US - EMIME','SLA') then output EMIME_SLA_week&week_num.;
	else if Last_status = 'OPEN' and ams_asl in ('US - HC CP&LS','US - Healthcare-Gvt HHS','P&G','Brazil') then output HH_PB_week&week_num.;
	else if Last_status = 'OPEN' then output Firth_week&week_num.;
    if Last_status = 'WON' then output won_week&week_num.; 
run;	 

/*****************************************************************/ 
/*** Score the open opportunities                              ***/ 
/*****************************************************************/ 
proc sort data= Firth_week&week_num.; 
	by ams_asl deal_type prodline; 
run; 

PROC logistic inmodel=outmodel_dhc; 
	score data=dhc_week&week_num. out=dhc; 
PROC logistic inmodel=outmodel_MLE; 
	by ams_asl;
	score data=MLE_week&week_num. out=MLE; 
PROC logistic inmodel=outmodel_Unmapped; 
	score data=Unmapped_week&week_num. out=Unmapped; 
PROC logistic inmodel=outmodel_EMIME_SLA; 
	score data=EMIME_SLA_week&week_num. out=EMIME_SLA; 
PROC logistic inmodel=outmodel_HH_PB; 
	score data=HH_PB_week&week_num. out=HH_PB;
PROC logistic inmodel=outmodel_Firth; 
	score data=Firth_week&week_num. out=Firth; 
run;

/***************************************************************************************************/ 
/*** Append all other datasets that contain open deals to MLE data set                           ***/ 
/***************************************************************************************************/ 

proc append base=MLE data=Unmapped force; run;
proc append base=MLE data=EMIME_SLA force; run;
proc append base=MLE data=HH_PB force; run;
proc append base=MLE data=Firth force; run; 
proc append base=MLE data=dhc force; run; 


/****************************************************************************************************/ 
/*** Combine won deals with remaining open deals and calculate subtotal FFYR for each sub-region  ***/ 
/****************************************************************************************************/
data won;
	set won_week&week_num.;
	P_1=1;
	P_0=0;
	if Close_QTR = 'FY2014Q2' then output;
run;

data scoredweek&week_num.; 
	set MLE won; 

	if flag = 1 then ams_asl = 'OneHP';
	else if flag = 2 then ams_asl = 'US - COM';
	else if flag = 3 then ams_asl = 'US - Healthcare-Gvt HHS'; 

	if P_1 > 0.5 then Converted_P = 1;
	else if P_1 < 0.5 then Converted_P = 0;

	Factored_Value = P_1*Updated_ES_FFYR;

	drop flag PL_flag;
RUN; 

proc sort data=scoredweek&week_num.; 
by Deal_Size ams_asl;
run;


data  scoredweek&week_num.;
	set scoredweek&week_num.;

	by Deal_Size ams_asl;
	if first.ams_asl then Factored_FFYR = 0; 

	Factored_FFYR + Factored_Value;
run;

data forecast_Subregion_week&week_num. (keep= Snapshot Deal_Size ams_asl Week_num Factored_FFYR);
	set scoredweek&week_num.;
	by Deal_Size ams_asl;
	Week_num = "Week&week_num.";
	if last.Deal_Size = 1 or last.ams_asl = 1 then output;
run;
/*
%end;
%mend forecast_Subregion_Q2;

%forecast_Subregion_Q2;
*/

data forecast_output_Subregion_q2;
	set forecast_Subregion_week&week_num.;
run;

/*
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week16 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week17 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week18 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week19 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week20 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week21 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week22 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week23 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week24 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week25 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week26 force;
run;
proc append base= forecast_output_Subregion_q2 data=forecast_Subregion_week27 force;
run;
*/

proc sql;
create table Output_Subregion as 
select Week_num, ams_asl, sum(Factored_FFYR) as Predicted_FFYR
from forecast_output_Subregion_q2
group by Week_num, ams_asl;
quit;
