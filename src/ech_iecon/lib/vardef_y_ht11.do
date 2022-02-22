/* 
	vardef_y_ht11.do
	Reconstrucción del ingreso ht11 con criterios del INE y ajustes IECON

	Primero reconstruye los ingresos laborales, empezando por el salario en 
	especie. Se hace una desagregación de las cuotas mutuales y se las asigna
	a quienes generan el derecho de atención. En el caso de las cuotas 
	generadas fuera del hogar, estas se asignan al jefe/a de hogar. Luego,
	se reconstruye el salario monetario y se agregan entre si. 

	Segundo se reconstruyen los ingresos de transferencias. Se consideran 
	jubilaciones y pensiones, transferencias monetarias, y transferencias en
	especie. 

	Tercero se construyen los agregados de ingreso personal y del hogar 
	siguiendo los criterios del INE. En este punto, termina la reconstrucción
	y se pasa a las modificaciones del IECON.

	Las últimas modificaciones en este do-file consisten en 

*/

//  #1 -------------------------------------------------------------------------
//  Salario en especie: Cuotas mutuales ----------------------------------------

//  Cuotas militares -------------------------------------------------

* Se calcula cuotas militares, adjudicadas a militar que las genera.
* 	Se toma a quienes tienen derecho en sanidad militar a través de un miembro 
*	de este hogar y a su vez no generan derecho por FONASA, ya sea por miembro 
*	del hogar o por otro hogar.

* para definir la rama militar en ocupación ppal o secundaria
local ciiu_militar "5222, 5223, 8030, 8411, 8421, 8422, 8423, 8430, 8521, 8530, 8610"

gen at_milit  = ss_mili_o_h & !ss_sinpago
gen at_milit2 = ss_mili & !ss_sinpago

sort bc_correlat bc_nper

* numero de personas con acceso a salud militar en el hogar, por persona que genera el derecho
egen n_milit = sum(ss_mili_o_h & !ss_sinpago) if nper_d_mili>0, by(bc_correlat nper_d_mili)

// cuota militar por ocupación principal

