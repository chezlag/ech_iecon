/*
	bpc.do
	arma base con el valor de BPC mes a mes en el período 2007–2022
	fuente: https://www.dgi.gub.uy/wdgi/page?2,principal,_Ampliacion,O,es,0,PAG;CONC;40;1;D;base-de-prestaciones-y-contribuciones-bpc;6;PAG;

	gsl \ 2022-02-21
*/

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

// importo

import delimited "$SRC_DATA/bpc.tsv", clear

// mensualizo la base

* expando a 12 meses
expand 12
* genero variable de mes a mes
bys vigente_desde: gen mes = _n
* genero fecha mensual
gen     mdate = mofd(date(vigente_desde, "YMD"))
replace mdate = mdate + (mes-1)

// ajusto y exporto

* conservo fecha y bpc
keep mdate bpc
isid mdate

* etiquetas
lab var mdate "Fecha mensual"
lab var bpc  "Base de Prestaciones y Contribuciones"

* guardo 
quietly compress		
notes: bpc.dta \ BPC 2007–2022 \ `tag'
label data "BPC 2007–2022 \ `date'"
datasignature set, reset
save  "out/data/bpc.dta", replace
