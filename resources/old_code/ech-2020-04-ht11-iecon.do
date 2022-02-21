capture log close
log using "log/ech-2020-04-ingreso-ht11-iecon.log", replace text

//  ech-2020-04-ingreso-ht11-iecon.do
//  gsl \ 2021-09-29

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "2019-04.do gsl `date'"
local fullnm "ech-2020-04-ingreso-ht11-iecon"

// ----------------------------------------------
// use

use "data/tmp/ech-2020-02.dta", clear
datasig confirm
notes _dta

// ----------------------------------------------

//  hotfix
recode g134_1 (999999 = 0)

* derecho a atención en cada servicio
gen ss_asse = inrange(e45_1_1_cv, 1, 6)
gen ss_iamc = inrange(e45_2_1_cv, 1, 6)
gen ss_priv = inrange(e45_3_1_cv, 1, 6)
gen ss_mili = inrange(e45_4_1_cv, 1, 6)

* origen del derecho de atención
clonevar ss_asse_o = e45_1_1_cv
clonevar ss_iamc_o = e45_2_1_cv
clonevar ss_priv_o = e45_3_1_cv
clonevar ss_mili_o = e45_4_1_cv

* derecho de atención militar originado por alguien del hogar
gen     ss_mili_o_h = ss_mili_o==1
* derecho de atención origina en un pago de alguien dentro del hogar
gen ss_asse_o_hpago = inlist(ss_asse_o, 2, 3)
gen ss_iamc_o_hpago = ss_iamc_o==2
gen ss_priv_o_hpago = ss_priv_o==2


* cuota IAMC paga por empleador 
*	excluyendo personas sin derecho a atenderse en ASSE o seguro privado
*	o quienes acceden a través de un pago (o bajos recursos en ASSE)
gen ss_iamcemp =  ss_iamc_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)
* idem para ASSE
gen ss_asseemp =  ss_asse_o==5 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)
* idem para seguro privado
gen ss_privemp =  ss_priv_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago)
* emergencia movil paga por empleador
gen ss_emeremp = e47_cv==4

* cuotas para este hogar generadas desde otro hogar 
gen ss_otrohog = (ss_asse_o==6 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_iamc_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_priv_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago))
* emergencia móvil paga de otro hogar
gen ss_emerotr = e47_cv==3


// nper de personas que generan derechos de salud a otros integrantes del hogar

clonevar nper_d_asseemp = e45_1_1_1_cv
clonevar nper_d_iamcemp = e45_2_1_1_cv
clonevar nper_d_privemp = e45_3_1_1_cv
clonevar nper_d_mili    = e45_4_1_1_cv
clonevar nper_d_emeremp = e47_1_cv

* para definir la rama militar en ocupación ppal o secundaria
local ciiu_militar "5222, 5223, 8030, 8411, 8421, 8422, 8423, 8430, 8521, 8530, 8610"

* derecho fonasa
gen ss_fonasa   = inlist(ss_asse_o, 1, 4, 5, 6) | /// 
			  	  inlist(ss_iamc_o, 1, 6, 3, 5) | /// 
			  	  inlist(ss_priv_o, 1, 6, 3, 5)   // 
gen ss_fonasaV2 = inlist(ss_asse_o, 1, 4) | ///
				  inlist(ss_iamc_o, 1, 6) | ///
				  inlist(ss_priv_o, 1, 6)
* derecho fonasa por un miembro del hogar
gen ss_fonasa_o_h = ss_asse_o==1| ss_iamc_o==1 | ss_priv_o==1


//  variables generales

gen esjefe = ine_ysvl>0

//  indicadores laborales

* trabajo dependiente
gen dependiente_op = inlist(f73, 1, 2, 7, 8)
gen dependiente_os = inlist(f92, 1, 2, 7)    // excluye part. en prog. empleo social

* trabajo independiente (coop, patrón, cprop)
gen independiente_op = inrange(f73, 3, 6)   
gen independiente_os = inrange(f92, 3, 6)   

* formalidad
gen formal_op = f82==1
gen formal_os = f96==1

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

*-------------------------------------------------------------------------------
* CUOTA MILITAR GENERADA POR MIEMBRO DEL HOGAR


* Se calcula cuotas militares, adjudicadas a militar que las genera.
* Se toma a quienes tienen derecho en sanidad militar a través de un miembro de este hogar y a su vez no generan derecho por FONASA ya sea por miembro del hogar o por otro hogar.


