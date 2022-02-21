capture log close
log using "log/ech-2020-07-check-ingr.log", replace text

//  ech-2020-07-check-ingr.do
//  gsl \ 2021-09-29

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "2019-07.do gsl `date'"
local fullnm "ech-2020-07-check-ingr"

// ----------------------------------------------
// use

use "data/tmp/ech-2020-05.dta", clear
datasig confirm
notes _dta

// ----------------------------------------------


compare ht11 bc_ht11_sss_corr if bc_nper==1


log close
exit
