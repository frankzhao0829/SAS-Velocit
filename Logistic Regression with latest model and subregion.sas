LIBNAME vel_old "/var/blade/data2031/esiblade/Velocity/Data";


Data velocity(keep=daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg1 ststg2 ststg3 ststg4a ststg4b ststg5
					deal_type ams_asl sold contract_length longevity recency tcv___m_);
	set vel_old.model102513ii;

	if tcv___m_ >0;
	if ams_asl = 'BoA' then ams_asl = 'US-FIN Svcs';
	if ams_asl = 'GM' then ams_asl = 'US - EMIME';
run;

data renewal new_add;
	set velocity;

if deal_type = 'Renewal' then output renewal;
else output new_add;
run;

/* Logistic regression for deal type=renewal */
Proc sort data=renewal;
	by deal_type ams_asl;
run;

ods graphics on; 
PROC logistic data=renewal plots(only)=(roc oddsratio(range=clip)) outest=VelEst_renewal outmodel=outmodel_renewal;
	class deal_type ams_asl / param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg1 ststg2 ststg3 ststg4a ststg4b ststg5  
							contract_length longevity recency deal_type tcv___m_ ams_asl / firth clodds=pl;
	score out=score_renewal;
RUN;

/* Logistic regression for deal type=new, addon */
Proc sort data=new_add;
	by deal_type ams_asl;
run;

PROC logistic data=new_add plots(only)=(roc oddsratio(range=clip)) outest=VelEst_newadd outmodel=outmodel_newadd;
    by deal_type;
	class deal_type ams_asl / param=ref;
	MODEL sold(event='1') = daysin01 daysin02 daysin03 daysin04a daysin04b daysin05 ststg1 ststg2 ststg3 ststg4a ststg4b ststg5  
							contract_length longevity recency deal_type tcv___m_ ams_asl / ;
	score out=score_newadd;
RUN;


proc freq data=velocity;
	table deal_type*ams_asl*sold / nocol nopercent norow;
run;