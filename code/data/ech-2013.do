//  ech-2013.do
//  gsl \ 2021-10-06

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "2013.do gsl `date'"
local fullnm "ech-2013"

* ruta a las ech originales
global echine "~/data/ine/ech"

// use

use "$echine/ech-2013.dta", clear


//  #1 -------------------------------------------------------------------------
//  correcciones de datos ------------------------------------------------------

include "code/src/vardef-ajustes-2001-2019.doi"


//  #2 -------------------------------------------------------------------------
//  demografía -----------------------------------------------------------------

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
loc pe5_unionlibre  "(e35==2 | e35==3)"
loc pe5_casado      "(e35==4 | e35==5)"
loc pe5_divsep      "(e35==0 & (e36==1 | e36==2 | e36==3))"
loc pe5_viudo       "(e35==0 & (e36==4 | e36==6))"
loc pe5_soltero     "(e35==0 & (e36==5))"

include "code/src/vardef-demog-2011-2019.doi"


//  #3 -------------------------------------------------------------------------
//  salud y trabajo ------------------------------------------------------------

* van juntos porque se utilizan mutuamente para crear variables

// salud -------------------------------------------------------------

* derecho de atención en cada servicio
gen ss_asse = e45_1==1
gen ss_iamc = e45_2==1
gen ss_priv = e45_3==1
gen ss_mili = e45_4==1
gen ss_bps  = e45_5==1
gen ss_muni = e45_6==1
gen ss_otro = e45_7==1
gen ss_emer = e46==1
/* * V2: solo para quienes se repregunta
gen ss_asseV2 = inrange(e45_1_1, 1, 6)
gen ss_iamcV2 = inrange(e45_2_1, 1, 6)
gen ss_privV2 = inrange(e45_3_1, 1, 6)
gen ss_miliV2 = inrange(e45_4_1, 1, 2) */

* origen del derecho de atención
clonevar ss_asse_o = e45_1_1
clonevar ss_iamc_o = e45_2_1
clonevar ss_priv_o = e45_3_1
clonevar ss_mili_o = e45_4_1
clonevar ss_emer_o = e47

* chequeo: solo se repregunta para quienes declaran tener derecho de atención
foreach inst in asse iamc priv mili emer {
	assert inrange(ss_`inst'_o, 1, 6)  if ss_`inst'
	assert ss_`inst'_o==0 if !ss_`inst'
}

* accede a la salud por fonasa (dentro o fuera del hogar)
gen ss_o_fonasa = inlist(ss_asse_o, 1, 4) | ///
				  inlist(ss_iamc_o, 1, 6) | ///
				  inlist(ss_priv_o, 1, 6)
* fonasa dentro del hogar
gen ss_o_fonasa_h = ss_asse_o==1 | ss_iamc_o==1 | ss_priv_o==1

//  trabajo ----------------------------------------------------------

* condición de actividad
clonevar bc_pobp = pobpcoac
recode   bc_pobp (10=9)

* pea, empleados, desempleados
gen pea    = inrange(bc_pobp, 2, 5) if bc_pe3>=14
gen emp    = bc_pobp==2             if bc_pe3>=14
gen desemp = inrange(bc_pobp, 3, 5) if pea==1

* formalidad en ocupación ppal, otras, conjunto
gen formal_op = f82==1                      if ocu==1
gen formal_os = f96==1                      if ocu==1
gen formal    = formal_op==1 | formal_os==1 if ocu==1

* trabajo dependiente
gen dependiente_op = inlist(f73, 1, 2, 7, 8)
gen dependiente_os = inlist(f92, 1, 2, 7)    // excluye part. en prog. empleo social

* trabajo independiente (coop, patrón, cprop)
gen independiente_op = inrange(f73, 3, 6)   
gen independiente_os = inrange(f92, 3, 6)   

* ciiu ocupacion principal y ocupacion secundaria
clonevar ciiu_op = f72_2
clonevar ciiu_os = f91_2

* aslariados en ocupación principal o secundaria
gen asal_op = inlist(f73, 1, 2, 8)
gen asal_os = inlist(f92, 1, 2)

* dependiente público o privado en ocupación principal
gen deppri_op = f73==1
gen deppri_os = f92==1
gen deppub_op = inlist(f73, 2, 8)
gen deppub_os = f92==2

// creamos variables de los módulos

include "code/src/vardef-salud-2011-2019.doi"
include "code/src/vardef-ml-2011-2019.doi"


//  #4 -------------------------------------------------------------------------
//  educación ------------------------------------------------------------------

include "code/src/vardef-educ-2011-2019.doi"


//  #5 -------------------------------------------------------------------------
//  ingresos -------------------------------------------------------------------

include "code/src/vardef-cuotas-mutuales.doi"
include "code/src/vardef-transferencias.doi"
include "code/src/vardef-ypt.doi"
include "code/src/vardef-yhog.doi"


//  #6 -------------------------------------------------------------------------
//  descomposición por fuentes -------------------------------------------------

include "code/src/vardef-descomp-fuentes.doi"


//  #7 -------------------------------------------------------------------------
//  labels ---------------------------------------------------------------------

include "code/src/varlab.doi"


//  #8 -------------------------------------------------------------------------
//  save -----------------------------------------------------------------------

quietly compress		
notes: ech-2013.dta \ compatibilización IECON v.2 \ `tag'
label data "ECH IECON 2013 \ `date'"
datasignature set, reset
save  "data/ech-2013.dta", replace

exit
