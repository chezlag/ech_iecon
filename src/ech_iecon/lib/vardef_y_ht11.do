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

	Por último se realizan imputaciones de varias transferencias: AFAM-PE con 
	la sintaxis del MIDES, AFAM contributivas, TUS y vector salud con código
	de IECON.

*/

//  #1 -------------------------------------------------------------------------
//  Salario en especie: Cuotas mutuales ----------------------------------------
* 	–– !! muchas variables usadas en esta sub-sección se definen en lib/vardef_salud.do

//  Cuotas militares -------------------------------------------------

* Se calcula cuotas militares, adjudicadas a militar que las genera.
* 	Se toma a quienes tienen derecho en sanidad militar a través de un miembro 
*	de este hogar y a su vez no generan derecho por FONASA, ya sea por miembro 
*	del hogar o por otro hogar.

* para definir la rama militar en ocupación ppal o secundaria
* CIIU rev 3
loc ciiu3_militar "7510, 7511, 7512, 7513, 7514, 7515, 7516, 7517, 7518, 7519"
loc ciiu3_militar "7520, 7521, 7522, 7523, 7524, 7525, 7526, 7527, 7528, 7529, `ciiu3_militar'"
loc ciiu3_militar "7530, 7531, 7532, 7533, 7534, 7535, 7536, 7537, 7538, 7539, `ciiu3_militar'"
loc ciiu3_militar "8020, 8021, 8022, 8023, 8024, 8025, 8026, 8027, 8028, 8029, `ciiu3_militar'"
loc ciiu3_militar "8030, 8031, 8032, 8033, 8034, 8035, 8036, 8037, 8038, 8039, `ciiu3_militar'"
loc ciiu3_militar "8511, `ciiu3_militar'"
* CIIU rev 4
loc ciiu4_militar "5222, 5223, 8030, 8411, 8421, 8422, 8423, 8430, 8521, 8530, 8610"

* atención militar
gen at_milit  = ss_mili_o_h & !ss_sinpago
gen at_milit2 = ss_mili & !ss_sinpago

sort bc_correlat bc_nper

* numero de personas con acceso a salud militar en el hogar, por persona que genera el derecho
egen n_milit = sum(ss_mili_o_h & !ss_sinpago) if nper_d_mili>0, by(bc_correlat nper_d_mili)

// cuota militar por ocupación principal

* ocupada en rama militar en la ocupación principal
gen  ramamilit_op = inlist(ciiu_op, `ciiu`ciiurev'_militar')
gen    n_milit_op = n_milit if ramamilit_op & nper_d_mili==bc_nper
recode n_milit_op (. = 0)
* valorizo con el monto de la cuota
gen    ytdop_2      = n_milit_op * mto_cuot

// Cuota militar ocupación secundaria.

gen    ramamilit_os  = inlist(ciiu_os, `ciiu`ciiurev'_militar')
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

// ingresos por trabajo dependiente – op ------------------

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdop_1 = rowtotal(yl_rem_mon_op yl_rem_esp_op yl_rem_atrasado_op)

* ingresos TOTALES por trabajo dependiente en op –– sumo cuotas mutuales 
egen YTDOP =  rowtotal(ytdop_1 ytdop_2 ytdop_3 yt_ss_emp yt_ss_emeremp yt_ss_asseemp)

// ingresos por trabajo dependiente – os -------------------

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdos_1 = rowtotal(yl_rem_mon_os yl_rem_esp_os yl_rem_atrasado_os)

* ingresos TOTALES por trabajo dependiente en os –– sumo cuotas mutuales 
egen YTDOS = rowtotal(ytdos_1 ytdos_2 ytdos_3)

// ingresos por trabajo independiente ----------------------

gen YTINDE_1 = yl_mix_mon + yl_mix_esp + yk_util_per/12

* ingresos TOTALES por trabajo independiente –– sumo cuotas mutuales
egen YTINDE   = rowtotal(YTINDE_1 YTINDE_2)


//  #3 -------------------------------------------------------------------------
//  Ingresos por transferencias ------------------------------------------------

//  Jubilaciones y pensiones -----------------------------------------

egen YTRANSF_1 = rowtotal(`ytransf_jyp')

//  Políticas sociales: transferencias monetarias --------------------

// Asignaciones Familiares (no incluídas en el sueldo)

/* 
	Asi lo hace el INE, pero nosotros imputamos los ingresos por transferencias
	en base a lo declarado de ingresos (ver más abajo). 

	El monto cobrado se empezó a preguntar recién en 2013. 
*/

* señalizo afam cobradas por fuera del sueldo
gen afam_nosueldo = `afam_nosueldo'

* agergo afam cobradas por fuera del sueldo
gen    YTRANSF_2 = `mto_afam_declarado' * (afam_nosueldo==1)
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

cap replace CANASTA = `canasta_pre2012'

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

/* 
	Se define más abajo nuevamente con las correcciones del IECON.
	Creo que habría que borrar toda esta sección para no confundir / gsl 2022-02-23
*/

egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)

//  #4 -------------------------------------------------------------------------
//  Ingreso personal total e ingresos del hogar –– replicación INE -------------

