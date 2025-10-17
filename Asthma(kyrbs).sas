/*Library*/
libname A 'Z:\김예원\#KYRBS\data';
libname B "Z:\김예원\4.Asthma_bmi_trend\data";

data Allyear;
set 
A.kyrbs2007
A.kyrbs2008
A.kyrbs2009
A.kyrbs2010
A.kyrbs2011
A.kyrbs2012
A.kyrbs2013
A.kyrbs2014
A.kyrbs2015
A.kyrbs2016
A.kyrbs2017
A.kyrbs2018
A.kyrbs2019
A.kyrbs2020
A.kyrbs2021
A.kyrbs2022
A.kyrbs2023
A.kyrbs2024;
run;

proc sort data =  Allyear; by year; run;
proc freq data=allyear; table year; run;

/*Age*/
data C_school; set Allyear;
if MH = '중학교' then school = 1;
else if MH = '고등학교' then school = 2;
else school = .;
run;


/*City type*/
data D_ctype; set C_school;
if CTYPE = '대도시' then region = 1;
else if CTYPE = '중소도시' or CTYPE = '군지역' then region = 2;
else region = .;
run;


/*Income*/
data E_income; set D_ctype;
if E_SES in (4 5) then incm = 1; *하, 중하;
else if E_SES = 3 then incm = 2; *중;
else if E_SES in (1 2) then incm = 3; *중상, 상;
else incm = .;
run;
	

/*BMI*/
data D_BMI; set E_income;
if WT^=. & HT^=. then BMI = WT / ((HT * 0.01)**2);
else BMI = .;
run;


data D_BMI; set D_BMI;
if 10 <= BMI <16.41207 then BMI_g = 1; *Underweight;
else if 16.41207 <= BMI <24.33748 then BMI_g = 2; *Normal; 
else if 24.33748 <= BMI then BMI_g = 3; *Overweight + Obese;
else BMI_g = .; *Unknown;
run;

/*Residence*/
data E_home; set D_BMI;
if year in (2007 2008 2009 2010 2011 2012 2013 2014 2015 2016 2017) then do;
	if E_RES = 1 then house_g = 1; *Family;
	else if E_RES = 2 then house_g = 2; *Relatives;
	else if E_RES = 3 then house_g = 3; *Friends, alone, dormitory;
	else if E_RES = 4 then house_g = 4; *Facility;
	else house_g = .;
end;
run;

data E_home; set E_home;
if year in (2018 2019 2020 2021 2022 2023 2024) then do;
	if E_RES = 1 then house_g = 1;
	else if E_RES = 2 then house_g = 2;
	else if E_RES in (3 4) then house_g = 3;
	else if E_RES = 5 then house_g = 4;
	else house_g = .;
end;
run;

/*Subjective stress*/
data F_stress; set E_home;
if M_STR in (4 5) then stress = 1; *Low;
else if M_STR = 3 then stress = 2; *Middle;
else if M_STR in (1 2) then stress = 3; *High;
else stress = .;
run;


/*잠을 잔 시간이 피로회복에 충분하다고 생각하는가*/
data G_sleep; set F_stress;
if M_SLP_EN in (1 2) then sleep_g = 1; *(매우)충분;
else if M_SLP_EN = 3 then sleep_g = 2; *그저그렇다;
else if M_SLP_EN in (4 5) then sleep_g = 3; *(전혀)충분하지 않다;
else sleep_g = .;
run;

/*Fastfood*/
data H_food; set G_sleep;
if f_fastfood = 1 then food_g = 1; *No;
else if f_fastfood in (2 3) then food_g = 2; *1-4 times;
else if f_fastfood in (4 5 6 7) then food_g = 3; *over 5 times;
else food_g = .;
run;


/*Smoking*/
data I_smoking; set H_food;
if TC_DAYS in (2 3 4 5 6 7) then smoking = 1; *Smoking;
else if TC_DAYS in (1 9999)  then smoking = 2; *No smoking;
else smoking = .;
run;


/*Asthma*/
data J_asthma; set I_smoking;
if AS_DG_LT = 2 then Asthma_dg = 1; *진단 받은 적 있음;
else if AS_DG_LT = 1 then Asthma_dg = 0; *없음;
else Asthma_dg = .;
run;


/*===============================================================*/

