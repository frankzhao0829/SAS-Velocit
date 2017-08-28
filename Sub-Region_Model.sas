LIBNAME test "/var/blade/data2031/esiblade/zchunyou/Velocity/test";
LIBNAME forecast "/var/blade/data2031/esiblade/zchunyou/Velocity/forecast"; 

Data MLE_test Unmapped_test Firth_test EMIME_SLA_test HH_PB_test dhc_test;
	set test.velocity_model_v3; 

	format contract_length sold ststg1 ststg2 ststg3 ststg4a ststg4b ststg5 dealsize 8.;
	

	if status = 'Won' then sold=1;
	else sold=0;

	tcv___m_ = total_opportunity_value___m_;


	dealsize=0;
	     if TCV___M_ > 25 then dealsize = 2;
	else if TCV___M_ > 10 then dealsize = 1;
	else if TCV___M_ >  0 then dealsize = 0;
	else if TCV___M_ =  0 then delete;
	else delete;

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

	*if AMID2_FIRST_WIN = '.' then AMID2_FIRST_WIN = '17may2011'd;
	longevity='19may2014'D - AMID2_FIRST_WIN;
    *if longevity="." then longevity= 1095;
	*if AMID2_LAST_WIN = '.' then AMID2_LAST_WIN = '17may2011'd;
	recency='19may2014'D - AMID2_LAST_WIN;
	*if recency="." then recency= 1095;

	*if deal_type in ('Add-On') and ams_asl='NULL' then ams_asl='US - EMIME';
	*if deal_type in('New') and ams_asl='P&G' then ams_asl='US - Healthcare-Gvt HHS';

	if ams_asl = 'Canada-Combined' then ams_asl = 'Canada';
	if ams_asl = 'LA - Brazil' then ams_asl = 'Brazil';

			array maxtcv(13) 
			Apps_Cloud__Mobility_and_Tr_0001 
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

	if ams_asl in ('BofA', 'Bofa', 'bofa', 'US - FIN SVCS', 'US - Fin Svcs') then ams_asl = 'US - FIN Svcs';
	else if ams_asl in ('Do Not Map', 'Unassigned', 'NULL') then ams_asl = 'Unmapped';
	else if ams_asl = 'us - com' then ams_asl = 'US - COM';

	if ams_asl = 'Brazil' and prodline = 'commsol' then prodline = 'bpocards';
    else if ams_asl in ('OneHP','US - COM') and prodline = 'bpoanalys' then prodline = 'bpocards'; 
	else if ams_asl = 'SLA' then do;
		if prodline = 'bpoanalys' then prodline = 'secser';
		if prodline = 'bpocards' then prodline = 'bpopryrol';
		if prodline = 'commsol' then prodline = 'informgmt'; end;