* ocupada en rama militar en la ocupación principal
gen  ramamilit_op = inlist(ciiu_op, `ciiu_militar')
gen    n_milit_op = n_milit if ramamilit_op & nper_d_mili==bc_nper
recode n_milit_op (. = 0)
* valorizo con el monto de la cuota
gen    ytdop_2      = n_milit_op * mto_cuot

// Cuota militar ocupación secundaria.

gen    ramamilit_os  = inlist(ciiu_os, `ciiu_militar')
gen    n_milit_os  = n_milit if ramamilit_os & nper_d_mili==bc_nper & n_milit_op==0
recode n_milit_os (. = 0)
gen    ytdos_2       = n_milit_os * mto_cuot

// total de cuotas militares en el hogar

*Se suman todas las cuotas de op, os
egen n_milit_op_hog = sum(n_milit_op)          , by(bc_correlat)
egen n_milit_os_hog = sum(n_milit_os)          , by(bc_correlat)

* se suma el total de cuotas militares del hogar
egen n_milit_hog    = sum(ss_mili & !ss_sinpago), by(bc_correlat)

* a partir de la diferencia, se encuentra las cuotas militares provenientes de otro hogar
gen  n_militotr     = n_milit_hog - (n_milit_op_hog + n_milit_os_hog)
gen  yt_ss_militotr = n_militotr * mto_cuot
* asigna las cuotas al jefx
replace yt_ss_militotr = 0 if !esjefe

//  Cuotas fonasa ----------------------------------------------------

// cuotas fonasa adjudicables al trabajador

* trabajador dependiente formal en ocupación principal.
gen ytdop_3 = mto_cuot if dependiente_op & formal_op & ss_fonasa_o_h 
recode ytdop_3 (. = 0)

* trabajador dependiente formal en ocupación secundaria.
gen ytdos_3 = mto_cuot if dependiente_os & formal_os & ss_fonasa_o_h ///
						& ytdop_2==0 & ytdop_3==0 // Por qué no se incluye ytdos_2??? / sofi santin
recode ytdos_3 (. = 0)

* trabajador independiente formal
gen YTINDE_2 = mto_cuot if ((independiente_op & formal_op) | (independiente_os & formal_os)) & ss_fonasa_o_h ///
						& ytdop_3==0 & ytdos_3==0 & ytdop_2==0 & ytdos_2==0
recode YTINDE_2 (. = 0)

// cuotas de fonasa no originadas por el trabajador

* para todos quienes generan derecho por FONASA y no son adjudicables al trabajo.
gen ss_fonasa_nolab = ss_fonasa & ytdop_3 ==0 & ytdos_3 ==0 & YTINDE_2 ==0
	
* sumo cuotas no laborales, monetizo, y se las imputo al jefe
egen    n_fonasa_nolab = sum(ss_fonasa_nolab), by(bc_correlat)
replace n_fonasa_nolab = 0 if !esjefe
gen yt_ss_fonasa_nolab = n_fonasa_nolab * mto_cuot

//  Cuotas mutuales y emergencia pagas por empleador  ----------------

* cuotas pagas por empleador para cada rubro :: yt_ss_asseemp, yt_ss_iamcemp, yt_ss_privemp
foreach ss in asseemp iamcemp privemp emeremp {
	* nro de cuotas que genera cada integrante del hogar
	egen n_`ss' = sum(ss_`ss') if nper_d_`ss'>0, by (bc_correlat nper_d_`ss')
	recode n_`ss' (. = 0)

	cap drop CuotasGeneradas
	gen CuotasGeneradas = .
	qui sum nper_d_`ss'
	forvalues i = 1/`r(max)' { 
		gen aux`i' = n_`ss' if nper_d_`ss'==`i'
		egen aux`i'_max = max(aux`i'), by(bc_correlat)
		replace CuotasGeneradas = aux`i'_max if bc_nper==`i'
		drop aux`i'*
	}
	recode CuotasGeneradas (. = 0)
	sum CuotasGeneradas, d
	* ingreso total de transferencias para cada seguro de salud
	gen yt_ss_`ss' = CuotasGeneradas * mto_cuot
}

* fix: cuota de emergencia movil paga por empleador usa otro monto
replace yt_ss_emeremp = (yt_ss_emeremp / mto_cuot) * mto_emer

* agrego ingreso en especie por salud en mutualistas o seguro privado
gen yt_ss_emp = yt_ss_privemp + yt_ss_iamcemp

// Derechos de salud para este hogar provenientes de otros hogares

* cuotas para este hogar generadas desde otro hogar 
egen    n_otrohog     = sum(ss_otrohog), by(bc_correlat)
replace n_otrohog     = 0 if !esjefe
gen     yt_ss_otrohog = n_otrohog * mto_cuot 

* emeregencia móvil
egen    n_emerotr    = sum(ss_emerotr), by(bc_correlat)
replace n_emerotr    = 0 if !esjefe
gen    yt_ss_emerotr = n_emerotr * mto_emer


//  #2 -------------------------------------------------------------------------
//  Ingresos laborales por todo concepto ---------------------------------------

// ingresos por trabajo dependiente – ocupación principal

* monetizo los pagos en especie
gen g127_1_y = g127_1 * mto_desa
gen g127_2_y = g127_2 * mto_almu
gen g132_1_y = g132_1 * mto_vaca
gen g132_2_y = g132_2 * mto_ovej
gen g132_3_y = g132_3 * mto_caba
* mensualizo ingresos relevados en forma anual
gen g133_2_y = g133_2 / 12

* genero locals por rubro para agregarlos
local ytdop_1_dinero   "g126_1   g126_2    g126_3    g126_4 g126_5 g126_6 g126_7 g126_8"
local ytdop_1_aliment  "g127_1_y g127_2_y  g127_3"
local ytdop_1_especie  "g128_1   g129_2    g130_1    g131_1"
local ytdop_1_pastoreo "g132_1_y g132_2_y  g132_3_y"
local ytdop_1_autocult "g133_1   g133_2_y"

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdop_1 = rowtotal(`ytdop_1_dinero' `ytdop_1_aliment' `ytdop_1_especie' ///
						`ytdop_1_pastoreo' `ytdop_1_autocult')

* ingresos TOTALES por trabajo dependiente en op –– sumo cuotas mutuales 
egen YTDOP =  rowtotal(ytdop_1 ytdop_2 ytdop_3 yt_ss_emp yt_ss_emeremp yt_ss_asseemp)

// ingresos por trabajo dependiente – ocupación secundaria

* monetizo los pagos en especie
gen g135_1_y = g135_1 * mto_desa
gen g135_2_y = g135_2 * mto_almu
gen g140_1_y = g140_1 * mto_vaca
gen g140_2_y = g140_2 * mto_ovej
gen g140_3_y = g140_3 * mto_caba
* mensualizo ingresos relevados en forma anual
gen g141_2_y = g141_2 / 12

* genero locals por rubro para agregarlos
local ytdos_1_dinero   "g134_1   g134_2    g134_3    g134_4 g134_5 g134_6 g134_7 g134_8"
local ytdos_1_aliment  "g135_1_y g135_2_y  g135_3"
local ytdos_1_especie  "g136_1   g137_2    g138_1    g139_1"
local ytdos_1_pastoreo "g140_1_y g140_2_y  g140_3_y"
local ytdos_1_autocult "g141_1   g141_2_y"

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdos_1 = rowtotal(`ytdos_1_dinero' `ytdos_1_aliment' `ytdos_1_especie' ///
						`ytdos_1_pastoreo' `ytdos_1_autocult')

* ingresos TOTALES por trabajo dependiente en os –– sumo cuotas mutuales 
egen YTDOS = rowtotal(ytdos_1 ytdos_2 ytdos_3)

// ingresos por trabajo independiente

* mensualizo ingresos relevados en forma anual
foreach varn in g143 g145 g146 g147 {
	gen `varn'_y = `varn'/12
}

* genero locals por rubro para agregarlos
local ytinde_1_utilidades  "g142   g143_y" // utilidades o retiro de $
local ytinde_1_autoconsumo "g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5"
local ytinde_1_negocioagro "g145_y g146_y   g147_y"

egen YTINDE_1 = rowtotal(`ytinde_1_utilidades' `ytinde_1_autoconsumo' `ytinde_1_negocioagro')

* ingresos TOTALES por trabajo independiente –– sumo cuotas mutuales
egen YTINDE   = rowtotal(YTINDE_1 YTINDE_2)


//  #3 -------------------------------------------------------------------------
//  Ingresos por transferencias ------------------------------------------------

//  Jubilaciones y pensiones -----------------------------------------

egen YTRANSF_1 = rowtotal(`ytransf_jyp')

//  Políticas sociales: transferencias monetarias --------------------

// Asignaciones Familiares (no incluídas en el sueldo)

gen    YTRANSF_2 = g257 if g256!=1
recode YTRANSF_2 (. = 0)

// Hogar Constituido

gen    YTRANSF_3 = mto_hogc if (g149==1 & g149_1==2)
recode YTRANSF_3 (. = 0)

//  Políticas sociales: transferencias en especie --------------------

// Transferencias en especie: Alimentos

* recodifico 99s a missing
recode `desaymer' `almycen' (99 = .q)

* numero de desayunos/meriendas y número de almuerzos/cenas
foreach varl in desaymer almycen {
	egen n_`varl' = rowtotal(``varl'')
}

gen DESAYMER = n_desaymer * 4.3 * mto_desa

gen ALMYCEN  = n_almycen  * 4.3 * mto_almu

gen         CANASTA1 = 0
cap replace CANASTA1 = e247*indabajo if e246 == 1
cap replace CANASTA1 = e247*indaplom if e246 == 2
cap replace CANASTA1 = e247*indadiab if e246 == 4
cap replace CANASTA1 = e247*indarena if e246 == 5
cap replace CANASTA1 = e247*indarend if e246 == 6
cap replace CANASTA1 = e247*indaceli if e246 == 7
cap replace CANASTA1 = e247*indatube if e246 == 8
cap replace CANASTA1 = e247*indaonco if e246 == 9
cap replace CANASTA1 = e247*indasida if e246 == 10
cap replace CANASTA1 = e247*indaemer if e246 == 14
	
gen         CANASTA2 = 0
cap replace CANASTA2 = e249*indabajo if e248 == 1
cap replace CANASTA2 = e249*indaplom if e248 == 2
cap replace CANASTA2 = e249*indadiab if e248 == 4
cap replace CANASTA2 = e249*indarena if e248 == 5
cap replace CANASTA2 = e249*indarend if e248 == 6
cap replace CANASTA2 = e249*indaceli if e248 == 7
cap replace CANASTA2 = e249*indatube if e248 == 8
cap replace CANASTA2 = e249*indaonco if e248 == 9
cap replace CANASTA2 = e249*indasida if e248 == 10
cap replace CANASTA2 = e247*indaemer if e248 == 14

gen    CANASTA = CANASTA1 + CANASTA2
recode CANASTA (. = 0)

drop CANASTA1 CANASTA2

// Otras transferencias de alimientación

* tarjetas tus-mides y tus-inda
gen tusmides = `y_tusmides'
gen tusinda  = `y_tusinda'
egen tus       = rowtotal(tusmides tusinda)

* tickets de alimentación del inda
gen ticketsinda = `y_ticketsinda'

* leche en polvo
gen     leche  = `y_lecheenpolvo'
*replace leche  = 0 if inlist(e246, 1, 7) & e560==2 // Ver sintaxis 2018 (por qué hacemos replace?)

//  Se genera una variable de alimentos separando entre mayores y menores de 14

egen yalim_tot     = rowtotal(DESAYMER ALMYCEN CANASTA tus ticketsinda leche)
gen  YALIMENT      = yalim_tot if bc_pe3>=14
gen  YALIMENT_MEN1 = yalim_tot if bc_pe3< 14
recode YALIMENT YALIMENT_MEN1 (. = 0)

gen YTRANSF_4 = YALIMENT

egen    YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
replace YALIMENT_MEN = 0 if !esjefe

//  total de transferencias ------------------------------------------
* 	–– asumo que para mayores de 14 dado el tratamiento de YTRANSF_4 / gsl 2021-08-31

egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)


//  #4 -------------------------------------------------------------------------
//  Ingreso personal total e ingresos del hogar –– replicación INE -------------

* otros ingresos 
gen OTROSY = (g258_1/12) + g154_1 // devolución de fonasa + otros ingresos

// PT1 – ingresos personales

egen    pt1_iecon = rowtotal(YTDOP YTDOS YTINDE YTRANSF OTROSY)
recode  pt1_iecon   (. = 0)

egen    HPT1 = sum(pt1_iecon), by(bc_correlat)
replace HPT1 = 0 if !esjefe

// PT2 – INGRESOS DE LA OCUPACIÓN PRINCIPAL.

*PRIVADOS.
gen  PT2PRIV   = YTDOP if deppri_op

*PÚBLICOS.
gen  PT2PUB    = YTDOP if deppub_op

*INDEPENDIENTE.
gen  PT2NODEP  = YTINDE if independiente_op

* PT2 TOTAL.
egen pt2_iecon = rowtotal(PT2PRIV PT2PUB PT2NODEP)

// PT4 – TOTAL DE INGRESOS POR TRABAJO. OCUPACION PRINCIPAL Y SECUNDARIA

egen pt4_iecon = rowtotal(YTDOP YTDOS YTINDE)

// HT11 – INGRESOS DEL HOGAR

* ingresos relevados con frecuencia anual
#del ;
local yhog_anual "`y_pg121' `y_pg122' `y_otrok_hog' `y_pg131' `y_pg132'
	 `y_util_hog' h171_1   h172_1";
#del cr

egen yhog_anual = rowtotal(`yhog_anual')
	// excluye h173_1 – seguramente por ser ingreso extraordinario

gen yhog1 = h155_1 + h156_1 + h252_1 + (yhog_anual/12) + ///
	yt_ss_militotr + YALIMENT_MEN + yt_ss_fonasa_nolab + yt_ss_emerotr + yt_ss_otrohog

egen yhog_iecon = max(yhog1), by(bc_correlat)
drop yhog_anual yhog1

egen ht11_iecon = rowtotal(HPT1 ine_ht13 yhog_iecon)