data asthma; set J_asthma;
if AS_DG_YR = 2 then Asthma_12_dg = 1;
else if AS_DG_YR = 1 then Asthma_12_dg = 0;
else Asthma_12_dg = .;
run;

/*Period*/
data M_year; set asthma;
if 2007 <= year <= 2009 then period = 1;
else if 2010 <= year <= 2012 then period = 2;
else if 2013 <= year <= 2015 then period = 3;
else if 2016 <= year <= 2019 then period = 4;
else if year = 2020 then period = 5;
else if year = 2021 then period = 6;
else if year = 2022 then period = 7;
else if year = 2023 then period = 8;
else if year = 2024 then period = 9;
run;

/*Weight value*/
data N_weight; set M_year;
if period = 1 then do;
	w_new = w * (1/3);
	end;
if period = 2 then do;
	w_new = w * (1/3);
	end;
if period = 3 then do;
	w_new = w * (1/3);
	end;
if period = 4 then do;
	w_new = w * (1/4);
	end;
if period in (5 6 7 8 9) then do;
	w_new = w;
	end;
run;

data b.weight; set N_weight; run; /*Save*/
data N_weight; set b.weight; run; /*load*/


/*===========================================================*/
/*Checking*/
/*n = 1,174,933*/
data test1; set N_weight;
if sex =. then subject = 0;
run;
proc freq data =  test1;
table subject;
run; *Sex missing = 0; *Sex missing = 0;

data test2; set test1;
if school =. then subject = 0;
run;
proc freq data =  test2;
table subject;
run; *Age missing = 0; *Age missing = 0;

data test3; set test2;
if region =. then subject = 0;
run;
proc freq data =  test3;
table subject;
run; *Region missing = 8; *Region missing = 0;

data test4; set test3;
if incm =. then subject = 0;
run;
proc freq data =  test4;
table subject;
run; *Income missing = 33033; *Income missing = 13;

data test5; set test4;
if BMI_g =. then subject = 0;
run;
proc freq data = test5;
table subject;
run; *BMI missing = 3; *BMI missing = 34513;

data test6; set test5;
if house_g =. then subject = 0;
run;
proc freq data = test6;
table subject;
run; *Residence missing = 0; *Residence missing = 5;

data test7; set test6;
if stress =. then subject = 0;
run;
proc freq data = test7;
table subject;
run; *Stress missing = 0; *Stress missing = 0;

data test8; set test7;
if sleep_g =. then subject = 0;
run;
proc freq data = test8;
table subject;
run; *sleep_g missing = 0;

data test9; set test8;
if food_g =. then subject = 0;
run;
proc freq data = test9;
table subject;
run; *food_g missing = 0;

data test10; set test9;
if smoking =. then subject = 0;
run;
proc freq data = test10;
table subject;
run; *Smoking missing = 0;

data test11; set test10;
if Asthma_dg =. then subject = 0;
run;
proc freq data = test11;
table subject;
run; *Asthma missing = 0;

/*data test12; set test11;
if Asthma_12_dg = . then subject = 0;
run;
proc freq data = test12;
table subject;
run; *Asthma_12 missing = ;*/

/*Final Check*/
data test12; set test11;
if subject ^= 0 then subject = 1;
run;
proc freq data =  test12;
table subject;
run; *subject 0 = 34531  / subject 1 = 1140402 ;

data final; set test12;
if subject = 1 then output final;
run;

data b.final; set final; run; /*Save*/
data final; set b.final; run; /*load*/

libname b "Z:\김예원\4. Asthma_trend_KYRBS";

/*=====================Table 1======================*/

/*Table 1*/
/*
strata strata;
cluster cluster;
weight w_newl;
해당 내용 들어가면 weighted, 없으면 crude로 구함
*/

/*crude total - total*/
proc surveyfreq data =  final nomcar;
by subject;
table
sex
school
region
incm
BMI_g
house_g
stress
sleep_g
food_g
smoking
/cl row column;
title 'Total crude';
run;

/*add*/
/*proc surveyfreq data =  final nomcar;
by subject;
table
sex*incm
sex*BMI_g
sex*house_g
sex*stress
sex*sleep_g
sex*food_g
sex*smoking
/cl row column;
title 'Total crude';
run;*/

/*crude total*/
proc surveyfreq data =  final nomcar;
by subject;
table
period*sex
period*school
period*region
period*incm
period*BMI_g
period*house_g
period*stress
period*sleep_g
period*food_g
period*smoking
/cl row column;
title 'Total crude';
run;