gen at_milit  = ss_mili_o_h & !ss_fonasa
gen at_milit2 = ss_mili & !ss_fonasa

sort bc_correlat bc_nper

*Se toma a todos quienes tienen derecho a atención militar y no tienen FONASA ya sea por miembro del hogar o por otro hogar . 

egen n_milit = sum(ss_mili_o_h & !ss_fonasa) if nper_d_mili>0, by(bc_correlat nper_d_mili)
* ocupada en rama militar en la ocupación principal
gen  ramamilit_op = inlist(ciiu_op, `ciiu_militar')
gen    n_milit_op = n_milit if ramamilit_op & nper_d_mili==bc_nper
recode n_milit_op (. = 0)
* valorizo con el monto de la cuota
gen    ytdop_2      = n_milit_op * mto_cuot

*Cuota militar ocupación secundaria.

gen    ramamilit_os  = inlist(ciiu_os, `ciiu_militar')
gen    n_milit_os  = n_milit if ramamilit_os & nper_d_mili==bc_nper & n_milit_op==0
recode n_milit_os (. = 0)
gen    ytdos_2       = n_milit_os * mto_cuot

*Se suman todas las cuotas de op, os y las totales sin derecho a FONASA a la vez. 
egen n_milit_hog    = sum(ss_mili & !ss_fonasa), by(bc_correlat)
egen n_milit_op_hog = sum(n_milit_op)          , by(bc_correlat)
egen n_milit_os_hog = sum(n_milit_os)          , by(bc_correlat)

gen     n_militotr     = n_milit_hog - (n_milit_op_hog + n_milit_os_hog)
gen     yt_ss_militotr = n_militotr * mto_cuot
* asigna las cuotas al jefx
replace yt_ss_militotr = 0 if !esjefe

*-------------------------------------------------------------------------------
*- Sintaxis FONASA

*FONASA trabajador ocupación principal.
gen ytdop_3 = mto_cuot if dependiente_op & formal_op & ss_fonasa_o_h 
recode ytdop_3 (. = 0)

*FONASA trabajador ocupación secundaria.
gen ytdos_3 = mto_cuot if dependiente_os & formal_os & ss_fonasa_o_h ///
						& ytdop_2==0 & ytdop_3==0 // Por qué no se incluye ytdos_2??? / sofi santin
recode ytdos_3 (. = 0)

*FONASA Trabajador independiente.
gen YTINDE_2 = mto_cuot if ((independiente_op & formal_op) | (independiente_os & formal_os)) & ss_fonasa_o_h ///
						& ytdop_3==0 & ytdos_3==0 & ytdop_2==0 & ytdos_2==0
recode YTINDE_2 (. = 0)

*FONASA. Para todos quienes generan derecho por FONASA y no son adjudicables al trabajo.
gen ss_fonasa_nolab = ss_fonasaV2 & ytdop_3 ==0 & ytdos_3 ==0 & YTINDE_2 ==0
	
*SOLO FONASAS ADJUDICABLES AL HOGAR.
egen    n_fonasa_nolab = sum(ss_fonasa_nolab), by(bc_correlat)
replace n_fonasa_nolab = 0 if !esjefe
gen yt_ss_fonasa_nolab = n_fonasa_nolab * mto_cuot

// Salario en especie: cuotas mutuales y emergencia pagas por empleador

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

* cuota de emergencia movil paga por empleador usa otro monto
replace yt_ss_emeremp = (yt_ss_emeremp / mto_cuot) * mto_emer

* ingreso por transferencias a mutualistas o seguro privado
gen yt_ss_emp = yt_ss_privemp + yt_ss_iamcemp

*EMERGENCIA MOVIL PAGA POR OTRO HOGAR

// Derechos de salud para este hogar provenientes de otros hogares

* emeregencia móvil
egen    n_emerotr    = sum(ss_emerotr), by(bc_correlat)
replace n_emerotr    = 0 if !esjefe
gen    yt_ss_emerotr = n_emerotr * mto_emer


* Cuotas para este hogar generadas desde otro hogar 
egen    n_otrohog     = sum(ss_otrohog), by(bc_correlat)
replace n_otrohog     = 0 if !esjefe
gen     yt_ss_otrohog = n_otrohog * mto_cuot 



//  #3
//  Ingreso de trabajo

* Ingresos por trabajo como dependiente - Ocupación Principal

gen g127_1_y = g127_1 * mto_desa
gen g127_2_y = g127_2 * mto_almu
gen g132_1_y = g132_1 * mto_vaca
gen g132_2_y = g132_2 * mto_ovej
gen g132_3_y = g132_3 * mto_caba
gen g133_2_y = g133_2 / 12

local ytdop_1_dinero   "g126_1   g126_2    g126_3    g126_4 g126_5 g126_6 g126_7 g126_8"
local ytdop_1_aliment  "g127_1_y g127_2_y  g127_3"
local ytdop_1_especie  "g128_1   g129_2    g130_1    g131_1"
local ytdop_1_pastoreo "g132_1_y g132_2_y  g132_3_y"
local ytdop_1_autocult "g133_1   g133_2_y"

* Ingresos por trabajo como dependiente - Ocupación Principal

egen ytdop_1 = rowtotal(`ytdop_1_dinero' `ytdop_1_aliment' `ytdop_1_especie' ///
						`ytdop_1_pastoreo' `ytdop_1_autocult')

egen YTDOP =  rowtotal(ytdop_1 ytdop_2 ytdop_3 yt_ss_emp yt_ss_emeremp yt_ss_asseemp)

* Ingresos por trabajo como dependiente - Ocupación Secundaria

gen g135_1_y = g135_1 * mto_desa
gen g135_2_y = g135_2 * mto_almu
gen g140_1_y = g140_1 * mto_vaca
gen g140_2_y = g140_2 * mto_ovej
gen g140_3_y = g140_3 * mto_caba
gen g141_2_y = g141_2 / 12

local ytdos_1_dinero   "g134_1   g134_2    g134_3    g134_4 g134_5 g134_6 g134_7 g134_8"
local ytdos_1_aliment  "g135_1_y g135_2_y  g135_3"
local ytdos_1_especie  "g136_1   g137_2    g138_1    g139_1"
local ytdos_1_pastoreo "g140_1_y g140_2_y  g140_3_y"
local ytdos_1_autocult "g141_1   g141_2_y"

egen ytdos_1 = rowtotal(`ytdos_1_dinero' `ytdos_1_aliment' `ytdos_1_especie' ///
						`ytdos_1_pastoreo' `ytdos_1_autocult')

egen YTDOS = rowtotal(ytdos_1 ytdos_2 ytdos_3)

* Ingresos por trabajo independiente

foreach varn in g143 g145 g146 g147 {
	gen `varn'_y = `varn'/12
}

local ytinde_1_utilidades  "g142   g143_y" // utilidades o retiro de $
local ytinde_1_autoconsumo "g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5"
local ytinde_1_negocioagro "g145_y g146_y   g147_y"

egen YTINDE_1 = rowtotal(`ytinde_1_utilidades' `ytinde_1_autoconsumo' `ytinde_1_negocioagro')

egen YTINDE   = rowtotal(YTINDE_1 YTINDE_2)



//  #4
//  transferencias

// Tansferencias jubilaciones y pensiones.

#del ;
local ytransf_jyp "g148_1_1 g148_1_2  g148_1_3  g148_1_4  g148_1_5  g148_1_6
	g148_1_7      g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1
	g148_2_2      g148_2_3  g148_2_4  g148_2_5  g148_2_6  g148_2_7  g148_2_8
	g148_2_9      g148_2_12 g148_2_10 g148_2_11 g148_3    g148_4    g148_5_1
	g148_5_2      g153_1    g153_2";
#del cr

egen YTRANSF_1 = rowtotal(`ytransf_jyp')

// Políticas sociales: transferencias monetarias

// Asignaciones Familiares (no incluídas en el sueldo)

gen    YTRANSF_2 = g257 if g256!=1
recode YTRANSF_2 (. = 0)

// Hogar Constituido

gen    YTRANSF_3 = mto_hogc if (g149==1 & g149_1==2)
recode YTRANSF_3 (. = 0)

// Políticas sociales, ingresos por alimentación

// Transferencias en especie: Alimentos

* recodifico 99s a missing
local desaymer "e559_1 e196_1 e196_3 e200_1 e200_3 e211_1 e211_3"
local almycen  "e559_2 e196_2 e200_2 e211_2"
recode `desaymer' `almycen' (99 = .q)

* numero de desayunos/meriendas y número de almuerzos/cenas
foreach varl in desaymer almycen {
	egen n_`varl' = rowtotal(``varl'')
}

gen DESAYMER = n_desaymer * 4.3 * mto_desa

gen ALMYCEN  = n_almycen  * 4.3 * mto_almu

gen     CANASTA = e247*indaceli if e246==7
replace CANASTA = e247*indaemer if e246==14
recode  CANASTA (. = 0)

* Tarjetas TUS -MIDES y TUS- INDA

gen  tusmides  = e560_1_1
gen  tusinda   = e560_2_1
egen tus       = rowtotal(tusmides tusinda)
gen     leche  = e561_1 * lecheenpol 
replace leche  = 0 if inlist(e246, 1, 7) & e560==2 // Ver sintaxis 2018 (por qué hacemos replace?)

* Se genera una variable de alimentos separando entre mayores y menores de 14

egen yalim_tot     = rowtotal(DESAYMER ALMYCEN tus CANASTA leche)
gen  YALIMENT      = yalim_tot if bc_pe3>=14
gen  YALIMENT_MEN1 = yalim_tot if bc_pe3< 14
recode YALIMENT YALIMENT_MEN1 (. = 0)

gen YTRANSF_4 = YALIMENT

egen    YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
replace YALIMENT_MEN = 0 if !esjefe

// total de transferencias 
* 	–– asumo que para mayores de 14 dado el tratamiento de YTRANSF_4 / gsl 2021-08-31

egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)



//  #5
//  Ingresos PT (personal total)

* otros ingresos 
gen OTROSY = (g258_1/12) + g154_1 // devolución de fonasa + otros ingresos

// PT1 – ingresos personales

egen     pt1_iecon = rowtotal(YTDOP YTDOS YTINDE YTRANSF OTROSY)
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
local yhog_anual "h160_1 h160_2 h163_1 h163_2 h164 h165 h166
	h269_1 h167_1_1 h167_1_2 h167_2_1 h167_2_2 h167_3_1 h167_3_2
	h167_4_1 h167_4_2 h170_1 h170_2   h271_1   h171_1   h172_1";
#del cr

egen yhog_anual = rowtotal(`yhog_anual')
	// excluye h173_1 – seguramente por ser ingreso extraordinario

gen yhog1 = h155_1 + h156_1 + h252_1 + (yhog_anual/12) + ///
	yt_ss_militotr + YALIMENT_MEN + yt_ss_fonasa_nolab + yt_ss_emerotr + yt_ss_otrohog

egen yhog_iecon = max(yhog1), by(bc_correlat)
drop yhog_anual yhog1

egen ht11_iecon = rowtotal(HPT1 ine_ht13 yhog_iecon)



*Hasta aquí se replican resultados de INE
*-------------------------------------------------------------------------------

* ASIGNACIONES
* Sintaxis del Mides

// AFAM-PE

/* 
	Identifcamos a los perceptores de AFAM-PE en tanto:
	- Cobra asignación por separado del sueldo en local de cobranza todos los meses 
	- Cobra AFAM y es inactivo (exc. jub y pen), desempleados sin seguro, menores 
	  de 14 añós -- o trabajadores informales
	- Declara recibir AFAM-PE
*/

gen afam_pe = (g256==2 & g152==1) ///
	| (g150==1 & (inlist(pobpcoac, 1, 3, 4, 6, 7, 8, 11) | (pobpcoac==2 & !formal_op & !formal_os))) ///
	| (g255==1)

gen afam_cont      = g150==1 & afam_pe==0
gen afam_cont_pub  = afam_cont==1 &  (deppub_op | deppub_os)
gen afam_cont_priv = afam_cont==1 & !(deppub_op | deppub_os)
gen afam_total     = afam_pe==1 | afam_cont==1

*** BENEFICIARIOS ***
egen cant_af = rowtotal(g151_6 g151_3 g151_4)

*** HOGARES ***
foreach varn in afam_pe afam_cont afam_cont_pub afam_cont_priv afam_total {
	egen `varn'_hog = max(`varn'), by(bc_correlat)
}

*** MONTO AFAM-PE (con pregunta de complemento) ***
gen     mto_afampe      = 1496.1 if bc_mes==1
replace mto_afampe      = 1615.2 if bc_mes>1
gen     mto_afampe_comp = 641.2  if bc_mes==1
replace mto_afampe_comp = 692.3  if bc_mes>1

egen hh_n_men18       = rowtotal(g151_6 g151_3)
egen hh_n_men18_liceo = rowtotal(g151_3)
egen hh_n_disca       = rowtotal(g151_4)

gen monto_afam_pe = mto_afampe                     * (hh_n_men18^0.6)       ///
				  + mto_afampe_comp                * (hh_n_men18_liceo^0.6) ///
				  + (mto_afampe + mto_afampe_comp) *  hh_n_disca            ///
				  if afam_pe==1
recode monto_afam_pe (. = 0)


// AFAM_CON - Código Iecon

gen nucleo = bc_nper
*replace nucleo = min(bc_nper,e34) if e34!=0 / no está el modulo de pareja en ECH 2020 \ gsl 2021-09-30
* suma de ingresos trabajadores formales por concepto de sueldo, comisiones, o viáticos
* ocupacion ppal
gen  suma1 = (g126_1 + g126_2 + g126_3) * 1.22 if asal_op & formal_op 
* ocupación secundaria
gen  suma2 = (g134_1 + g134_2 + g134_3) * 1.22 if asal_os & formal_os 
* trabajo independiente
gen  suma3 = (g142 + g143/12)  if (independiente_op & formal_op) | (independiente_os & formal_os)
* suma de ingresos de jubilados y pensionistas
egen suma4 = rowtotal(g148_1_1  g148_1_2  g148_1_3  g148_1_4 g148_1_5  g148_1_6  g148_1_7  g148_1_8 ///
	        g148_1_9  g148_1_10 g148_1_11 g148_1_12 g148_2_1 g148_2_2  g148_2_3  g148_2_4 ///
	        g148_2_5  g148_2_6  g148_2_7  g148_2_8  g148_2_9 g148_2_10 g148_2_11 g148_2_12)

egen suma = rowtotal(suma1 suma2 suma3 suma4)
drop suma1 suma2 suma3 suma4
egen ing_nucleo = sum(suma)  , by(bc_correlat nucleo)

gen corte_afam_contrib = 6*bpc

gen     monto_asig = 0.16*bpc if ing_nucleo<=corte_afam_contrib & afam_cont==1
replace monto_asig = 0.08*bpc if ing_nucleo> corte_afam_contrib & afam_cont==1
recode  monto_asig   (. = 0)

gen monto_afam_cont = monto_asig*cant_af

// TUS

* No hay forma de asignar TUS, por lo que se utiliza el monto declarado.
egen    monto_tus_iecon = sum(tus), by(bc_correlat)
replace monto_tus_iecon = 0 if !esjefe


// Vector salud. Código Iecon

* cuotas mutuales por fonasa ($)
egen fonasa = rowtotal(ytdop_3 ytdos_3 YTINDE_2)
* fonasa + cuotas militares
egen salud  = rowtotal(fonasa ytdos_2 ytdop_2)

egen    saludh = sum(salud), by(bc_correlat)
replace saludh = saludh + yt_ss_fonasa_nolab + yt_ss_militotr

// ----------------------------------------------
// rename

clonevar cuotmilit_hogar   = yt_ss_militotr     
clonevar totfonasa_hogar2  = yt_ss_fonasa_nolab 
clonevar CUOT_EMP_IAMC_TOT = yt_ss_iamcemp      
clonevar CUOT_EMP_PRIV_TOT = yt_ss_privemp      
clonevar CUOT_EMP_TOT      = yt_ss_emp          
clonevar CUOT_EMP_ASSE_TOT = yt_ss_asseemp      
clonevar EMER_EMP_TOT      = yt_ss_emeremp      
clonevar EMER_OTRO_TOT     = yt_ss_emerotr      
clonevar CUOT_OTROHOG2     = yt_ss_otrohog      
* variable aparece dos veces con distintos nombres
clonevar cuota_otrohog_h   = yt_ss_otrohog

// ----------------------------------------------


// ----------------------------------------------
// save

quietly compress		
notes: ech-2020-03.dta \ ingreso ht11 iecon \ `tag'
label data "ECH 2020 [tmp 3] \ `date'"
datasignature set, reset
save  "data/tmp/ech-2020-03.dta", replace

// ----------------------------------------------


log close
exit
