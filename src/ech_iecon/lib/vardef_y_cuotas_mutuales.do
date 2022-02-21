// vardef_y_cuotas_mutuales.do
// monetizamos transferencias por cuotas mutuales

//  #1 -------------------------------------------------------------------------
//  Variables auxiliares de atención de salud ----------------------------------

* derecho de atención origina en un pago de alguien dentro del hogar
gen ss_asse_o_hpago = inlist(ss_asse_o, 2, 3)
gen ss_iamc_o_hpago = ss_iamc_o==2
gen ss_priv_o_hpago = ss_priv_o==2

* derecho de atención militar originado por alguien del hogar
gen     ss_mili_o_h = ss_mili_o==1

* cuota IAMC paga por empleador 
*	excluyendo personas sin derecho a atenderse en ASSE o seguro privado
*	o quienes acceden a través de un pago (o bajos recursos en ASSE)
gen ss_iamcemp =  ss_iamc_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)
gen ss_asseemp =  ss_asse_o==5 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)
gen ss_privemp =  ss_priv_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago)
gen ss_emeremp = e47_cv==4

* cuotas para este hogar generadas desde otro hogar 
gen ss_otrohog = (ss_asse_o==6 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_iamc_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_priv_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago))
* emergencia móvil paga de otro hogar
gen ss_emerotr = e47_cv==3

* para definir la rama militar en ocupación ppal o secundaria
local ciiu_militar "5222, 5223, 8030, 8411, 8421, 8422, 8423, 8430, 8521, 8530, 8610"

* derecho fonasa
gen ss_fonasa   = inlist(ss_asse_o, 1, 4, 5, 6) | /// 
			  	  inlist(ss_iamc_o, 1, 6, 3, 5) | /// 
			  	  inlist(ss_priv_o, 1, 6, 3, 5)   // 

gen ss_fonasaV2 = inlist(ss_asse_o, 1, 4) | ///
				  inlist(ss_iamc_o, 1, 6) | ///
				  inlist(ss_priv_o, 1, 6)


//  #2 -------------------------------------------------------------------------
//  Cuotas militares -----------------------------------------------------------

* Se calcula cuotas militares, adjudicadas a militar que las genera.
* 	Se toma a quienes tienen derecho en sanidad militar a través de un miembro 
*	de este hogar y a su vez no generan derecho por FONASA, ya sea por miembro 
*	del hogar o por otro hogar.

gen at_milit  = ss_mili_o_h & !ss_fonasa
gen at_milit2 = ss_mili & !ss_fonasa

sort bc_correlat bc_nper

* numero de personas con acceso a salud militar en el hogar, por persona que genera el derecho
egen n_milit = sum(ss_mili_o_h & !ss_fonasa) if nper_d_mili>0, by(bc_correlat nper_d_mili)

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
egen n_milit_hog    = sum(ss_mili & !ss_fonasa), by(bc_correlat)

* a partir de la diferencia, se encuentra las cuotas militares provenientes de otro hogar
gen  n_militotr     = n_milit_hog - (n_milit_op_hog + n_milit_os_hog)
gen  yt_ss_militotr = n_militotr * mto_cuot
* asigna las cuotas al jefx
replace yt_ss_militotr = 0 if !esjefe


//  #3 -------------------------------------------------------------------------
//  cuotas fonasa --------------------------------------------------------------

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
gen ss_fonasa_nolab = ss_fonasaV2 & ytdop_3 ==0 & ytdos_3 ==0 & YTINDE_2 ==0
	
* sumo cuotas no laborales, monetizo, y se las imputo al jefe
egen    n_fonasa_nolab = sum(ss_fonasa_nolab), by(bc_correlat)
replace n_fonasa_nolab = 0 if !esjefe
gen yt_ss_fonasa_nolab = n_fonasa_nolab * mto_cuot


//  #4 -------------------------------------------------------------------------
//  Salario en especie: cuotas mutuales y emergencia pagas por empleador  ------

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