/*weighted total - total*/
proc surveyfreq data =  final nomcar;
strata strata;
cluster cluster;
weight w_new;
by subject;
table
sex
school
region
incm
BMI_g
house_g
stress
sleep_g
food_g
smoking
/cl row column;
title 'Total weighted';
run;

/*weighted total*/
proc surveyfreq data =  final nomcar;
strata strata;
cluster cluster;
weight w_new;
by subject;
table
period*sex
period*school
period*region
period*incm
period*BMI_g
period*house_g
period*stress
period*sleep_g
period*food_g
period*smoking
/cl row column;
title 'Total weighted';
run;


/*=====================Asthma======================*/

data Total_1; set B.final;

*Sex;
if subject = 1 and Asthma_dg = 1 and sex = 1 then Asthma_male = 1;
else if subject = 1 and Asthma_dg = 0 and sex = 1 then Asthma_male = 0;

if subject = 1 and Asthma_dg = 1 and sex = 2 then Asthma_female = 1;
else if subject = 1 and Asthma_dg = 0 and sex = 2 then Asthma_female = 0;

*School type;
if subject = 1 and Asthma_dg = 1 and school = 1 then Asthma_middle = 1; *Middle school;
else if subject = 1 and Asthma_dg = 0 and school = 1 then Asthma_middle = 0;

if subject = 1 and Asthma_dg = 1 and school = 2 then Asthma_high = 1; *High school;
else if subject = 1 and Asthma_dg = 0 and school = 2 then Asthma_high = 0;

*Region;
if subject = 1 and Asthma_dg = 1 and region = 1 then Asthma_urban = 1; *Urban;
else if subject = 1 and Asthma_dg = 0 and region = 1 then Asthma_urban = 0;

if subject = 1 and Asthma_dg = 1 and region = 2 then Asthma_rural = 1; *Rural;
else if subject = 1 and Asthma_dg = 0 and region = 2 then Asthma_rural = 0;

*Income;
if subject = 1 and Asthma_dg = 1 and incm = 1 then Asthma_incm1 = 1; *하, 중하;
else if subject = 1 and Asthma_dg = 0 and incm = 1 then Asthma_incm1 = 0;

if subject = 1 and Asthma_dg = 1 and incm = 2 then Asthma_incm2 = 1; *중;
else if subject = 1 and Asthma_dg = 0 and incm = 2 then Asthma_incm2 = 0;

if subject = 1 and Asthma_dg = 1 and incm = 3 then Asthma_incm3 = 1; *중상, 상;
else if subject = 1 and Asthma_dg = 0 and incm = 3 then Asthma_incm3 = 0;

*Residence;
if subject = 1 and Asthma_dg = 1 and house_g = 1 then Asthma_house1 = 1; *Family;
else if subject = 1 and Asthma_dg = 0 and house_g = 1 then Asthma_house1 = 0;

if subject = 1 and Asthma_dg = 1 and house_g = 2 then Asthma_house2 = 1; *Relatives;
else if subject = 1 and Asthma_dg = 0 and house_g = 2 then Asthma_house2 = 0;

if subject = 1 and Asthma_dg = 1 and house_g = 3 then Asthma_house3 = 1; *Friends, alone, dormitory;
else if subject = 1 and Asthma_dg = 0 and house_g = 3 then Asthma_house3 = 0;

if subject = 1 and Asthma_dg = 1 and house_g = 4 then Asthma_house4 = 1; *Facility;
else if subject = 1 and Asthma_dg = 0 and house_g = 4 then Asthma_house4 = 0;

*Stress;
if subject = 1 and Asthma_dg = 1 and stress = 1 then Asthma_stress1 = 1; *Low;
else if subject = 1 and Asthma_dg = 0 and stress = 1 then Asthma_stress1 = 0;

if subject = 1 and Asthma_dg = 1 and stress = 2 then Asthma_stress2 = 1; *Middle;
else if subject = 1 and Asthma_dg = 0 and stress = 2 then Asthma_stress2 = 0;

if subject = 1 and Asthma_dg = 1 and stress = 3 then Asthma_stress3 = 1; *High;
else if subject = 1 and Asthma_dg = 0 and stress = 3 then Asthma_stress3 = 0;

