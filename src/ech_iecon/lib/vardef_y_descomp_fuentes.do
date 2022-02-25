/* 
	vardef_y_descomposición_fuentes.do
	Se descomponen los ingresos por fuentes

	En las specs de cada año defino una listados de variables para cada
	u


*/

//  #1
//  ajustes previos

// convierto varlists a variables ------------------------------------

* ingresos laborales
loc yl_dep_mon_op "y_pg11p y_pg21p y_pg12p y_pg22p y_pg14p y_pg24p y_pg15p y_pg25p y_pg16p y_pg26p" 
loc yl_dep_mon_os "y_pg11o y_pg21o y_pg12o y_pg22o y_pg14o y_pg24o y_pg15o y_pg25o y_pg16o y_pg26o"
loc yl_dep_esp_op "y_pg17p_mes y_pg17p_ano y_pg27p_mes y_pg27p_ano"
loc yl_dep_esp_os "y_pg17o_mes y_pg17o_ano y_pg27o_mes y_pg27o_ano"
loc yl_dep_ben_op "y_pg13p y_pg23p"
loc yl_dep_ben_os "y_pg13o y_pg23o"
loc yl_ind_mon_op "y_pg31p_mes y_pg41p_mes y_pg51p_mes y_pg71p_mes y_pg31p_ano y_pg41p_ano y_pg51p_ano y_pg71p_ano"
loc yl_ind_mon_os "y_pg31o_mes y_pg41o_mes y_pg51o_mes y_pg71o_mes y_pg31o_ano y_pg41o_ano y_pg51o_ano y_pg71o_ano"
loc yl_ind_esp_op "y_pg33p y_pg43p y_pg52p y_pg73p"
loc yl_ind_esp_os "y_pg33o y_pg43o y_pg52o y_pg73o"
* ingresos por transferencias
loc yt_contrib "y_pg111_per y_pg111_hog y_pg112_per y_pg112_hog"
* ingresos de capital
loc yk_rentas "y_pg121_ano y_pg121_mes y_pg122_ano y_pg122_mes y_pg131 y_pg132"
loc yk_util   "y_util_per y_util_hog"
loc yk_otro   "y_otrok_hog"

* lista de varlists
loc varlist_list `yl_dep_mon_op' `yl_dep_mon_os' `yl_dep_esp_op' `yl_dep_esp_os' `yl_dep_ben_op' `yl_dep_ben_os' ///
				 `yl_ind_mon_op' `yl_ind_mon_os' `yl_ind_esp_op' `yl_ind_esp_os' ///
			     `yt_contrib' ///
				 `yk_rentas' `yk_util' `yk_otro'

* genero variables agregadas de cada rubro
foreach varn in `varlist_list' {
	egen `varn' = rowtotal(``varn'')
}

// ajustes de variables ----------------------------------------------

* fix: monto hog constituido=0 para los que no cobran o que declaran incluido en el sueldo
replace mto_hogc = 0 if g149!=1 | g149_1==1

* suma de cuotas mutuales pagas por empleador
egen yt_ss_totemp = rowtotal(yt_ss_iamcemp yt_ss_privemp yt_ss_asseemp yt_ss_emeremp)

//  #2 -------------------------------------------------------------------------
// 	Valor locativo -------------------------------------------------------------

cap gen loc=substr(loc_agr, 3,3)
destring loc, replace
 
cap drop bc_pg14
gen     bc_pg14 = 0
replace bc_pg14 = d8_3 if (d8_1!=6 & (d8_1!=5 & loc!=900))	// Código compatible
replace bc_pg14 = 0    if ine_ht13==0 & d8_1!=6				// Excepción porque nosotros no podemos identificar zonas rurales en Mdeo, entonces tomamos valor de INE

gen    sal_esp_net = g129_2-bc_pg14 if d8_1==6 & g129_2!=0 // Salario en especie neto de valor locativo para ocupantes en rel. de dependencia
recode sal_esp_net   (. = 0)
	
gen     corr_sal_esp = -bc_pg14 if sal_esp_net>0  // Corrección para salario en especie, es el valor locativo (*-1) si esta diferencia es positiva
replace corr_sal_esp = -g129_2  if sal_esp_net<=0 // Corrección para salario en especie, es todo el salario en especie si la dif entre valor loc y salario es negativa
/* 
gen bc_pg14      = ine_ht13 // en p19: compare ht13 bc_pg14 solo son != en 22 obs. good enough
gen sal_esp_net  = 0
gen corr_sal_esp = 0
 */
