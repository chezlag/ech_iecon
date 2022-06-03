/* 
	vardef_y_descomposición_fuentes.do
	Se descomponen los ingresos por fuentes

	En las specs de cada año defino una listados de variables para cada
	u

	En las ECH de los '90 se preguntaba por separado los ingresos de dependientes
	privados, dependientes públicos y trabajadores independientes. Si bien la 
	forma de relevamiento cambió, reconstruímos los ingresos de esta forma para 
	mantener la continuidad de la serie.

*/

//  #1 -------------------------------------------------------------------------
//  ajustes previos ------------------------------------------------------------

* fix: monto hog constituido=0 para los que no cobran o que declaran incluido en el sueldo
replace mto_hogc = 0 if g149!=1 | g149_1==1

* suma de beneficios sociales no incluidos en el salario
gen     yl_bentot  = yl_ben_mon + mto_hogc
replace yl_bentot  = yl_ben_mon + mto_hogc + YTRANSF_2 if afam_nosueldo==1 & afam_pe==0

* suma de cuotas mutuales pagas por empleador
egen yt_ss_totemp = rowtotal(yt_ss_iamcemp yt_ss_privemp yt_ss_asseemp yt_ss_emeremp)

// 	Valor locativo -----------------------------------------

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

//  #3 -------------------------------------------------------------------------
// 	Ingresos laborales por rubro -----------------------------------------------

// YL dependientes en ocupación principal ----------------------------

// ingresos monetarios por rubro para dependientes en ocupación principal
* Se distingue entre trabajadores públicos y privados

gen bc_pg11p = yl_rem_salario_op    if bc_pf41==1 // sueldos o jornales líquidos privados
gen bc_pg21p = yl_rem_salario_op    if bc_pf41==2 // sueldos o jornales líquidos públicos
gen bc_pg12p = yl_rem_comisiones_op if bc_pf41==1 // complementos salariales privados
gen bc_pg22p = yl_rem_comisiones_op if bc_pf41==2 // complementos salariales públicos
gen bc_pg14p = yl_rem_aguinaldo_op  if bc_pf41==1 // aguinaldo privados
gen bc_pg24p = yl_rem_aguinaldo_op  if bc_pf41==2 // aguinaldo públicos
gen bc_pg15p = yl_rem_vacacional_op if bc_pf41==1 // salario vacacional privados
gen bc_pg25p = yl_rem_vacacional_op if bc_pf41==2 // salario vacacional públicos
gen bc_pg16p = yl_rem_propina_op    if bc_pf41==1 // propinas privados
gen bc_pg26p = yl_rem_propina_op    if bc_pf41==2 // propinas públicos

// ingresos en especie para dependientes en ocupación principal

/* 
	Además de los ingresos declarados imputo cuotas mutuales pagas
	por empleador y la corrección por vivienda paga por empleador.
*/

gen bc_pg17p = yl_rem_esp_op + yt_ss_totemp + corr_sal_esp if bc_pf41==1
gen bc_pg27p = yl_rem_esp_op + yt_ss_totemp + corr_sal_esp if bc_pf41==2

// beneficios sociales para dependientes en ocupación principal

* beneficios sociales privados
gen     bc_pg13p = yl_bentot if bc_pf41==1 
gen     bc_pg23p = yl_bentot if bc_pf41==2 


// YL dependientes en ocupación secundaria ---------------------------

// 	Ingresos monetarios por rubro para dependientes en ocupación secundaria 

gen bc_pg11o = yl_rem_salario_os    if bc_pf41o==1 // sueldos o jornales líquidos privados
gen bc_pg21o = yl_rem_salario_os    if bc_pf41o==2 // sueldos o jornales líquidos públicos
gen bc_pg12o = yl_rem_comisiones_os if bc_pf41o==1 // complementos salariales privados
gen bc_pg22o = yl_rem_comisiones_os if bc_pf41o==2 // complementos salariales públicos
gen bc_pg14o = yl_rem_aguinaldo_os  if bc_pf41o==1 // aguinaldo privados
gen bc_pg24o = yl_rem_aguinaldo_os  if bc_pf41o==2 // aguinaldo públicos
gen bc_pg15o = yl_rem_vacacional_os if bc_pf41o==1 // salario vacacional privados
gen bc_pg25o = yl_rem_vacacional_os if bc_pf41o==2 // salario vacacional públicos
gen bc_pg16o = yl_rem_propina_os    if bc_pf41o==1 // propinas privados
gen bc_pg26o = yl_rem_propina_os    if bc_pf41o==2 // propinas publicos