*Sleeping time;
if subject = 1 and Asthma_dg = 1 and sleep_g = 1 then Asthma_sleep1 = 1; *Sufficient;
else if subject = 1 and Asthma_dg = 0 and sleep_g = 1 then Asthma_sleep1 = 0;

if subject = 1 and Asthma_dg = 1 and sleep_g = 2 then Asthma_sleep2 = 1; *Neutral;
else if subject = 1 and Asthma_dg = 0 and sleep_g = 2 then Asthma_sleep2 = 0;

if subject = 1 and Asthma_dg = 1 and sleep_g = 3 then Asthma_sleep3 = 1; *Insufficient;
else if subject = 1 and Asthma_dg = 0 and sleep_g = 3 then Asthma_sleep3 = 0;

*Fastfood;
if subject = 1 and Asthma_dg = 1 and food_g = 1 then Asthma_food1 = 1; *No;
else if subject = 1 and Asthma_dg = 0 and food_g = 1 then Asthma_food1 = 0;

if subject = 1 and Asthma_dg = 1 and food_g = 2 then Asthma_food2 = 1; *1-4 times;
else if subject = 1 and Asthma_dg = 0 and food_g = 2 then Asthma_food2 = 0;

if subject = 1 and Asthma_dg = 1 and food_g = 3 then Asthma_food3 = 1; *over 5 times;
else if subject = 1 and Asthma_dg = 0 and food_g = 3 then Asthma_food3 = 0;

*Smoking;
if subject = 1 and Asthma_dg = 1 and smoking = 1 then Asthma_smoking1 = 1; *Smoking;
else if subject = 1 and Asthma_dg = 0 and smoking = 1 then Asthma_smoking1 = 0;

if subject = 1 and Asthma_dg = 1 and smoking = 2 then Asthma_smoking2 = 1; *No smoking;
else if subject = 1 and Asthma_dg = 0 and smoking = 2 then Asthma_smoking2 = 0;

run;

data B.total; set Total_1; run; *Save;


/*=====================Table 2======================*/
data Total; set B.total; run;

data BMI_1 BMI_2 BMI_3; set total;
if subject=1 and bmi_g=1 then output BMI_1;
if subject=1 and bmi_g=2 then output BMI_2;
if subject=1 and bmi_g=3 then output BMI_3;
run;

proc sort data=BMI_1; by period; run;
data b.BMI_1; set BMI_1; run;

proc sort data=BMI_2; by period; run;
data b.BMI_2; set BMI_2; run;

proc sort data=BMI_3; by period; run;
data b.BMI_3; set BMI_3; run;

/*Prevalence Macro*/
%macro prevalence(data = , dise = );
proc surveyfreq data =  &data nomcar;
strata strata;
cluster cluster;
weight w_new;
by period;
table
&dise._dg
&dise._male
&dise._female
&dise._middle
&dise._high
&dise._urban
&dise._rural
&dise._incm1
&dise._incm2
&dise._incm3
&dise._house1
&dise._house2
&dise._house3
&dise._house4
&dise._stress1
&dise._stress2
&dise._stress3
&dise._sleep1
&dise._sleep2
&dise._sleep3
&dise._food1
&dise._food2
&dise._food3
&dise._smoking1
&dise._smoking2
/cl row column;
run;
%mend;

/*Total*/
%prevalence(data = BMI_1, dise = Asthma)
%prevalence(data = BMI_2, dise = Asthma)
%prevalence(data = BMI_3, dise = Asthma)


/*===============B value - Total=================*/
/*기간 나누기*/
data Pre_total Intra_total Post_total; set Total;
if period in (1 2 3 4) then output Pre_total;
if period in (4 5 6 7) then output Intra_total;
if period in (7 8 9) then output Post_total;
run;

data pre1 pre2 pre3 intra1 intra2 intra3 post1 post2 post3; set total;
if period in (1 2 3 4) and bmi_g=1 then output pre1;
if period in (1 2 3 4) and bmi_g=2 then output pre2;
if period in (1 2 3 4) and bmi_g=3 then output pre3;
if period in (4 5 6 7) and bmi_g=1 then output intra1;
if period in (4 5 6 7) and bmi_g=2 then output intra2;
if period in (4 5 6 7) and bmi_g=3 then output intra3;
if period in (7 8 9) and bmi_g=1 then output post1;
if period in (7 8 9) and bmi_g=2 then output post2;
if period in (7 8 9) and bmi_g=3 then output post3;
run;


