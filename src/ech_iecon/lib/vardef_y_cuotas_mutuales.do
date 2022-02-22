// vardef_y_cuotas_mutuales.do
// monetizamos transferencias por cuotas mutuales

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
gen ss_fonasa_nolab = ss_fonasa & ytdop_3 ==0 & ytdos_3 ==0 & YTINDE_2 ==0
	
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
