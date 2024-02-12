/* ----------------------------------------------------------------------------------------------------------------------
   $Author: sj364 $
   $Date: 2023/07/20 21:14:13 $
   $Source: /biolincc_data/aric/programs/RCS/pull_aric_events.sas,v $
    
   Purpose: ARIC Events dataset creation for Stroke prediction project.
            All events are "by 2018", except for Afib, which is "by 2013".
    
   Assumptions: Source datasets exist
    
   Outputs: /biolincc_data/aric/analdata/cv_events.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
  
   $Log: pull_aric_events.sas,v $
   Revision 1.1  2023/07/20 21:14:13  sj364
   Initial revision





   ---------------------------------------------------------------------------------------------------------------------
*/  
                  
libname inci "/biolincc_data/aric/data/cohort_Incident" access=readonly;
libname inchd "/biolincc_data/aric/data/cohort_CHD" access=readonly;
libname out1 '/biolincc_data/aric/analdata';


options nofmterr nonumber nodate nocenter validvarname=upcase;

proc sort data=inci.incps18(keep=id_c fudth18) out=censoring nodupkey;
 by id_c;
run;

proc sort data=inchd.coccps18 out=coccps18;
 by id_c;
run;

proc sort data=inchd.cevtps18 out=cevtps18;
 by id_c;
run;

proc sort data=inci.incps18 out=incps18;
 by id_c;
run;

proc sort data=inci.afincps13 out=afincps13;
 by id_c;
run;

proc contents data=coccps18;
run;
proc contents data=incps18;
run;
proc contents data=afincps13;
run;


* All Cause Hospitalization;
data occ1;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge coccps18(in=a) censoring(in=b);
 by id_c;

if EVTYPE01 = "I" then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, NON CHD-RELATED";
   event_val_c  = "YES";
   if C_CHD = 1 then event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, CHD-RELATED";
   event_t2_o = DDATE0_DAYS;
   output;
end;  

if last.id_c then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, NON CHD-RELATED";
   event_val_c  = "NO";
   if C_CHD = 1 then event_name_o = "ALL CAUSE HOSPITALIZATION, IN HOSPITAL DEATH, CHD-RELATED";
   event_t2_o = FUDTH18;
   output;
end;  
   
 
   keep id_c event_name_o event_val_c event_t2_o;      
run;


data occ2;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge coccps18(in=a) censoring(in=b);
 by id_c;
   
if EVTYPE01 = "N" then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, NON CHD-RELATED";
   event_val_c  = "YES";
   if C_CHD = 1 then event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, CHD-RELATED";
   event_t2_o = DDATE0_DAYS;
   output;
end;  

if last.id_c then do;
   event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, NON CHD-RELATED";
   event_val_c  = "NO";
   if C_CHD = 1 then event_name_o = "ALL CAUSE HOSPITALIZATION, NON-FATAL, CHD-RELATED";
   event_t2_o = FUDTH18;
   output;
end;  
 
   keep id_c event_name_o event_val_c event_t2_o;      
run;


* CHD related Death;
data chddth;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";

merge cevtps18(in=a) censoring(in=b);
 by id_c;

if CDTHYR ne . then do;
   event_name_o = "CHD-RELATED DEATH";
   event_val_c  = "YES";
   event_t2_o = DTHDATE_DAYS;
   output;
end;  

if last.id_c then do;
   event_name_o = "CHD-RELATED DEATH";
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   output;
end;  

   keep id_c event_name_o event_val_c event_t2_o;      
run;



* All cause death prior to censor date;
data dth18;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;  
 
if DEAD18  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUDTH18;
   event_name_o = "ALL CAUSE DEATH BY 2018";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   event_name_o = "ALL CAUSE DEATH BY 2018";
 output;
end;

if DEAD18  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   event_name_o = "ALL CAUSE DEATH BY 2018";
 output;
end;

   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;


* Hospitalized MI prior to censor date;
data MI18;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;  
 
if MI18  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUMI18;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2018";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUMI18;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2018";
 output;
end;

if MI18  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   event_name_o = "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2018";
 output;
end;

   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;


* MI or Fatal CHD prior to censor date;
data INC18;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;  
 
if INC18  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUINC18;
   event_name_o = "MI OR FATAL CHD BY 2018";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUINC18;
   event_name_o = "MI OR FATAL CHD BY 2018";
 output;
end;

if INC18  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   event_name_o = "MI OR FATAL CHD BY 2018";
 output;
end;

   keep id_c  event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* Incident Heart Failure;
data hf18;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;  
 
 if INCHF18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = C7_FUTIMEHF;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = C7_FUTIMEHF;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2018";
  output;
 end;
 
 if INCHF18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "INCIDENT HF (FROM DISCHARGE CODES) BY 2018";
  output;
 end;
      
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* Cardiac Procedures prior to censor date;
data PROC18;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;  
 
