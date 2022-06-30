/* 
	afampe.dta
	Valor de AFAM-PE y su complemento 2008–2019
	gsl \ 2022-02-22
	

	AFAM-PE pasan a regirse por la Ley Nº 18.227, que establece sus valores
	desde el 1º de enero de 2008.

	El Art. 4 establece los montos y la forma de cálculo.

		- $700  * beneficiarios sin discapacidad ^ 0.6
		- $300  * beneficiarios en el liceo ^ 0.6
		- $1000 * beneficiarios con discapacidad

	El Art. 10 fija los ajustes en conformidad a la variación del IPC, en las 
	mismas oportunidades que se ajusten las remuneraciones de los funcionarios
	públicos de la Administración Central

	El texto completo de la ley, y sus posteriores ajustes, pueden consultarse 
	en: https://www.impo.com.uy/bases/leyes/18227-2007

*/

version 15
clear all
set more off
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "gsl `date'"

* defino numero de observaciones
set obs 18

* creo año, mes y fecha mensualizada
gen year = 2007 + _n
expand 12
bys year: gen mes = _n
gen mdate = monthly(string(year) + "m" + string(mes), "YM")
format mdate %tm
isid mdate

* mergeo con deflactor del ipc
merge 1:1 mdate using "out/data/ipc_2006m12.dta", keep(1 3) nogen
* ajusto deflactor a base 2008m1
local defl_2008m1 = defl[1]
replace defl = defl / `defl_2008m1'

* actualizo el valor de las canastas en el mes 1
*	–– asumo que es cuando se ajustan los salarios de Administración Central
gen x1 = 700 * defl if mes==1
gen x2 = 300 * defl if mes==1
* imputo el valor de enero al resto del año
egen afampe_base = max(x1), by(year)
egen afampe_comp = max(x2), by(year)

* "duplicación" de AFAM por pandemia
foreach v in 2020m4 2020m9 2020m11 2021m2 2021m7 2021m9 2021m10 2021m11 {
	local `v' = monthly("`v'", "YM")
}
foreach v in afampe_base afampe_comp {
	replace `v' = `v' * 1.5 if inrange(mdate, `2020m4' , `2020m9')
	replace `v' = `v' * 1.5 if inrange(mdate, `2020m11', `2021m2')
	replace `v' = `v' * 2   if inrange(mdate, `2021m7' , `2021m9')
	replace `v' = `v' * 1.7 if mdate==`2021m10'
	replace `v' = `v' * 1.5 if mdate==`2021m11'
}

* saco variables sin datos
drop if defl == .

* conservo fecha y montos
keep mdate afampe_base afampe_comp

* etiqueto
lab var mdate       "Fecha mensual"
lab var afampe_base "AFAM-PE: Monto base"
lab var afampe_comp "AFAM-PE: Monto complemento liceal"

* guardo 
quietly compress		
notes: afampe.dta \ montos de AFAM-PE: base y complemento \ `tag'
label data "Valor de transferencias AFAM-PE \ `date'"
datasignature set, reset
save  "out/data/afampe.dta", replace