//  #3 -------------------------------------------------------------------------
// 	Ingresos por rubro para dependientes ---------------------------------------

// dependientes en ocupación principal -------------------------------

// ingresos monetarios por rubro para dependientes en ocupación principal
* Se distingue entre trabajadores públicos y privados

gen bc_pg11p = y_pg11p if bc_pf41==1 // sueldos o jornales líquidos privados
gen bc_pg21p = y_pg21p if bc_pf41==2 // sueldos o jornales líquidos públicos
gen bc_pg12p = y_pg12p if bc_pf41==1 // complementos salariales privados
gen bc_pg22p = y_pg22p if bc_pf41==2 // complementos salariales públicos
gen bc_pg14p = y_pg14p if bc_pf41==1 // aguinaldo privados
gen bc_pg24p = y_pg24p if bc_pf41==2 // aguinaldo públicos
gen bc_pg15p = y_pg15p if bc_pf41==1 // salario vacacional privados
gen bc_pg25p = y_pg25p if bc_pf41==2 // salario vacacional públicos
gen bc_pg16p = y_pg16p if bc_pf41==1 // propinas privados
gen bc_pg26p = y_pg26p if bc_pf41==2 // propinas públicos

// ingresos en especie para dependientes en ocupación principal

/* 
	Además de los ingresos declarados imputo cuotas mutuales pagas
	por empleador y la corrección por vivienda paga por empleador.
*/

gen bc_pg17p = y_pg17p_mes + y_pg17p_ano/12 + yt_ss_totemp + corr_sal_esp if bc_pf41==1
gen bc_pg27p = y_pg27p_mes + y_pg27p_ano/12 + yt_ss_totemp + corr_sal_esp if bc_pf41==2

// beneficios sociales para dependientes en ocupación principal

* beneficios sociales privados
gen     bc_pg13p = y_pg13p + mto_hogc             if bc_pf41==1 
replace bc_pg13p = y_pg13p + mto_hogc + YTRANSF_2 if bc_pf41==1 & afam_nosueldo==1 & afam_pe==0

* beneficios sociales privados
gen     bc_pg23p = y_pg23p + mto_hogc             if bc_pf41==2 
replace bc_pg23p = y_pg23p + mto_hogc + YTRANSF_2 if bc_pf41==2 & afam_nosueldo==1 & afam_pe==0

// dependientes en ocupación secundaria ------------------------------

// 	Ingresos monetarios por rubro para dependientes en ocupación secundaria 

gen bc_pg11o = y_pg11o if deppri_os // sueldos o jornales líquidos privados
gen bc_pg21o = y_pg21o if deppub_os // sueldos o jornales líquidos públicos
gen bc_pg12o = y_pg12o if deppri_os // complementos salariales privados
gen bc_pg22o = y_pg22o if deppub_os // complementos salariales públicos
gen bc_pg14o = y_pg14o if deppri_os // aguinaldo privados
gen bc_pg24o = y_pg24o if deppub_os // aguinaldo públicos
gen bc_pg15o = y_pg15o if deppri_os // salario vacacional privados
gen bc_pg25o = y_pg25o if deppub_os // salario vacacional públicos
gen bc_pg16o = y_pg16o if deppri_os // propinas privados
gen bc_pg26o = y_pg26o if deppub_os // propinas publicos

// ingreso en especie para dependientes en ocupación secundaria 

* dependientes privados os
* 	agrega cuotas mutuales si no son dependientes en ocupación principal
gen     bc_pg17o = y_pg17o_mes + y_pg17o_ano/12 if deppri_os
replace bc_pg17o = bc_pg17o + yt_ss_totemp      if deppri_os & !inlist(bc_pf41, 1, 2)

* dependientes públicos os
gen bc_pg27o = y_pg27o_mes + y_pg27o_ano/12 if deppub_os // –– ¿por qué no imputa cuotas mutuales acá?

// Transferencias de ocupación secundaria no declaradas en el sueldo

