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
* importo paths
include "out/lib/global_paths.do"

// do

import excel "$SRC_DATA/IPC gral var M_B10.xls", cellrange(A8:H1018) firstrow clear

* renombro variables
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

* dropeo duplicados y chequeo que mdate identifique de forma única a cada obs.
drop if mdate==.
isid mdate

* etiquetas
lab var mdate "Fecha mensual"
lab var defl  "Deflactor IPC a 2006m12"

* guardo 
quietly compress		
notes: ipc_2006m12.dta \ deflactor del ipc al 2006m12 \ `tag'
label data "Deflactor de IPC a 2006m12 \ `date'"
datasignature set, reset
save  "out/data/ipc_2006m12.dta", replace
