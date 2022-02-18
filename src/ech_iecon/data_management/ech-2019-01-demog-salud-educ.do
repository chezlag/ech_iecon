capture log close
log using "log/ech-2019-01-demog-salud-educ.log", replace text

//  ech-2019-01-demog-salud-educ.do
//  gsl \ 2021-10-06

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "2019-01.do gsl `date'"
local fullnm "ech-2019-01-demog-salud-educ"

* ruta a las ech originales
global echine "~/data/ine/ech"

// use

use "$echine/hp19.dta", clear

//  #1
//  correcciones de datos

include "src/vardef-ajustes-2001-2019.doi"


//  #2
//  demografía

/* si falta algún módulo (pe4/pe5) sustituir el local por "0" */

* relación de parentezco
loc pe4_jefe        "e30==1"
loc pe4_conyuge     "e30==2"
loc pe4_hije        "e30==3 | e30==4 | e30==5"
loc pe4_padresuegro "e30==7 | e30==8"
loc pe4_otroparient "e30==6 | e30==9 | e30==10 | e30==11 | e30==12"
loc pe4_nopariente  "e30==13"
loc pe4_servdom     "e30==14"
* estado civil
loc pe5_unionlibre  "e35==2 | e35==3"
loc pe5_casado      "e35==4 | e35==5"
loc pe5_divsep      "e35==0 & (e36==1 | e36==2 | e36==3)"
loc pe5_viudo       "e35==0 & (e36==4 | e36==6)"
loc pe5_soltero     "e35==0 & (e36==5)"

include "src/vardef-demog-2011-2019.doi"


//  #3
//  salud





log close
exit
