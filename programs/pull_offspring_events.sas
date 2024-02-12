/* ----------------------------------------------------------------------------------------------------------------------
   $Author: sj364 $
   $Date: 2023/07/24 19:42:51 $
   $Source: /biolincc_data/framingham/programs/RCS/pull_offspring_events.sas,v $
    
   Purpose: Create Phenotype visit file and events file for Framingham Offspring.
    
   Assumptions: Source datasets exist
    
   Outputs: /biolincc_data/framingham/analdata/events_fram_offspring.sas7bdat

   ---------------------------------------------------------------------------------------------------------------------
   Modification History
   ---------------------------------------------------------------------------------------------------------------------
   $Log: pull_offspring_events.sas,v $
   Revision 1.1  2023/07/24 19:42:51  sj364
   Initial revision




   ---------------------------------------------------------------------------------------------------------------------
*/                    

libname in1 '/biolincc_data/framingham/data/Datasets' access=readonly;

libname out1 '/biolincc_data/framingham/analdata';

/* Now, output the CV events and procedure data */

proc format;

 value procnum

   140 = "PTCA (Percutaneous transluminal coronary angioplasty)"
   141 = "CABG"
   142 = "Permanent pacemaker insertion"
   143 = "Heart valve procedure"
   144 = "Other cardiac surgery/procedure"
   145 = "Carotid artery surgery"
   146 = "Aorta surgery"
   147 = "Femoral of lower extremity surgery"
   148 = "Surgical amputation"
   149 = "Cardiac catheterization"
   150 = "Cerebral carotid vascular imaging"
   151 = "Aorta and renal vascular imaging";

 value evtdesc
   1 = 'MI recognized, with diagnostic ECG'
   2 = 'MI recognized, without diagnostic ECG, with enzymes and history'
   3 = 'MI recognized, without diagnostic ECG, with autopsy evidence, new event (see also code 9)'
   4 = 'MI unrecognized, silent'
   5 = 'MI unrecognized, not silent'
   6 = 'AP, first episode only'
   7 = 'CI, definite by both history and ECG'
   8 = 'Questionable MI at exam 1'
   9 = 'Acute MI by autopsy, previously coded as 1 or 2'
  10 = 'Definite CVA at exam 1, but questionable type'
  11 = 'ABI (Atherothrombotic Infarction of brain)'
  12 = 'TIA (Transient Ischemic Attack) only the 1st TIA is coded'
  13 = 'Cerebral embolism'
  14 = 'Intracerebral hemorrhage'
  15 = 'Subarachnoid hemorrhage'
  16 = 'Other CVA'
  17 = 'CVA, definite CVA, type unknown'
  18 = 'TIA with positive imaging'
  19 = 'Questionable CVA at exam 1'
  21 = 'Death, CHD sudden, within 1 hour'
  22 = 'Death, CHD, 1-23 hours, non sudden'
  23 = 'Death, CHD, 24-47 hours, non sudden'
  24 = 'Death, CHD, 48 hours or more, non sudden'
  25 = 'Death, CVA'
  26 = 'Death, other CVD'
  27 = 'Death, Cancer'
  28 = 'Death, other causes'
  29 = 'Death, cause unknown'
  30 = 'IC, first episode only'
  39 = 'IC, questionable IC at exam 1'
  40 = 'CHF, not hospitalized, diagnosed on basis of on exam or MD notes'
  41 = 'CHF, hospitalized'
  49 = 'CHF, questionable CHF at exam 1'
  60 = 'General CVD'
  70 = 'CHD'
  80 = 'Hard CVD'
  90 = 'Composite, CVD';   

run; 


data cv_procs(rename=(date=days_since_exam1));
 length event_desc $100;
 set in1.vr_cvdproc_2020_a_1313d(where=(idtype=1)rename=(procnum=event procdate=date));

 event_desc=put(event,procnum.);

 keep pid date event event_desc;

 label event_desc = 'Event/Procedure description'
       date = 'Date (days since Exam 1)';


run;

data cv_events(rename=(date=days_since_exam1));
 length event_desc $100;
 set in1.vr_soe_2020_a_1340d(where=(idtype=1));

 event_desc=put(event,evtdesc.);

 keep pid date event event_desc;

 label event_desc = 'Event/Procedure description'
       date = 'Date (days since Exam 1)';

run;


data general_cvd(rename=(date=days_since_exam1));
 length event_desc $100;
 set in1.vr_soe_2020_a_1340d(where=(idtype=1));

  if (1<=event<=17) or event=19 or (21<=event<=26) or event in (30,39,40,41,49);
  event=60;

  event_desc=put(event,evtdesc.);

 keep pid date event event_desc;

 label event_desc = 'Event/Procedure description'
       date = 'Date (days since Exam 1)';

run;