/*Pre-pandemic*/
%macro Pre_pan19(data = , model_var = );
ods graphics off;
ods select ParameterEstimates;
proc surveyreg DATA = &data NOMCAR;
strata strata;
cluster cluster;
weight w_new;
MODEL &model_var = period / stb clparm;
run;
%mend;

%macro Pre_B_total(data = , disease_name =);
%local k;
	%do k = 1 %to 25;
		%Pre_pan19(data = &data, model_var = &disease_name._%scan(
dg
male
female
middle
high
urban
rural
incm1
incm2
incm3
house1
house2
house3
house4
stress1
stress2
stress3
sleep1
sleep2
sleep3
food1
food2
food3
smoking1
smoking2,
&k));
	%end;
%mend; 

%Pre_B_total(data = pre1, disease_name = Asthma)
%Pre_B_total(data = pre2, disease_name = Asthma)
%Pre_B_total(data = pre3, disease_name = Asthma)


/*======================================================*/

/*Intra-pandemic*/
%macro Intra_pan19(data = , model_var = );
ods graphics off;
ods select ParameterEstimates;
proc surveyreg DATA = &data NOMCAR;
strata strata;
cluster cluster;
weight w_new;
MODEL &model_var = period / stb clparm;
run;
%mend;

%macro Intra_B_total(data = , disease_name =);
%local k;
	%do k = 1 %to 25;
		%Intra_pan19(data = &data, model_var = &disease_name._%scan(
dg
male
female
middle
high
urban
rural
incm1
incm2
incm3
house1
house2
house3
house4
stress1
stress2
stress3
sleep1
sleep2
sleep3
food1
food2
food3
smoking1
smoking2,
&k));
	%end;
%mend; 

%Intra_B_total(data = intra1, disease_name = Asthma)
%Intra_B_total(data = intra2, disease_name = Asthma)
%Intra_B_total(data = intra3, disease_name = Asthma)


/*=================================================*/

/*Post-pandemic*/
%macro Post_pan19(data = , model_var = );
ods graphics off;
ods select ParameterEstimates;
proc surveyreg DATA = &data NOMCAR;
strata strata;
cluster cluster;
weight w_new;
MODEL &model_var = period / stb clparm;
run;
%mend;

%macro Post_B_total(data = , disease_name =);
%local k;
	%do k = 1 %to 25;
		%Post_pan19(data = &data, model_var = &disease_name._%scan(
dg
male
female
middle
high
urban
rural
incm1
incm2
incm3
house1
house2
house3
house4
stress1
stress2
stress3
sleep1
sleep2
sleep3
food1
food2
food3
smoking1
smoking2,
&k));
	%end;
%mend; 

%Post_B_total(data = post1, disease_name = Asthma)
%Post_B_total(data = post2, disease_name = Asthma)
%Post_B_total(data = post3, disease_name = Asthma)



/*=========================Table 3============================*/

/*Odds Ratio*/
data Odd1; set B.Total; run;

data c1 c2 c3 c4 c5 c6 c7;
set Odd1;
if period in (1 2) then output c1;
if period in (2 3) then output c2;
if period in (3 4) then output c3;
if period in (4 5) then output c4;
if period in (5 6) then output c5;
if period in (6 7) then output c6;
if period in (7 8) then output c7;
run;

/*Period c1*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c1 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '1') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c2*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c2 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '2') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c3*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c3 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '3') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c4*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c4 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '4') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c5*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c5 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '5') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c6*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c6 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '6') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);

/*Period c7*/
%macro logistic_model(model_name);
PROC SURVEYLogistic data =  c7 NOMCAR;
strata strata;
cluster cluster;
weight w_new;
class period (ref = '7') / param =  ref;
model &model_name (event = '1') = period;
run;
%mend;