* dependientes privados en ocupacion secundaria
gen     bc_pg13o = y_pg13o  + mto_hogc             if deppri_os & !inlist(bc_pf41, 1, 2, 3, 5, 6)
replace bc_pg13o = bc_pg13o + mto_hogc + YTRANSF_2 if deppri_os & !inlist(bc_pf41, 1, 2, 3, 5, 6) ///
												     & afam_nosueldo==1 & afam_pe==0
* dependientes públicos en ocupación secundaria
gen     bc_pg23o = y_pg23o  + mto_hogc             if deppub_os & !inlist(bc_pf41, 1, 2, 3, 5, 6)
replace bc_pg23o = bc_pg23o + mto_hogc + YTRANSF_2 if deppub_os & !inlist(bc_pf41, 1, 2, 3, 5, 6) ///
												     & afam_nosueldo==1 & afam_pe==0

// Ingreso total trabajadores dependientes

* recodifico para no se pierdan sumas por mv
recode bc_pg??p bc_pg??o (. = 0)

* sumo ingreso por rubros en ocupación principal y secundaria
gen bc_pg11t = bc_pg11o + bc_pg21o
gen bc_pg12t = bc_pg12o + bc_pg22o
gen bc_pg13t = bc_pg13o + bc_pg23o
gen bc_pg14t = bc_pg14o + bc_pg24o
gen bc_pg15t = bc_pg15o + bc_pg25o
gen bc_pg16t = bc_pg16o + bc_pg26o
gen bc_pg17t = bc_pg17o + bc_pg27o // Se introduce el cambio por no descomponer fonasa por fuentes

//  #4 -------------------------------------------------------------------------
// 	Ingresos por rubro para independientes -------------------------------------

// Ingresos laborales en ocupaciones no dependientes

* ingresos por transferencia para ocupación principal
gen bc_pg32p=0
replace bc_pg32p=g148_4+mto_hogc  if bc_pf41==5  // Cuenta propia sin local
replace bc_pg32p=YTRANSF_2+g148_4+mto_hogc if bc_pf41==5 & afam_nosueldo==1 & afam_pe==0 // Cuenta propia sin local
gen bc_pg42p=0
replace bc_pg42p=g148_4+mto_hogc if bc_pf41==6   // Cuenta propia con local
replace bc_pg42p=YTRANSF_2+g148_4+mto_hogc  if bc_pf41==6 & afam_nosueldo==1 & afam_pe==0 // Cuenta propia con local
gen bc_pg72p=0
replace bc_pg72p=g148_4+mto_hogc if bc_pf41==3 // Cooperativista
replace bc_pg72p=YTRANSF_2+g148_4+mto_hogc if bc_pf41==3 & afam_nosueldo==1 & afam_pe==0 // Cooperativista

* ingresos por transferencias ocupaciones secundarias
capture drop  bc_pg32o
capture drop  bc_pg42o
capture drop  bc_pg72o
gen bc_pg32o=0
replace bc_pg32o=g148_4+mto_hogc if bc_pf41o==5 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1) 
replace bc_pg32o=YTRANSF_2+g148_4+mto_hogc if bc_pf41o==5 & afam_nosueldo==1 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0
gen bc_pg42o=0
replace bc_pg42o=g148_4+mto_hogc if bc_pf41o==6  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)
replace bc_pg42o=YTRANSF_2+g148_4+mto_hogc  if bc_pf41o==6 & afam_nosueldo==1 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0
gen bc_pg72o=0
replace bc_pg72o=g148_4+mto_hogc if bc_pf41o==3  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)
replace bc_pg72o=YTRANSF_2+g148_4+mto_hogc if bc_pf41o==3 &afam_nosueldo==1 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0

// trabajador no dependiente - ingresos por negocios propios

