LIBNAME velocity "/var/blade/data2031/esiblade/zchunyou/Velocity/Data";


data velocity.coeff_test (keep= deal_type stage coeff);
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
from open_temp a left outer join velocity.coeff_test b 
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

data velocity.daystored_test;
	set open;
run;