%logistic_model(Asthma_dg);
%logistic_model(Asthma_male);
%logistic_model(Asthma_female);
%logistic_model(Asthma_middle);
%logistic_model(Asthma_high);
%logistic_model(Asthma_urban);
%logistic_model(Asthma_rural);
%logistic_model(Asthma_incm1);
%logistic_model(Asthma_incm2);
%logistic_model(Asthma_incm3);
%logistic_model(Asthma_BMI1);
%logistic_model(Asthma_BMI2);
%logistic_model(Asthma_BMI3);
%logistic_model(Asthma_BMI4);
%logistic_model(Asthma_house1);
%logistic_model(Asthma_house2);
%logistic_model(Asthma_house3);
%logistic_model(Asthma_house4);
%logistic_model(Asthma_stress1);
%logistic_model(Asthma_stress2);
%logistic_model(Asthma_stress3);
%logistic_model(Asthma_sleep1);
%logistic_model(Asthma_sleep2);
%logistic_model(Asthma_sleep3);
%logistic_model(Asthma_food1);
%logistic_model(Asthma_food2);
%logistic_model(Asthma_food3);
%logistic_model(Asthma_smoking1);
%logistic_model(Asthma_smoking2);


/*==========================Table 4========================*/
/*Risk Factor*/
data Risk; set B.Total; run;

data Pre_risk Intra_risk Post_risk; set Risk;
if period in (1 2 3 4) then output Pre_risk;
if period in (4 5 6 7) then output Intra_risk;
if period in (7 8 9) then output Post_risk;
run;

proc sort data=Risk out=Risk;
	by bmi_g; run;

/*Overall*/
%macro risk_factor1(ref_value, class_variable);
ods select ParameterEstimates;
ods select OddsRatios;
proc surveylogistic data =  Risk nomcar;
where subject = 1;
strata strata;
cluster cluster;
weight w_new;
by bmi_g;
class &class_variable (ref=&ref_value) / param=ref;
model Asthma_dg (event='1') = &class_variable;
run;
%mend;

%risk_factor1('2', sex)
%risk_factor1('1', school)
%risk_factor1('2', region)
%risk_factor1('2', incm)
%risk_factor1('1', house_g)
%risk_factor1('1', stress)
%risk_factor1('1', sleep_g)
%risk_factor1('1', food_g)
%risk_factor1('2', smoking)



/*Pre-pandemic*/
%macro risk_factor2(ref_value, class_variable);
ods select ParameterEstimates;
ods select OddsRatios;
proc surveylogistic data =  Pre_risk nomcar;
where subject = 1;
strata strata;
cluster cluster;
weight w_new;
class &class_variable (ref=&ref_value) / param=ref;
model Asthma_dg (event='1') = &class_variable;
run;
%mend;

%risk_factor2('2', sex)
%risk_factor2('1', school)
%risk_factor2('2', region)
%risk_factor2('2', incm)
%risk_factor2('2', BMI_g)
%risk_factor2('1', house_g)
%risk_factor2('1', stress)
%risk_factor2('1', sleep_g)
%risk_factor2('1', food_g)
%risk_factor2('2', smoking)
%risk_factor2('2', school)

%risk_factor2('2', BMI_g)
%risk_factor2('1', food_g)


/*Intra-pandemic*/
%macro risk_factor3(ref_value, class_variable);
ods select ParameterEstimates;
ods select OddsRatios;
proc surveylogistic data =  Intra_risk nomcar;
where subject = 1;
strata strata;
cluster cluster;
weight w_new;
class &class_variable (ref=&ref_value) / param=ref;
model Asthma_dg (event='1') = &class_variable;
run;
%mend;

%risk_factor3('2', sex)
%risk_factor3('1', school)
%risk_factor3('2', region)
%risk_factor3('2', incm)
%risk_factor3('1', BMI_g)
%risk_factor3('1', house_g)
%risk_factor3('1', stress)
%risk_factor3('1', sleep_g)
%risk_factor3('2', food_g)
%risk_factor3('2', smoking)

%risk_factor3('2', BMI_g)
%risk_factor3('1', food_g)


/*Post-pandemic*/
%macro risk_factor4(ref_value, class_variable);
ods select ParameterEstimates;
ods select OddsRatios;
proc surveylogistic data =  Post_risk nomcar;
where subject = 1;
strata strata;
cluster cluster;
weight w_new;
class &class_variable (ref=&ref_value) / param=ref;
model Asthma_dg (event='1') = &class_variable;
run;
%mend;

%risk_factor4('2', sex)
%risk_factor4('1', school)
%risk_factor4('2', region)
%risk_factor4('2', incm)
%risk_factor4('1', BMI_g)
%risk_factor4('1', house_g)
%risk_factor4('1', stress)
%risk_factor4('1', sleep_g)
%risk_factor4('2', food_g)
%risk_factor4('2', smoking)

%risk_factor4('2', BMI_g)
%risk_factor4('1', food_g)