if PROC18  = 1 then do;
   event_val_c  = "YES";
   event_t2_o = FUPROC18;
   event_name_o = "CARDIAC PROCEDURES BY 2018";
 output;
end;

else do;
   event_val_c  = "NO";
   event_t2_o = FUPROC18;
   event_name_o = "CARDIAC PROCEDURES BY 2018";
 output;
end;

if PROC18  = 1 then do;
   event_val_c  = "NO";
   event_t2_o = FUDTH18;
   event_name_o = "CARDIAC PROCEDURES BY 2018";
 output;
end;

   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* Incident Atrial Fibrillation (by 2013); 
* Note:  No additional censoring record is output for subjects who have afib;
data af13;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set afincps13;
 
 if AFINC  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = TTAF;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2013";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = TTAF;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2013";
  output;
 end;

/*
 if AFINC  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = ?;
    event_name_o = "INCIDENT ATRIAL FIBRILLATION BY 2013";
  output;
 end;
*/

   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;


/*NOT FOUND IN NEW BIOLINCC DATA 
* Incident Atrial Flutter (by 2013);
data afL13;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set afincps13;
 
 if AFLINCBY11  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT11AFLINC;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FT11AFLINC;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;

 if AFLINCBY11  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH11;
    event_name_o = "INCIDENT ATRIAL FLUTTER BY 2011";
  output;
 end;

   keep subject_id event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;
*/



* DEFINITE/PROBABLE Incident Stroke;
data stroke;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;
 
 if INDP18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT18DP;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FT18DP;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2018";
  output;
 end; 

 if INDP18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "DEFINITE/PROBABLE INCIDENT STROKE BY 2018";
  output;
 end;
    
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* DEFINITE/PROBABLE/POSSIBLE Incident Stroke;
data DPP;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;
 
 if INDPP18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTDPP18;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FTDPP18;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2018";
  output;
 end; 

 if INDPP18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2018";
  output;
 end;
    
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* DEFINITE/PROBABLE ISCHEMIC Incident Stroke;
data ISC;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;
 
 if INISC18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTISC18;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FTISC18;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2018";
  output;
 end; 

 if INISC18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2018";
  output;
 end;
    
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* DEFINITE/PROBABLE BRAIN HEMORRHAGIC Incident Stroke;
data HEM;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;
 
 if INHEM18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FTHEM18;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FTHEM18;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end; 

 if INHEM18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end;
    
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC Incident Stroke;
data CHM;
   attrib event_name_o label="Original Event Name" length=$200;
   attrib event_val_c label = "Original Event Value of EVENT_NAME_O" length=$50;
   attrib event_t2_o label="Original Analysis - Time to Event (Days)";
   
   set incps18;
 
 if INCHM18  = 1 then do;
    event_val_c  = "YES";
    event_t2_o = FT18CHM;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end;
 
 else do;
    event_val_c  = "NO";
    event_t2_o = FT18CHM;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end; 

 if INCHM18  = 1 then do;
    event_val_c  = "NO";
    event_t2_o = FUDTH18;
    event_name_o = "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2018";
  output;
 end;
    
   keep id_c event_name_o event_val_c event_t2_o;      
run;

proc freq; tables event_val_c;



* ##### ALL EVENTS DATA #####;

data cvevents;

   set occ1 occ2 chddth dth18 mi18 inc18 hf18 proc18 af13 /*afL11*/
   	   stroke dpp isc hem chm;

   label event_t2_o = 'Days since exam 1'
         event_name_o = 'Event/Procedure description'
         event_val_c = 'Event Value (YES/NO)'
         id_c = 'Unique study participant identification number';

   rename event_name_o = event_desc
          event_t2_o = days_since_exam1;
       
run;

proc sort data=cvevents;
   by id_c days_since_exam1;
run;

proc sort data=out1.pheno_aric(keep=/*DBGAP_SUBJECT_ID*/ id_c) out=fullpop nodupkey;
by id_c;
run;

data cvevents;
 merge cvevents(in=a)
       fullpop(in=b);
 by id_c;

 if a and b;

run;


options validvarname=upcase;
data out1.cv_events;
 set cvevents;
 by id_c days_since_exam1;
run;


proc export data=cvevents
            outfile="/biolincc_data/aric/analdata/cv_events.csv"
            dbms=csv
            replace;
run;


ods rtf file="/biolincc_data/aric/analdata/cv_events_contents.rtf";

proc contents data=out1.cv_events;
run;

ods rtf close;

proc freq data=out1.cv_events;
 tables event_desc*event_val_c/list missing nocum;
run;

endsas;
   