* otros ingresos 
gen OTROSY = (`devolucion_fonasa'/12) + g154_1 // devolución de fonasa + otros ingresos

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
loc  yhog_anual "y_pg121_ano y_pg122_ano y_pg131 y_pg132 yk_util_hog yk_otro_hog h171_1 h172_1"
egen yhog_anual = rowtotal(`yhog_anual')
	// excluye h173_1 – seguramente por ser ingreso extraordinario

gen yhog1 = h155_1 + h156_1 + h252_1 + (yhog_anual/12) + ///
	yt_ss_militotr + YALIMENT_MEN + yt_ss_fonasa_nolab + yt_ss_emerotr + yt_ss_otrohog

egen yhog_iecon = max(yhog1), by(bc_correlat)
drop yhog_anual yhog1

egen ht11_iecon = rowtotal(HPT1 ine_ht13 yhog_iecon)


//  #5 -------------------------------------------------------------------------
// Ingresos adicionales definidos por IECON ------------------------------------

// AFAM-PE –– Sintaxis MIDES

/* 
	Identifcamos a los perceptores de AFAM-PE en tanto:
	- Cobra asignación por separado del sueldo en local de cobranza todos los meses 
	- Cobra AFAM y es inactivo (exc. jub y pen), desempleados sin seguro, menores 
	  de 14 añós -- o trabajadores informales
	- Declara recibir AFAM-PE
*/

gen afam_pe = `afampe_cond1' | `afampe_cond2' | `afampe_cond3'

gen afam_cont      = `afamcont_cond'
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

gen monto_afam_pe = bc_afampe_base                    * (hh_n_afam_men18^0.6)      ///
				  + bc_afampe_comp                    * (hh_n_afam_comp_liceo^0.6) ///
				  + (bc_afampe_base + bc_afampe_comp) *  hh_n_afam_disca           ///
				  if afam_pe==1
recode monto_afam_pe (. = 0)

// AFAM CONTRIBUTIVA –– Sintaxis Iecon

* identificamos núcleo y sus ingresos
gen nucleo = bc_nper
cap replace nucleo = min(bc_nper,e34) if e34!=0 // no está el modulo de pareja en ECH 2020 \ gsl 2021-09-30

* suma de ingresos trabajadores formales por concepto de sueldo, comisiones, o viáticos
* ocupacion ppal
gen  suma1 = (g126_1 + g126_2 + g126_3) * 1.22 if asal_op & formal_op 
* ocupación secundaria
gen  suma2 = (g134_1 + g134_2 + g134_3) * 1.22 if asal_os & formal_os 
* trabajo independiente
gen  suma3 = (g142 + g143/12)  if (independiente_op & formal_op) | (independiente_os & formal_os)
* suma de ingresos de jubilados y pensionistas
egen suma4 = rowtotal(`ytransf_jubpen')

* suma de los ingresos del núcleo
egen suma = rowtotal(`ing_nucleo_afamcont')
drop suma1 suma2 suma3 suma4
egen ing_nucleo = sum(suma)  , by(bc_correlat nucleo)

* punto de corte para el cobro de afam contributivas
gen corte_afam_contrib = 6*bc_bpc

* imputamos asignación si el ingreso del núcleo es menor a 6 bpc
gen     monto_asig = 0.16*bc_bpc if ing_nucleo<=corte_afam_contrib & afam_cont==1
replace monto_asig = 0.08*bc_bpc if ing_nucleo> corte_afam_contrib & afam_cont==1
recode  monto_asig   (. = 0)

gen monto_afam_cont = monto_asig*cant_af

// TUS

* No hay forma de asignar TUS, por lo que se utiliza el monto declarado.
cap gen  monto_tus_iecon = h157_1 // para los años que se relevaba a nivel de hogar
cap egen monto_tus_iecon = sum(tus), by(bc_correlat)
replace  monto_tus_iecon = 0 if !esjefe

// Vector salud –– Código Iecon

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

//  #6
//  Correcciones a transferencias

* sacamos becas, subsidios y donaciones –– pasa a canasta "otras"	
egen ytransf_1_iecon = rowtotal(`ytransf_jubpen' `ytransf_otrpen')

replace YTRANSF_1 = ytransf_1_iecon if e246==11
drop ytransf_1_iecon

// Asignaciones familiares

/* 
	Queremos evitar sumar las transferencias dos veces.

	Se incluyen las asignaciones contributivas solo si son cobradas por fuera del sueldo
	Todas las AFAM-PE son cobradas por fuera del sueldo, asi que se suman todas.
*/

* sumo afam contributivas cobradas fuera del sueldo y afam-pe
replace YTRANSF_2 = monto_afam_cont * (afam_nosueldo==1) + monto_afam_pe

// Políticas sociales: ingresos por alimentación

* único cambio real respecto al anterior
replace CANASTA = g148_5_1+g148_5_2 if e246==11 // Otras canastas, cambió en ECH 2018

*Se genera una variable de alimentos para todos sin importar si son mayores de 14 años o no
*	saca TUS de YALIMENT
egen    yalim_totV2   = rowtotal(DESAYMER ALMYCEN CANASTA ticketsinda leche)  //Monto tus del iecon va para bc_tarjeta
replace YALIMENT      = yalim_totV2 if bc_pe3>=14
replace YALIMENT_MEN1 = yalim_totV2 if bc_pe3< 14
recode  YALIMENT YALIMENT_MEN1 (. = 0)

* transferencia de alimentos para menores de 14
drop    YALIMENT_MEN
egen    YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
replace YALIMENT_MEN = 0 if !esjefe

* transferencias de alimentos para mayores de 14
replace YTRANSF_4 = YALIMENT

// Nuevo ingreso total de transferencias
	
drop YTRANSF
egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)