* ocupación principal
gen bc_pg31p = y_pg31p_mes + y_pg31p_ano/12 if bc_pf41==5 // Cp sin local - Dinero
gen bc_pg41p = y_pg41p_mes + y_pg41p_ano/12 if bc_pf41==6 // Cp con local - Dinero
gen bc_pg51p = y_pg51p_mes + y_pg51p_ano/12 if bc_pf41==4 // patrón - Dinero
gen bc_pg71p = y_pg71p_mes + y_pg71p_ano/12 if bc_pf41==3 // cooperativista
gen bc_pg33p = y_pg33p + yt_ss_totemp       if bc_pf41==5 // Cp sin local - Especie
gen bc_pg43p = y_pg43p + yt_ss_totemp       if bc_pf41==6 // Cp con local - Especie
gen bc_pg52p = y_pg52p + yt_ss_totemp       if bc_pf41==4 // patrón - Especie
gen bc_pg73p = y_pg73p + yt_ss_totemp       if bc_pf41==3 // cooperativista - Especie

* ocupación secundaria
gen bc_pg31o = y_pg31o_mes + y_pg31o_ano/12 if bc_pf41o==5 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg31p, 0,.) 
gen bc_pg41o = y_pg41o_mes + y_pg41o_ano/12 if bc_pf41o==6 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg41p, 0,.) 
gen bc_pg51o = y_pg51o_mes + y_pg51o_ano/12 if bc_pf41o==4 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg51p, 0,.) 
gen bc_pg71o = y_pg71o_mes + y_pg71o_ano/12 if bc_pf41o==3 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg71p, 0,.) 
gen bc_pg33o = y_pg33p                      if bc_pf41o==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg43o = y_pg43p                      if bc_pf41o==6 & !inrange(bc_pf41, 3, 6)
gen bc_pg52o = y_pg52p                      if bc_pf41o==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg73o = y_pg73p                      if bc_pf41o==3 & !inrange(bc_pf41, 3, 6)


// otros ingresos laborales

capture drop bc_otros_lab

