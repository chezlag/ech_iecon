// setup

clear all
set more off

* globals con rutas
global SRC_LIB "src/ech_iecon/lib"
global SRC_DATA "src/ech_iecon/data"
global SRC_DATA_SPECS "src/ech_iecon/data_specs"

* año a procesar
loc year "2013"

* directorio de la base temporal
local tempPath "out/data/tmp/ech_`year'_descomp_fuentes.dta"

di "`tempPath'"

* proceso datos base si aún no los procesé
cap confirm file `tempPath'
if _rc != 0 {

	* cargo base INE
	use "$SRC_DATA/fusionado_`year'_terceros.dta", clear

	* parámetros de cada año
	include "$SRC_DATA_SPECS/ech_`year'_specs.do"

	// ajustes y demográficas básicas

	* correcciones de datos
	include "$SRC_LIB/vardef_ajustes.do"
	include "$SRC_LIB/vardef_demog.do"

	// salud y trabajo 

	* pea, empleados, desempleados
	gen pea    = inrange(bc_pobp, 2, 5) if bc_pe3>=14
	gen emp    = bc_pobp==2             if bc_pe3>=14
	gen desemp = inrange(bc_pobp, 3, 5) if pea==1

	* formalidad en ocupación ppal, otras, conjunto
	gen formal_op = `formal_op'                 if emp==1
	gen formal_os = `formal_os'                 if emp==1
	gen formal    = formal_op==1 | formal_os==1 if emp==1

	* creamos variables de los módulos
	include "$SRC_LIB/vardef_salud.do"
	include "$SRC_LIB/vardef_trabajo.do"

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
	
	// ingresos v1.2

	include "$SRC_LIB/vardef_y_ht11.do"

	include "resources/old_code/v1.2/`year'/5_descomp_fuentes.do"
	
	// renombro variables de descomposición por fuentes
	
	local varlist "bc_pg14 bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p bc_pg17p bc_pg27p bc_pg13p bc_pg23p bc_pg13o bc_pg23o bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t bc_pg32p bc_pg42p bc_pg72p bc_pg32o bc_pg42o bc_pg72o bc_pg31p bc_pg41p bc_pg51p bc_pg71p bc_pg33p bc_pg43p bc_pg52p bc_pg73p bc_pg31o bc_pg41o bc_pg51o bc_pg71o bc_pg33o bc_pg43o bc_pg52o bc_pg73o bc_pg911 bc_pg912 bc_pg921 bc_pg922 bc_pg91 bc_pg92 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132 bc_pg60p bc_pg80p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg60o bc_pg80o bc_pg60o_cpsl bc_pg60o_cpcl"
	local auxvarlist "sal_esp_net corr_sal_esp bc_otros_lab bc_otros_lab2 bc_otros_benef bc_pag_at bc_otras_utilidades bc_ot_utilidades bc_otras_capital otros"
	foreach varname in `varlist' `auxvarlist' {
		rename `varname' S`varname'
	}
	
	// guardo
	save `tempPath'
} 
else {
	use `tempPath', clear
	include "$SRC_DATA_SPECS/ech_`year'_specs.do"
}

include "$SRC_LIB/vardef_y_descomp_fuentes.do"

* armo lista de variables que no coinciden
local varlist "bc_pg14 bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p bc_pg17p bc_pg27p bc_pg13p bc_pg23p bc_pg13o bc_pg23o bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t bc_pg32p bc_pg42p bc_pg72p bc_pg32o bc_pg42o bc_pg72o bc_pg31p bc_pg41p bc_pg51p bc_pg71p bc_pg33p bc_pg43p bc_pg52p bc_pg73p bc_pg31o bc_pg41o bc_pg51o bc_pg71o bc_pg33o bc_pg43o bc_pg52o bc_pg73o bc_pg911 bc_pg912 bc_pg921 bc_pg922 bc_pg91 bc_pg92 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132 bc_pg60p bc_pg80p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg60o bc_pg80o bc_pg60o_cpsl bc_pg60o_cpcl"
foreach varname in `varlist' {
	cap assert (S`varname' == `varname') | (abs(S`varname' - `varname') < .01)
	if _rc!=0 loc diferentes_1 "`diferentes_1'`varname' "
}
di "`diferentes_1'"
* chequeo que las diferencias no surjan por valores faltantes
foreach varname in `diferentes_1' {
	recode S`varname' (. = 0)
	cap assert (S`varname' == `varname') | (abs(S`varname' - `varname') < .001)
	if _rc!=0 loc diferentes_2 "`diferentes_2'`varname' "
}
di "`diferentes_2'"
* comparo las variables diferentes 
foreach varname in `diferentes_2' {
	di _newl "`varname'"
	compare S`varname' `varname'
}
