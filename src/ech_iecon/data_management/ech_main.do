//  ech_main.do
//  programa central de compatibilización de ECH
//  gsl \ 2021-10-06

* argumentos del do-file para la consola
args year
di `year'

//  preamble

version 15
set more off
set linesize 100
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "`year'.do gsl `date'"

* rutas globales
include "out/lib/global_paths.do"

// use

use "$SRC_DATA/fusionado_`year'_terceros.dta", clear

// parámetros específicos de cada año

include "$SRC_DATA_SPECS/ech_`year'_specs.do"


//  #1 -------------------------------------------------------------------------
//  correcciones de datos ------------------------------------------------------

include "$SRC_LIB/vardef_ajustes.do"


//  #2 -------------------------------------------------------------------------
//  demografía -----------------------------------------------------------------

include "$SRC_LIB/vardef_demog.do"


//  #3 -------------------------------------------------------------------------
//  salud y trabajo ------------------------------------------------------------

* van juntos porque se utilizan mutuamente para crear variables

//  trabajo ----------------------------------------------------------

* pea, empleados, desempleados
gen pea    = inrange(bc_pobp, 2, 5) if bc_pe3>=14
gen emp    = bc_pobp==2             if bc_pe3>=14
gen desemp = inrange(bc_pobp, 3, 5) if pea==1

* formalidad en ocupación ppal, otras, conjunto
gen formal_op = `formal_op'                 if emp==1
gen formal_os = `formal_os'                 if emp==1
gen formal    = formal_op==1 | formal_os==1 if emp==1

* trabajo dependiente
gen dependiente_op = `dependiente_op'
gen dependiente_os = `dependiente_os'

* trabajo independiente (coop, patrón, cprop)
gen independiente_op = `independiente_op'
gen independiente_os = `independiente_os'

* ciiu ocupacion principal y ocupacion secundaria
clonevar ciiu_op = `ciiu_op'
clonevar ciiu_os = `ciiu_os'

* aslariados en ocupación principal o secundaria
gen asal_op = `asal_op'
gen asal_os = `asal_os'

* dependiente público o privado en ocupación principal
gen deppri_op = `deppri_op'
gen deppri_os = `deppri_os'
gen deppub_op = `deppub_op'
gen deppub_os = `deppub_os'

// creamos variables de los módulos

include "$SRC_LIB/vardef_salud.do"
include "$SRC_LIB/vardef_trabajo.do"


//  #4 -------------------------------------------------------------------------
//  educación ------------------------------------------------------------------

include "$SRC_LIB/vardef_educ.do"


//  #5 -------------------------------------------------------------------------
//  ingresos -------------------------------------------------------------------

// merge con ipc, bpc y montos de afam-pe

* creo fecha mensualizada
gen mdate = monthly(string(bc_anio) + "m" + string(bc_mes), "YM")
format %tm mdate
lab var mdate "Fecha de referencia de ingresos"
* resto un mes porque ech pregunta ingresos del mes anterior
replace mdate = mdate - 1

* mergeo con ipc
merge m:1 mdate using "out/data/ipc_2006m12.dta", keep(1 3) nogen
rename defl bc_deflactor

* mergeo con bpc
merge m:1 mdate using "out/data/bpc.dta", keep(1 3) nogen
rename bpc bc_bpc

* mergeo montos de afam-pe
merge m:1 mdate using "out/data/afampe.dta", keep(1 3) nogen
rename (afampe_base afampe_comp) (bc_afampe_base bc_afampe_comp)

// dropeamos servicio doméstico para sección de ingresos
*	(lo mergeamos de nuevo más adelante)

preserve
	keep if bc_pe4==7
	tempfile servdom
	save `servdom', replace
restore
drop if bc_pe4==7

// creamos variables de ingreso compatibilizadas según criterio INE

include "$SRC_LIB/vardef_y_ht11.do"
include "$SRC_LIB/vardef_y_transferencias.do"
include "$SRC_LIB/vardef_ypt_yhog.do"
include "$SRC_LIB/vardef_y_extra_iecon.do"


//  #6 -------------------------------------------------------------------------
//  Ingresos: retoques IECON ---------------------------------------------------

include "$SRC_LIB/vardef_y_descomp_fuentes.do"
include "$SRC_LIB/vardef_y_ht11_sss.do"


//  #7 -------------------------------------------------------------------------
//  Últimos retoques -----------------------------------------------------------

* reordeno
sort bc_correlat bc_nper

* renombro estas variables
rename saludh bc_salud
rename yhog_iecon bc_yhog
rename n_milit bc_cuotmilit

* ingreso ciudadano
bysort bc_correlat: egen bc_yciudada= sum(bc_ing_ciud)
replace bc_yciudada=0 if bc_nper!=1

* afam 
gen bc_afam = monto_afam_pe + monto_afam_cont
gen bc_yalimpan = `bc_yalimpan'
* variables que no están disponibles este año
gen bc_cuotabps = `bc_cuotabps'
gen bc_disse_p	= `bc_disse_p'
gen bc_disse_o	= `bc_disse_o'
gen bc_disse	= `bc_disse'
gen bc_pf051 = `bc_pf051'
gen bc_pf052 = `bc_pf052'
gen bc_pf053 = `bc_pf053'
gen bc_pf06  = `bc_pf06'

* ht11 con y sin seguro de salud en términos reales
gen bc_ht11_sss = bc_ht11_sss_corr/bc_deflactor
gen bc_ht11_css = (bc_ht11_sss_corr + bc_salud)/bc_deflactor
* ingreso per cápita
bysort bc_correlat: gen bc_percap_iecon = bc_ht11_sss/_N

* fix: imputamos variables a nivel de hogar el valor que toma para el jefe
foreach var in bc_pg14 bc_ht11_sss bc_ht11_css bc_percap_iecon bc_ht11_sss_corr bc_salud { 	
	bysort bc_correlat: egen `var'_aux = max(`var')
	replace `var' = `var'_aux
	drop `var'_aux
}

// recuperamos servicio doméstico

append using `servdom', nol
sort bc_correlat bc_nper

// rename and order

include "$SRC_LIB/rename_order.do"

//  #8 -------------------------------------------------------------------------
//  labels ---------------------------------------------------------------------

include "$SRC_LIB/label_variables.do"
include "$SRC_LIB/label_values.do"


//  #9 -------------------------------------------------------------------------
//  save -----------------------------------------------------------------------

quietly compress		
notes: ech_`year'.dta \ compatibilización IECON v.2 \ `tag'
label data "ECH IECON `year' \ `date'"
datasignature set, reset
save  "out/data/ech_`year'.dta", replace

exit
