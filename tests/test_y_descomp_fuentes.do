// setup

* globals con rutas
global SRC_LIB "src/ech_iecon/lib"
global SRC_DATA "src/ech_iecon/data"

* definimos año a procesar
local year "2012"

* directorio de la base temporal
local tempPath "out/data/tmp/ech_`year'_descomp_fuentes.dta"

* chequeo existencia del directorio out/data/tmp
cap confirm new file `tempPath'
if _rc!=0 !mkdir "out/data/tmp"
* proceso datos si aún no los procesé
cap confirm file `tempPath'
if _rc!=0 {

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

	include "$SRC_LIB/vardef_y_descomp_fuentes.do"

	save `tempPath'
}