data chd(rename=(date=days_since_exam1));
 length event_desc $100;
 set in1.vr_soe_2020_a_1340d(where=(idtype=1));

  if (1<=event<=9) or (21<=event<=24);
  event=70;

  event_desc=put(event,evtdesc.);

 keep pid date event event_desc;

 label event_desc = 'Event/Procedure description'
       date = 'Date (days since Exam 1)';

run;

data hard_cvd(rename=(date=days_since_exam1));
 length event_desc $100;
 set in1.vr_soe_2020_a_1340d(where=(idtype=1));

  if (1<=event<=5) or event=11 or (13<=event<=15) or (21<=event<=26);
  event=80;

  event_desc=put(event,evtdesc.);

 keep pid date event event_desc;

 label event_desc = 'Event/Procedure description'
       date = 'Date (days since Exam 1)';

run;

data cvd_composite;
 length event_desc $100;
 set in1.vr_survcvd_2019_a_1334d(where=(idtype=1) rename=(cvddate=days_since_exam1));

     if cvd = 1;

  event=90;

  event_desc=put(event,evtdesc.);

 keep pid days_since_exam1 event event_desc;

 label event_desc = 'Event/Procedure description'
       days_since_exam1 = 'Date (days since Exam 1)';

run;


/* Set all source event data together */
data events_prep;
 length event_val_c $50;
 set cv_procs(in=a)
     cv_events(in=b)
     general_cvd(in=c)
     chd(in=d)
     hard_cvd(in=e)
     cvd_composite(in=f);

 if a then evtype='P';
  else evtype='E';

 event_val_c = 'YES';

run; 

proc sort data=events_prep;
 by pid event_desc days_since_exam1;
run;

proc freq data=events_prep;
 tables event*event_desc/list missing nocum;
run;



/************************************************************/
/** Expand the events data set by adding censoring records **/
/************************************************************/

data patids(drop=idtype);
 set in1.vr_wkthru_ex09_1_1001d(where=(idtype=1) keep=pid idtype);

run;

proc sort data=patids nodupkey;
 by pid;
run;


proc sql;
    create table all_events as

    select distinct event_desc, event, evtype,
           count(event_desc) as count

   from events_prep
   group by event_desc, event, evtype;

   create table events_expanded as

   select a.event_desc, "NO" as event_val_c length=50, a.event, a.evtype,
          b.pid 
       
   from all_events as a left join patids as b
        on a.event_desc ne ' ';

quit;



data surv1(drop=idtype);
 set in1.vr_survcvd_2019_a_1334d(where=(idtype=1) keep=pid cvd cvddate idtype);
run;

proc sort data=surv1;
 by pid;
run;    

data surv2(drop=idtype lastcon datedth);
 set in1.vr_survdth_2019_a_1337d(where=(idtype=1) keep=pid lastcon datedth idtype);

 survdays = min(lastcon,datedth);
 *rename lastcon = survdays;

run;

proc sort data=surv2;
 by pid;
run;    


data surv_disp;
 merge surv1 surv2;
 by pid;
run;
/*
proc print data=surv_disp(where=(cvd=1 and cvddate>survdays));
var cvddate survdays;
run;
endsas;
*/
data events;
 set events_prep
     events_expanded;

run;

/*
proc freq data=events;
 tables evtype*event*event_val_c/list missing;
run;
*/
proc sort data=events;
 by pid event_desc;
run;

data events;
 merge events
       surv_disp;
 by pid;

 if ((1<=event<=9) or event in (60,80)) and event_val_c='NO' and cvd=0 
  then days_since_exam1 = cvddate;

 else if evtype='E' and event ne 90 and event_val_c='NO' 
  then days_since_exam1 = survdays;

 else if event=90 and cvd=0 and event_val_c='NO'
  then days_since_exam1 = cvddate;

 else if event=90 and event_val_c='NO'
  then days_since_exam1 = survdays;
   
 else if evtype='P' and event_val_c='NO' then days_since_exam1 = survdays; 

 drop survdays cvd cvddate;

 label evtype='Type of record (E = event, P = procedure)'
       event_val_c = 'Event Value (YES/NO)'
       event = 'Cardiovascular Event/Procedure code'
       days_since_exam1 = 'Days since exam 1';

run;

proc contents data=events;
run;

proc freq data=events(where=(days_since_exam1=.));
 tables event*event_val_c/list missing;
run;


proc sort data=events;
 by pid event_desc descending event_val_c days_since_exam1;
run;

options validvarname=upcase;
data out1.cv_events;
 set events;
 by pid event_desc descending event_val_c days_since_exam1;
run;

proc export data=events
            outfile="/biolincc_data/framingham/analdata/cv_events.csv"
            dbms=csv
            replace;
run;


ods rtf file="/biolincc_data/framingham/analdata/cv_events_contents.rtf";

proc contents data=out1.cv_events;
run;

ods rtf close;

proc freq data=out1.cv_events;
 tables event_desc/nocum;
run;

endsas;