// ingreso en especie para dependientes en ocupación secundaria 

* dependientes privados os
* 	agrega cuotas mutuales si no son dependientes en ocupación principal
gen     bc_pg17o = yl_rem_esp_os                if bc_pf41o==1
replace bc_pg17o = yl_rem_esp_os + yt_ss_totemp if bc_pf41o==1 & !inlist(bc_pf41, 1, 2)

* dependientes públicos os
gen     bc_pg27o = yl_rem_esp_os                if bc_pf41o==2 // –– ¿por qué no imputa cuotas mutuales acá?

// Transferencias de ocupación secundaria no declaradas en el sueldo

gen bc_pg13o = yl_bentot if bc_pf41o==1 & !inlist(bc_pf41, 1, 2, 3, 5, 6)
gen bc_pg23o = yl_bentot if bc_pf41o==2 & !inlist(bc_pf41, 1, 2, 3, 5, 6)

// Ingreso total trabajadores dependientes

* recodifico mv
mvencode bc_pg??p bc_pg??o, mv(0) override

* sumo ingreso por rubros en ocupación principal y secundaria
egen bc_pg11t = rowtotal(bc_pg11o bc_pg21o)
egen bc_pg12t = rowtotal(bc_pg12o bc_pg22o)
egen bc_pg13t = rowtotal(bc_pg13o bc_pg23o)
egen bc_pg14t = rowtotal(bc_pg14o bc_pg24o)
egen bc_pg15t = rowtotal(bc_pg15o bc_pg25o)
egen bc_pg16t = rowtotal(bc_pg16o bc_pg26o)
egen bc_pg17t = rowtotal(bc_pg17o bc_pg27o) // Se introduce el cambio por no descomponer fonasa por fuentes

// YL trabajadores independientes ------------------------------------

// beneficios sociales para independientes

* beneficios sociales op
gen bc_pg32p = yl_bentot if bc_pf41==5 
gen bc_pg42p = yl_bentot if bc_pf41==6   
gen bc_pg72p = yl_bentot if bc_pf41==3 

* beneficios sociales os
gen bc_pg32o = yl_bentot if bc_pf41o==5 & !inlist(bc_pf41, 1,2,3,5,6)
gen bc_pg42o = yl_bentot if bc_pf41o==6 & !inlist(bc_pf41, 1,2,3,5,6)
gen bc_pg72o = yl_bentot if bc_pf41o==3 & !inlist(bc_pf41, 1,2,3,5,6) 

* recodifico mv
recode bc_pg32? bc_pg42? bc_pg72? (. = 0)

// ingresos por negocios propios para independientes

* negoricos propios ocupación principal
gen bc_pg31p = yl_mix_mon                if bc_pf41==5
gen bc_pg41p = yl_mix_mon                if bc_pf41==6
gen bc_pg51p = yl_mix_mon                if bc_pf41==4
gen bc_pg71p = yl_mix_mon                if bc_pf41==3
gen bc_pg33p = yl_mix_esp + yt_ss_totemp if bc_pf41==5
gen bc_pg43p = yl_mix_esp + yt_ss_totemp if bc_pf41==6
gen bc_pg52p = yl_mix_esp + yt_ss_totemp if bc_pf41==4
gen bc_pg73p = yl_mix_esp + yt_ss_totemp if bc_pf41==3

* negocios propios ocupación secundaria
gen bc_pg31o = yl_mix_mon                if bc_pf41o==5 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg31p, 0,.) 
gen bc_pg41o = yl_mix_mon                if bc_pf41o==6 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg41p, 0,.) 
gen bc_pg51o = yl_mix_mon                if bc_pf41o==4 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg51p, 0,.) 
gen bc_pg71o = yl_mix_mon                if bc_pf41o==3 & !inrange(bc_pf41, 3, 6) & inlist(bc_pg71p, 0,.) 
gen bc_pg33o = yl_mix_esp                if bc_pf41o==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg43o = yl_mix_esp                if bc_pf41o==6 & !inrange(bc_pf41, 3, 6)
gen bc_pg52o = yl_mix_esp                if bc_pf41o==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg73o = yl_mix_esp                if bc_pf41o==3 & !inrange(bc_pf41, 3, 6)