* ocupación principal
cap drop bc_otros_lab
gen bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
    + (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
    + g133_1 + (g133_2/12) + g131_1 + corr_sal_esp  ///
    if !inlist(bc_pf41, 1, 2)

replace bc_otros_lab = g142 + g144_1 + (g145 + g146 + g147)/12 ///
	if !independiente_op & !independiente_os 

replace bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
	+ (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
	+ g133_1 + (g133_2/12) + g142 + g144_1 + (g145 + g146 + g147)/12 + corr_sal_esp  ///
	if !inrange(bc_pf41, 1, 6) & !independiente_os  // Otras actividades

replace bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
	+ (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
	+ g133_1 + (g133_2/12) + g142 + g144_1 +(g145 + g146 + g147)/12 ///
	+ g144_2_1 + g144_2_2 + g144_2_3 + g144_2_4 + g144_2_5 + g131_1 ///
	+ corr_sal_esp ///
	if bc_pf41==-9

* recode  bc_otros_lab (. = 0)

* otras ocupaciones
capture drop bc_otros_lab2
gen bc_otros_lab2 = g134_1 + g134_2 + g134_3 + g134_4 + g134_5 + g134_6 + g134_8 ///
	+ g135_3 + g136_1 + g137_2 + g138_1 + (g135_1*mto_des) + (g135_2*mto_alm) ///
	+ (g140_1*mto_vac) + (g140_2*mto_ove) + (g140_3*mto_cab) + g141_1 + (g141_2/12) + g139_1 ///
	if !inlist(bc_pf41o, 1, 2)
recode  bc_otros_lab2 (. = 0)

capture drop bc_otros_benef
gen     bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1
replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 if afam_pe>0 // 2/6/20 cambio hay que ver si no está duplicando para bc_pf41 = 7 o 4????
replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(bc_pf41o, 1, 2, 3, 5, 6)

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 // esta linea borra todo lo anterior

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(bc_pf41o, 1, 2, 3, 5, 6)

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 ///
	if /* (g150==1 | g257>0) & */ (afam_pe>0) // 08/04/19 cambio

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 +             g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(bc_pf41o, 1, 2, 3, 5, 6) & esjefe

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(bc_pf41o, 1, 2, 3, 5, 6) & esjefe

/* las últimas dos lineas son contradictorias / gsl 2021-09-20 */

//  #5 -------------------------------------------------------------------------
// 	Jubilaciones ---------------------------------------------------------------

foreach varlist in y_pg911 y_pg912 y_pg921 y_pg922 y_pg101 y_pg102 {
	egen `varlist' = rowtotal(``varlist'')
}

// jubilaciones y pensiones

gen bc_pg911 = y_pg911 if f124_1==1
gen bc_pg912 = y_pg912 if f124_2==1
recode bc_pg911 bc_pg912 (. = 0)

gen bc_pg921 = y_pg921 
gen bc_pg922 = y_pg922

gen bc_pg91  = bc_pg911+bc_pg912
gen bc_pg92  = bc_pg921+bc_pg922

// becas y subsidios

* sumo ingresos de becas y subsidios
gen bc_pg101 = y_pg101
gen bc_pg102 = y_pg102
* fix: otras canastas se suman al mismo rubro y ya están contadas
*	–– 2018 en adelante
replace bc_pg101 = y_pg101 - `y_pg101_fix'
replace bc_pg102 = y_pg102 - `y_pg102_fix'

// contribuciones – transferencias entre hogares

* del país
gen     bc_pg111 = y_pg111_per
replace bc_pg111 = y_pg111_per + y_pg111_hog + yt_ss_emerotr if esjefe
* del exterior
gen     bc_pg112 = y_pg112_per
replace bc_pg112 = y_pg112_per + y_pg112_hog/12              if esjefe

//  #6 -------------------------------------------------------------------------
// 	Ingresos de capital --------------------------------------------------------

* ingreso por alquiler/arrendamiento de activos (del país/del extranjero)
gen bc_pg121 = y_pg121_ano/12 + y_pg121_mes
gen bc_pg122 = y_pg122_ano/12 + y_pg122_mes

* ingreso por intereses (del país/del extranjero)
gen bc_pg131 = y_pg131/12
gen bc_pg132 = y_pg132/12

* utilidades de independientes por ocupación principal
gen bc_pg60p      = y_util_per/12 if bc_pf41==4
gen bc_pg80p      = y_util_per/12 if bc_pf41==3
gen bc_pg60p_cpsl = y_util_per/12 if bc_pf41==5
gen bc_pg60p_cpcl = y_util_per/12 if bc_pf41==6

* utilidades de independientes por ocupación secundaria
gen bc_pg60o      = y_util_per/12 if inlist(bc_pg60p, 0, .)      & bc_pf41o==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg80o      = y_util_per/12 if inlist(bc_pg80p, 0, .)      & bc_pf41o==3 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpsl = y_util_per/12 if inlist(bc_pg60p_cpsl, 0, .) & bc_pf41o==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpcl = y_util_per/12 if inlist(bc_pg60p_cpcl, 0, .) & bc_pf41o==6 & !inrange(bc_pf41, 3, 6)

* Utilidades a nivel de hogar independientes
gen    bc_ot_utilidades = y_util_hog/12 if (inlist(bc_pf41, 3, 4, 5, 6) | inlist(bc_pf41o, 3, 4, 5, 6)) & esjefe
recode bc_ot_utilidades (. = 0)

* Utilidades de dependientes
gen     bc_otras_utilidades = y_util_per/12                 if !inrange(bc_pf41, 3, 6) & !inrange(bc_pf41o, 3, 6)
replace bc_otras_utilidades = y_util_per/12 + y_util_hog/12 if !inrange(bc_pf41, 3, 6) & !inrange(bc_pf41o, 3, 6) & esjefe
recode  bc_otras_utilidades (. = 0)

* Medianería, pastoreo y ganado a capitalizar a nivel de hogar
gen    bc_otras_capital = y_otrok_hog/12  if esjefe
recode bc_otras_capital (. = 0)

//  #7 -------------------------------------------------------------------------
//  Ingresos por otro concepto -------------------------------------------------

/* 
	Dependiendo del año incluye pagos atrasados -bc_pag_at-, otro ingreso
	corriente -g154_1- y devoluciones de fonasa -g258_1/12- 

	Indemnización por despido -h171_1/12- se pregunta a nivel de hogar y se
	imputa al jefe/a.
*/

* pagos atrasados
egen bc_pag_at = rowtotal(`pagos_atrasados')

* devolución fonasa
gen bc_devol_fonasa = `devolucion_fonasa'

* otros ingresos
gen     otros = bc_pag_at + g154_1 + bc_devol_fonasa/12
replace otros = otros + h171_1/12  if esjefe

//  #8 -------------------------------------------------------------------------
// 	Dropeo auxiliares ----------------------------------------------------------

drop `varlist_list'