/*	else if ams_asl = 'US - HC CP&LS' then do;
		if prodline = 'bpoanalys' then prodline = 'bpocards';
		if prodline in ('commsol','bpopryrol') then prodline = 'informgmt';end;
	else if ams_asl = 'US - Healthcare-Gvt HHS' then do;
		if prodline = 'appsdev' then prodline = 'entappser'; 
		if prodline = 'informgmt' then prodline = 'secser';
		if prodline = 'dcntrserv' then prodline = 'bpocards'; end; */
	else if ams_asl = 'Unmapped' then do;
		if prodline = 'bpoanalys' then prodline = 'bpocards';
		if prodline = 'bpopryrol' then prodline = 'informgmt';
		if prodline = 'entcloud' then prodline = 'entappser'; end;
	else if ams_asl in ('US - Cons & Trans','US - EMIME') and prodline = 'commsol' then prodline = 'informgmt';
	else if ams_asl = 'Canada' and prodline = 'bpoanalys' then prodline = 'commsol';


	if ams_asl in ('OneHP','US - COM') then ams_asl = 'OneHP & US - COM';
	*if ams_asl = 'P&G' then deal_type = 'Add-On';

	if WillTheyBuyN ne 0 or BuyerExperienceWithHPN ne 0 or ClientRelationshipAndInsightN ne 0 or CompetitivePositionN ne 0 
       or SolutionScopeN ne 0 then dhc_flag=1; 

	*if dhc_flag = 1 then delete;

	number_moves = 0; moveto02 = 0; moveto03 = 0; moveto04a = 0; moveto04b = 0; moveto05= 0;

	if daysin01 > 0 and daysin02 > 0 then moveto02 = 1;
	if (daysin01 > 0 or daysin02 > 0) and daysin03 > 0 then moveto03 = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 ) and daysin04a > 0 then moveto04a = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0) and daysin04b > 0 then moveto04b = 1;
	if (daysin01 > 0 or daysin02 > 0 or daysin03 > 0 or daysin04a > 0 or daysin04b > 0) and daysin05 > 0 then moveto05 = 1;

	number_moves = moveto02 + moveto03 + moveto04a + moveto04b + moveto05;


	if Sales_Motion in ('Motion 01 - Regional Backlog','Motion 03 - Global Strategic Megadeals')
	then Sales_Motion = 'Motion 04 - Proactive Revenue';

	Add_identifier=0;
	if deal_type='Add-On' then Add_identifier=1;

	
	*else if total_opportunity_value___m_<0.000001 or total_opportunity_value___m_>250 then delete;
	DHC_predictors= WillTheyBuyN + BuyerExperienceWithHPN + ClientRelationshipAndInsightN + CompetitivePositionN+SolutionScopeN; 
	
	keep daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg1 ststg2 ststg3 ststg4a ststg4b ststg5 ststg deal_type 
		 ams_asl sold contract_length longevity recency tcv___m_ proline prodline highest_val ES_TCV___M_ Sales_Motion 
		 number_moves moveto02 moveto03 moveto04a moveto04b moveto05 Add_identifier DHC_predictors  ;

	*if sign_qtr = 'FY2014Q2' then delete; 
	if dhc_flag = 1 then output dhc_test;
	else if ams_asl = 'US - Cons & Trans' then output MLE_test; 
	else if ams_asl = 'Unmapped' then output Unmapped_test;
	else if ams_asl in ('US - EMIME','SLA') then output EMIME_SLA_test;
	else if ams_asl in ('US - HC CP&LS','US - Healthcare-Gvt HHS','P&G','Brazil') then output HH_PB_test;
	else output Firth_test; 
run;


/*
proc freq data=MLE_test;
	table ams_asl*prodline*sold / nocol norow nopercent;
proc freq data=Firth_test;
	table ams_asl*prodline*sold / nocol norow nopercent;
proc freq data=MLE_test;
	table ams_asl*Deal_Type*sold / nocol norow nopercent;
proc freq data=Firth_test;
	table ams_asl*Deal_Type*sold / nocol norow nopercent;
proc freq data=Brazil_PG_test;
	table ams_asl*prodline*sold / nocol norow nopercent;
proc freq data=HC_Health_test;
	table ams_asl*Deal_Type*sold / nocol norow nopercent;
proc freq data=dhc_test;
	table ams_asl*Deal_Type*sold / nocol norow nopercent;
run;
*/
proc sort data=MLE_test;
	by ams_asl deal_type prodline;
run;

*ods results off;
ods graphics on;
PROC logistic data=MLE_test plots(only)=(roc) outmodel=outmodel_MLE; 
	by ams_asl; 
	class deal_type ams_asl prodline Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion
							contract_length deal_type ams_asl tcv___m_ prodline number_moves / stb lackfit ;	
run;

PROC logistic data=Firth_test plots(only)=(roc) outmodel=outmodel_Firth; 
	class deal_type ams_asl prodline Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion	
							contract_length deal_type ams_asl tcv___m_ prodline number_moves/ stb lackfit firth clparm=pl;	
run;

PROC logistic data=Unmapped_test plots(only)=(roc) outmodel=outmodel_Unmapped; 
	class deal_type ams_asl prodline Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion
							contract_length deal_type ams_asl tcv___m_ prodline/stb lackfit ;	
run;

PROC logistic data=EMIME_SLA_test plots(only)=(roc) outmodel=outmodel_EMIME_SLA; 
	class deal_type ams_asl prodline Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion
							contract_length deal_type ams_asl tcv___m_ prodline number_moves/ stb lackfit firth clparm=pl;	
run;

PROC logistic data=HH_PB_test plots(only)=(roc) outmodel=outmodel_HH_PB; 
	class deal_type ams_asl prodline Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion
							contract_length deal_type ams_asl tcv___m_ prodline number_moves/ stb lackfit firth clparm=pl;	
run;

PROC logistic data=dhc_test plots(only)=(roc) outmodel=outmodel_dhc; 
	class deal_type ams_asl Sales_Motion/ param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg Add_identifier*Sales_Motion
							contract_length deal_type ams_asl tcv___m_ DHC_predictors number_moves/stb lackfit;	
run;
ods graphics off; 
*ods results on;

