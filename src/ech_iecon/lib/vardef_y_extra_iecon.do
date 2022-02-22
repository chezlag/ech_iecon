// vardef_y_extra_iecon.do
// Ingresos adicionales definidos por IECON


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
	| (g150==1 & (inlist(bc_pobp, 1, 3, 4, 6, 7, 8, 11) | (bc_pobp==2 & !formal_op & !formal_os))) ///
	| (g255==1)

gen afam_cont      = g150==1 & afam_pe==0
gen afam_cont_pub  = afam_cont==1 &  (deppub_op | deppub_os)
gen afam_cont_priv = afam_cont==1 & !(deppub_op | deppub_os)
gen afam_total     = afam_pe==1 | afam_cont==1

*** BENEFICIARIOS ***
egen cant_af = rowtotal(`hh_n_afam_men18' `hh_n_afam_disca')

*** HOGARES ***
foreach varn in afam_pe afam_cont afam_cont_pub afam_cont_priv afam_total {
	egen `varn'_hog = max(`varn'), by(bc_correlat)
}

*** MONTO AFAM-PE (con pregunta de complemento) ***
* –– mergea en ech_main.do

egen hh_n_afam_men18      = rowtotal(`hh_n_afam_men18')
egen hh_n_afam_comp_liceo = rowtotal(`hh_n_afam_comp_liceo')
egen hh_n_afam_disca      = rowtotal(`hh_n_afam_disca')

gen monto_afam_pe = bc_afampe_base                     * (hh_n_afam_men18^0.6)      ///
				  + bc_afampe_comp                * (hh_n_afam_comp_liceo^0.6) ///
				  + (bc_afampe_base + bc_afampe_comp) *  hh_n_afam_disca            ///
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

gen corte_afam_contrib = 6*bc_bpc

gen     monto_asig = 0.16*bc_bpc if ing_nucleo<=corte_afam_contrib & afam_cont==1
replace monto_asig = 0.08*bc_bpc if ing_nucleo> corte_afam_contrib & afam_cont==1
recode  monto_asig   (. = 0)

gen monto_afam_cont = monto_asig*cant_af

// TUS

* No hay forma de asignar TUS, por lo que se utiliza el monto declarado.
cap gen  monto_tus_iecon = h157_1 // para los años que se relevaba a nivel de hogar
cap egen monto_tus_iecon = sum(tus), by(bc_correlat)
replace  monto_tus_iecon = 0 if !esjefe


// Vector salud. Código Iecon

* cuotas mutuales por fonasa ($)
egen fonasa = rowtotal(ytdop_3 ytdos_3 YTINDE_2)
* fonasa + cuotas militares
egen salud  = rowtotal(fonasa ytdos_2 ytdop_2)

egen    saludh = sum(salud), by(bc_correlat)
replace saludh = saludh + yt_ss_fonasa_nolab + yt_ss_militotr

// ----------------------------------------------
// clono variables para que funcionen siguientes do-files

clonevar cuotmilit_hogar   = yt_ss_militotr     
clonevar totfonasa_hogar2  = yt_ss_fonasa_nolab 
clonevar CUOT_EMP_IAMC_TOT = yt_ss_iamcemp      
clonevar CUOT_EMP_PRIV_TOT = yt_ss_privemp      
clonevar CUOT_EMP_TOT      = yt_ss_emp          
clonevar CUOT_EMP_ASSE_TOT = yt_ss_asseemp      
clonevar EMER_EMP_TOT      = yt_ss_emeremp      
clonevar EMER_OTRO_TOT     = yt_ss_emerotr      
clonevar emerg_otrohog_h   = yt_ss_emerotr      
clonevar CUOT_OTROHOG2     = yt_ss_otrohog      
* variable aparece dos veces con distintos nombres
clonevar cuota_otrohog_h   = yt_ss_otrohog

// ----------------------------------------------
