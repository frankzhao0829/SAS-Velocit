

data flyin_test1;
	set flyin_test (rename=(AMS_ASL=ams_asl));
	rename status=Last_status; 
run;

Data flyin_char; 
	set flyin_test1; 
 
	format contract_length ststg1 ststg2 ststg3 ststg4a ststg4b ststg5 8.; 
	format daysinall_char $ 30.;
/***************************************************************************************************/ 
/*** Rename to perform data cleansing and to match QV code                                       ***/ 
/***************************************************************************************************/ 
 	
	tcv___m_ = total_opportunity_value___m_; 

	if Last_status in ('Won','won') then Last_status = 'WON';
	if Last_status in ('Open','open') then Last_status = 'OPEN';

	if ams_asl in ('not us','LA - Mexico','US - Other','Do Not Map','NULL','Unassigned','xUS - Other') then ams_asl='Unmapped'; 
 	if ams_asl = 'Canada-Combined' then ams_asl = 'Canada'; 
	if ams_asl = 'LA - Brazil' then ams_asl = 'Brazil'; 
	if ams_asl in ('US - Fin Svcs', 'US - FIN SVCS', 'BofA','Bofa','bofa','us - FIN Svcs') then ams_asl = 'US - FIN Svcs';
	if ams_asl = 'us - com' then ams_asl = 'US - COM';
	if ams_asl = 'General Motors' then ams_asl = 'US - EMIME';
  
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
 
 	ststg_ls = ststg4a + ststg4b + ststg5;
	ststg_es = ststg1 + ststg2 + ststg3;

/***************************************************************************************************/ 
/*** find primary product line by highest TCV per product line                                   ***/ 
/***************************************************************************************************/ 
 
		array maxtcv(13)  
 /*			Apps_Cloud__Mobility_and_Transfo 
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
 */

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
else if proline = 4 then prodline='aboanalys'; 
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
/*
	if deal_type in ('New','Renewal') and ams_asl = 'P&G' then do;
		ams_asl = 'US - Cons & Trans'; flag = 1; end;

	if deal_type='Renewal' and prodline='aboanalys' then do;
		prodline='appscloud'; flag = 2; end;
	if deal_type='Renewal' and  prodline='secser' then do;
		prodline='appscloud'; flag = 3; end;
	if deal_type='Renewal' and  prodline='entcloud' then do;
		prodline='commsol'; flag = 4; end;
	if deal_type='New' and prodline='bpopryrol' then do;
		prodline='commsol'; flag = 8; end;
*/
	if deal_type='Add-On' and Sales_Motion='Motion 01 - Regional Backlog' then do;
		Sales_Motion='Motion 04 - Proactive Revenue'; flag = 6; end;
	if deal_type='New' and Sales_Motion='Motion 02 - Reactive Revenue' then do;
		Sales_Motion='Motion 04 - Proactive Revenue'; flag = 7; end;
	if deal_type='New' and Sales_Motion='Motion 01 - Regional Backlog' then do;
		Sales_Motion='Motion 04 - Proactive Revenue'; flag = 7; end;
	if deal_type='Add-On' and Sales_Motion='Motion 03 - Global Strategic Megadeals' then do;
		Sales_Motion='Motion 04 - Proactive Revenue'; flag = 9; end;
	if deal_type='Renewal' and Sales_Motion='Motion 01 - Regional Backlog' then do;
		Sales_Motion='Motion 02 - Reactive Revenue'; end;

/****************************************************************************************************************/ 
/*** Create New and Add-On deals identifier to force longevity and recency equal to 0 for New deals           ***/ 
/****************************************************************************************************************/
	
	if deal_type='New' then do; New_Identifier=1; Add_identifier = 0; end;
	else if deal_type='Add-On' then do; New_identifier = 0; Add_identifier = 1; end; 
	else do; New_identifier = 0; Add_identifier = 0; end;

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

