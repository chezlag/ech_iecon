/*
	ech_2015_specs.do
	Parámetros específicos de la ECH 2015.
*/

//  #1 -------------------------------------------------------------------------
//  correcciones de datos ------------------------------------------------------

* ¿cómo identificamos al jefx de hogar?
gen esjefe = e30==1


//  #2 -------------------------------------------------------------------------
//  demografía -----------------------------------------------------------------

/* si falta algún módulo (pe4/pe5) sustituir el local por "0" */

* relación de parentezco
loc pe4_jefe        "e30==1"
loc pe4_conyuge     "e30==2"
loc pe4_hije        "e30==3 | e30==4 | e30==5"
loc pe4_padresuegro "e30==7 | e30==8"
loc pe4_otroparient "e30==6 | e30==9 | e30==10 | e30==11 | e30==12"
loc pe4_nopariente  "e30==13"
loc pe4_servdom     "(e30==14)"
* estado civil
loc pe5_unionlibre  "(e35==2 | e35==3)"
loc pe5_casado      "(e35==4 | e35==5)"
loc pe5_divsep      "(e35==0 & (e36==1 | e36==2 | e36==3))"
loc pe5_viudo       "(e35==0 & (e36==4 | e36==6))"
loc pe5_soltero     "(e35==0 & (e36==5))"

//  #3 -------------------------------------------------------------------------
//  salud y trabajo ------------------------------------------------------------

* van juntos porque se utilizan mutuamente para crear variables

// salud -------------------------------------------------------------

* derecho de atención en cada servicio
loc ss_asse "e45_1==1"
loc ss_iamc "e45_2==1"
loc ss_priv "e45_3==1"
loc ss_mili "e45_4==1"
loc ss_bps  "e45_5==1"
loc ss_muni "e45_6==1"
loc ss_otro "e45_7==1"
loc ss_emer "e46==1"
/* * V2: solo para quienes se repregunta
loc ss_asseV2 "inrange(e45_1_1, 1, 6)"
loc ss_iamcV2 "inrange(e45_2_1, 1, 6)"
loc ss_privV2 "inrange(e45_3_1, 1, 6)"
loc ss_miliV2 "inrange(e45_4_1, 1, 2)" */

* origen del derecho de atención
loc ss_asse_o "e45_1_1"
loc ss_iamc_o "e45_2_1"
loc ss_priv_o "e45_3_1"
loc ss_mili_o "e45_4_1"
loc ss_emer_o "e47"

* nper de personas que generan derechos de salud a otros integrantes del hogar
loc nper_d_asseemp "e45_1_1_1"
loc nper_d_iamcemp "e45_2_1_1"
loc nper_d_privemp "e45_3_1_1"
loc nper_d_mili    "e45_4_2"
loc nper_d_emeremp "e47_1"

//  trabajo ----------------------------------------------------------

* condición de actividad
clonevar bc_pobp = pobpcoac
recode   bc_pobp (10=9)

* formalidad
loc formal_op "f82==1" 
loc formal_os "f96==1" 

* trabajo dependiente
loc dependiente_op "inlist(f73, 1, 2, 7, 8)"
loc dependiente_os "inlist(f92, 1, 2, 7)"    // excluye part. en prog. empleo social

* trabajo independiente (coop, patrón, cprop)
loc independiente_op "inrange(f73, 3, 6)"
loc independiente_os "inrange(f92, 3, 6)"

* ciiu ocupacion principal y ocupacion secundaria
loc ciiu_op "f72_2"
loc ciiu_os "f91_2"

* aslariados en ocupación principal o secundaria
loc asal_op "inlist(f73, 1, 2, 8)"
loc asal_os "inlist(f92, 1, 2)"

* dependiente público o privado en ocupación principal
loc deppri_op "f73==1"
loc deppri_os "f92==1"
loc deppub_op "inlist(f73, 2, 8)"
loc deppub_os "f92==2"

//  #4 -------------------------------------------------------------------------
//  educación ------------------------------------------------------------------

//  #5 -------------------------------------------------------------------------
//  reconstrucción de ingresos -------------------------------------------------

// transferencias

* jubilaciones y pensiones
#del ;
local ytransf_jyp "g148_1_1 g148_1_2  g148_1_3  g148_1_4  g148_1_5  g148_1_6
	g148_1_7      g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1
	g148_2_2      g148_2_3  g148_2_4  g148_2_5  g148_2_6  g148_2_7  g148_2_8
	g148_2_9      g148_2_12 g148_2_10 g148_2_11 g148_3    g148_4    g148_5_1
	g148_5_2      g153_1    g153_2";
#del cr

* numero de desayunos/meriendas y almuerzos/cenas
local desaymer "e559_1 e196_1 e196_3 e200_1 e200_3 e211_1 e211_3"
local almycen  "e559_2 e196_2 e200_2 e211_2"

* transferencias por tus-mides y tus-inda – en $
loc y_tusmides "e560_1_1"
loc y_tusinda  "e560_2_1"

* otras transferencias de alimentación – en $
loc y_ticketsinda  "0"
loc y_lecheenpolvo "e561_1 * lecheenpol"

// AFAM

* numero de beneficiarios de afam por tipo
loc hh_n_afam_men18       "g151_1 g151_2 g151_3"
loc hh_n_afam_comp_liceo  "g151_3_1"
loc hh_n_afam_disca       "g151_4"

//  #6 -------------------------------------------------------------------------
//  descomposición por fuentes -------------------------------------------------

// Ingresos de capital – anuales

* ingreso por alquileres (del país/del extranjero)
loc y_pg121     "h160_1 h163_1 h252_1 h269_1"
loc y_pg122     "h160_2 h163_2"
* ingreso por intereses (del pais/del extranjero)
loc y_pg131     "h167_1_1 h167_2_1 h167_3_1 h167_4_1"
loc y_pg132     "h167_1_2 h167_2_2 h167_3_2 h167_4_2"
* utilidades
loc y_util_per  "g143"
loc y_util_hog  "h170_1 h170_2 h271_1"
* otras fuentes de capital
loc y_otrok_hog "h164 h165 h166"

//  #7 -------------------------------------------------------------------------
//  Últimos retoques -----------------------------------------------------------

* variables que ya no están disponibles este año
loc bc_yalimpan "0"
loc bc_cuotabps "-13"
loc bc_disse_p  "-13"
loc bc_disse_o  "-13"
loc bc_disse    "-13"
loc bc_pf051    "-13"
loc bc_pf052    "-13"
loc bc_pf053    "-13"
loc bc_pf06     "-13"
