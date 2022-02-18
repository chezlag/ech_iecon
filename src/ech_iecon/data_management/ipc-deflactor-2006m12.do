//  ipc-deflactor-2006m12.do
//  arma base con deflactor mensual ipc
//  gsl \ 2021-10-06

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "gsl `date'"

// do

import excel "IPC gral var M_B10.xls", cellrange(A8:H1018) firstrow clear
rename Índice ipc
rename Mesyaño fecha
format fecha %td
* fecha mensual
gen mdate = mofd(fecha)
format mdate %tm
* deflactor
list fecha if fecha==date("1/12/2006", "DMY")
gen double defl = ipc / ipc[836]
assert defl[836] == 1
* conservo fecha mensual y deflactor
keep mdate defl
* guardo 
quietly compress		
notes: ipc-deflactor-2006m12.dta \ deflactor del ipc al 2006m12 \ `tag'
label data "ipc-deflactor \ `date'"
datasignature set, reset
save  "ipc-deflactor-2006m12.dta", replace