/***************************************************************************************************/ 
/*** Calculate DHC variables scoring and Late stage deal identifier for DHC_Closers              ***/ 
/*** Create dhc_flag to differentiate wheter a deal contains DHC information                     ***/ 
/***************************************************************************************************/ 
	if daysin01 + daysin02 + daysin03 > 0 then IncludeDaysES=1;
	else IncludeDaysES = 0;
	if daysin04a + daysin04b + daysin05 > 0 then IncludeDaysLS=1;
	else IncludeDaysLS = 0;

	DHC_predictors= WillTheyBuyN + BuyerExperienceWithHPN + ClientRelationshipAndInsightN + CompetitivePositionN+SolutionScopeN; 
	DHC_Closers= ClientDecisionProcessN + DefferentationN + TeamingN + SalesTeamStaffingN + DealShapeandPricingN +  
			 DeliveryLeadershipTeamN + TermsAndConditionsN; 
 
	LS_identifier=1; 
	if IncludeDaysES=1 and IncludeDaysLS=0 then LS_Identifier=0; 
	
	dhc_flag=0;
	if WillTheyBuyN ne 0 or BuyerExperienceWithHPN ne 0 or ClientRelationshipAndInsightN ne 0 or CompetitivePositionN ne 0 
       or ClientDecisionProcessN ne 0 or SolutionScopeN ne 0 or DefferentationN ne 0 or TeamingN ne 0 or SalesTeamStaffingN ne 0  
       or DealShapeandPricingN ne 0 or DeliveryLeadershipTeamN ne 0 or TermsAndConditionsN ne 0 
    then dhc_flag=1; 
	 
	if daysinall <= 15 then daysinall_char = 'aLess then or equal 15 days';
	else if daysinall <= 30 then daysinall_char = 'b15 - 30 days';
	else if daysinall <= 45 then daysinall_char = 'c31 - 45 days';
	else if daysinall <= 60 then daysinall_char = 'd46 - 60 days';
	else if daysinall <= 100 then daysinall_char = 'e61 - 100 days';
	else if daysinall <= 200 then daysinall_char = 'f101 - 200 days';
	else if daysinall <= 300 then daysinall_char = 'g201 - 300 days';
	else daysinall_char = 'hMore than 300 days';

	if tcv___m_ <= 1 then tcv_m_char = 'aLess than or equal $1 M';
	else if tcv___m_ <= 5 then tcv_m_char = 'b$1 - $5 M';
	else if tcv___m_ <= 10 then tcv_m_char = 'c$5 - $10 M';
	else if tcv___m_ <= 15 then tcv_m_char = 'd$10 - $15 M';
	else if tcv___m_ <= 20 then tcv_m_char = 'e$15 - $20 M';
	else if tcv___m_ <= 30 then tcv_m_char = 'f$20 - $30 M';
	else if tcv___m_ <= 50 then tcv_m_char = 'g$30 - $50 M';
	else if tcv___m_ <= 80 then tcv_m_char = 'h$50 - $80 M';
	else tcv_m_char = 'iMore than $80 M';

	*if tcv___m_ > 40 then delete;
run;

/*
proc freq data=flyin_char;
	table ams_asl*skipnum / nocol nopercent norow;
run;
proc freq data=flyin_char;
	table (ststg_es ststg_ls)*skipnum / nocol nopercent norow;
run;
*/
/*number_moves Sales_Motion*Add_identifier daysinall daysinall*daysinall
daysinall_char tcv_m_char*/

proc sort data=flyin_char;
	by deal_type;
run;

ods graphics on;
PROC logistic data=flyin_char plots(only)=(roc oddsratio(range=clip)) plots(MAXPOINTS=NONE) 
/*													outest=test.VelEst_add_new outmodel=test.outmodel_add_new*/; 
	class daysinall_char tcv_m_char deal_type ams_asl prodline Sales_Motion / param=ref;
	MODEL skipnum = daysinall_char tcv_m_char ststg 
							contract_length deal_type Sales_Motion*Add_identifier
							ams_asl prodline / stb;
*effectplot slicefit (x=daysinall sliceby=skipnum)/ INDIVIDUAL ;
*	effectplot fit (x=tcv_m_char)/ individual   ;
RUN;
QUIT;
ods graphics off; 

/*
ods graphics on;
PROC logistic data=flyin_char plots(only)=(roc oddsratio(range=clip)) plots(MAXPOINTS=NONE) 
													outest=test.VelEst_add_new outmodel=test.outmodel_add_new; 
	class daysinall_char / param=ref;
	MODEL skipnum(event='0') = daysinall_char ;
	effectplot slicefit(x = daysinall_char)/ INDIVIDUAL ;
*	effectplot fit (x=tcv_m_char)/ individual  slicefit( sliceby=skipnum) / polybar;
RUN;
QUIT;
ods graphics off; 
*/