// otros ingresos laborales ------------------------------------------

* ocupación principal
gen     bc_otros_lab = yl_rem_mon_op + yl_rem_esp_op                                     + corr_sal_esp if !inlist(bc_pf41, 1,2)
replace bc_otros_lab =                                 yl_mix_mon + g144_1                         if !inrange(bc_pf41, 3,6) & !inrange(bc_pf41o, 3,6)
replace bc_otros_lab = yl_rem_mon_op + yl_rem_esp_op + yl_mix_mon + g144_1          + corr_sal_esp if !inrange(bc_pf41, 1,6) & !independiente_os 
replace bc_otros_lab = yl_rem_mon_op + yl_rem_esp_op + yl_mix_mon + yl_mix_esp + corr_sal_esp if bc_pf41==-9

* otras ocupaciones
gen bc_otros_lab2 = yl_rem_mon_os + yl_rem_esp_os if !inlist(bc_pf41o, 1, 2)

// otros beneficios sociales -----------------------------------------

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

//  #4 -------------------------------------------------------------------------
// 	Transferencias -------------------------------------------------------------

// jubilaciones y pensiones

gen bc_pg911 = y_pg911 if f124_1==1
gen bc_pg912 = y_pg912 if f124_2==1
recode bc_pg911 bc_pg912 (. = 0)

gen bc_pg921 = y_pg921
gen bc_pg922 = y_pg922

egen bc_pg91  = rowtotal(bc_pg911 bc_pg912)
egen bc_pg92  = rowtotal(bc_pg921 bc_pg922)

// becas y subsidios

* sumo ingresos de becas y subsidios
gen bc_pg101 = y_pg101
gen bc_pg102 = y_pg102
* fix: otras canastas se suman al mismo rubro y ya están contadas
*	–– 2018 en adelante
replace bc_pg101 = y_pg101 - `y_pg101_fix'
replace bc_pg102 = y_pg102 - `y_pg102_fix'

// transferencias entre hogares

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
gen bc_pg60p      = yk_util_per/12 if bc_pf41==4
gen bc_pg80p      = yk_util_per/12 if bc_pf41==3
gen bc_pg60p_cpsl = yk_util_per/12 if bc_pf41==5
gen bc_pg60p_cpcl = yk_util_per/12 if bc_pf41==6

* utilidades de independientes por ocupación secundaria
gen bc_pg60o      = yk_util_per/12 if inlist(bc_pg60p, 0, .)      & bc_pf41o==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg80o      = yk_util_per/12 if inlist(bc_pg80p, 0, .)      & bc_pf41o==3 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpsl = yk_util_per/12 if inlist(bc_pg60p_cpsl, 0, .) & bc_pf41o==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpcl = yk_util_per/12 if inlist(bc_pg60p_cpcl, 0, .) & bc_pf41o==6 & !inrange(bc_pf41, 3, 6)

* Utilidades a nivel de hogar independientes
gen    bc_ot_utilidades = yk_util_hog/12 if (inlist(bc_pf41, 3, 4, 5, 6) | inlist(bc_pf41o, 3, 4, 5, 6)) & esjefe
recode bc_ot_utilidades (. = 0)

* Utilidades de dependientes
gen     bc_otras_utilidades = yk_util_per/12                 if !inrange(bc_pf41, 3, 6) & !inrange(bc_pf41o, 3, 6)
replace bc_otras_utilidades = yk_util_per/12 + yk_util_hog/12 if !inrange(bc_pf41, 3, 6) & !inrange(bc_pf41o, 3, 6) & esjefe
recode  bc_otras_utilidades (. = 0)

* Medianería, pastoreo y ganado a capitalizar a nivel de hogar
gen    bc_otras_capital = yk_otro_hog/12  if esjefe
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
egen bc_pag_at = rowtotal(`yl_rem_atrasado_op' `yl_rem_atrasado_os')

* devolución fonasa
gen bc_devol_fonasa = `devolucion_fonasa'

* otros ingresos
gen     otros = bc_pag_at + g154_1 + bc_devol_fonasa/12
replace otros = otros + h171_1/12  if esjefe

//  #8 -------------------------------------------------------------------------
// 	Últimos retoques -----------------------------------------------------------

* recodifico missing // para mi esto tendría que ir pero ta pa discutirlo
mvencode bc_pg??p bc_pg??o, mv(0) override

* dropeo variables auxiliares
*drop `varlist_list'
