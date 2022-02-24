/*
	ech_2013_specs.do
	Parámetros específicos de la ECH 2013.
*/

//  #1 -------------------------------------------------------------------------
//  correcciones de datos ------------------------------------------------------

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
loc pe5_casado      "(e35==1)"
loc pe5_divsep      "(e35==0 & (e36==1 | e36==2 | e36==3))"
loc pe5_viudo       "(e35==0 & (e36==4 | e36==6))"
loc pe5_soltero     "(e35==0 & (e36==5))"

* ¿cómo identificamos al jefx de hogar?
loc esjefe "e30==1"


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
cap drop bc_pobp
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

* revisión de la ciiu usada este año –– ver lib/local_ciiu_rama8.do
loc ciiurev "4"

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
loc ytransf_jubpen "g148_1_1  g148_1_2  g148_1_3  g148_1_4  g148_1_5  g148_1_6
	g148_1_7     g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1
	g148_2_2     g148_2_3  g148_2_4  g148_2_5  g148_2_6  g148_2_7  g148_2_8
	g148_2_9     g148_2_12 g148_2_10 g148_2_11";
loc ytransf_otrpen "g148_3 g148_4 g148_5_1 g148_5_2 g153_1 g153_2";
loc ytransf_jyp `ytransf_jubpen' `ytransf_otrpen';
#del cr

* numero de desayunos/meriendas y almuerzos/cenas
local desaymer "e57_4_1 e196_1 e196_3 e200_1 e200_3 e211_1 e211_3"
local almycen  "e57_4_2 e196_2 e200_2 e211_2"

* monto recibido por tus-mides y tus-inda
loc y_tusmides "0"
loc y_tusinda  "0"

* otras transferencias de alimentación
loc y_ticketsinda  "e254 * 4.3"
loc y_lecheenpolvo "0"

// AFAM

* monto afam declarado
loc mto_afam_declarado "g257"
* condiciones de recepción afam
loc afampe_cond1  "(g256==2 & g152==1)"
loc afampe_cond2  "(g150==1 & (inlist(bc_pobp, 1, 3, 4, 6, 7, 8, 11) | (bc_pobp==2 & !formal_op & !formal_os)))"
loc afampe_cond3  "(g255==1)"
loc afamcont_cond "g150==1 & afam_pe==0"
* afam no incluída en el sueldo
assert g256==0 if g150!=1
assert (g150==1 & g256!=1) == (g256==2)
loc afam_nosueldo "g256==2"

* numero de beneficiarios de afam por tipo
loc hh_n_afam_men18       "g151_1 g151_2 g151_3 g151_5"
loc hh_n_afam_comp_liceo  "g151_3_1"
loc hh_n_afam_disca       "g151_4"

* ingresos considerados para la afam contributiva
loc ing_nucleo_afamcont "suma1 suma2 suma3 suma4"

//  #6 -------------------------------------------------------------------------
//  descomposición por fuentes -------------------------------------------------

// Transferencias

* jubilaciones y pensiones nacionales
loc y_pg911 "g148_1_1 g148_1_2 g148_1_3 g148_1_4 g148_1_5 g148_1_6 g148_1_7 g148_1_8 g148_1_9 g148_1_10 g148_1_12"
loc y_pg912 "g148_2_1 g148_2_2 g148_2_3 g148_2_4 g148_2_5 g148_2_6 g148_2_7 g148_2_8 g148_2_9 g148_2_10 g148_2_12"
* jubilaciones y pensiones de otro país
loc y_pg921 "g148_1_11"
loc y_pg922 "g148_2_11"

* becas y subsidios (del país/del exterior)
loc y_pg101 "g148_3 g148_5_1"
loc y_pg102 "g148_5_2"
* canastas que se relevan en este rubro pero restamos porque ya están contadas
loc y_pg101_fix "0"
loc y_pg102_fix "0"

* contribuciones (del país/del exterior)
loc y_pg111_per "g153_1"
loc y_pg111_hog "h155_1 h156_1"
loc y_pg112_per "g153_2"
loc y_pg112_hog "h172_1"

// Ingresos de capital

* ingreso por alquileres (del país/del extranjero)
loc y_pg121_ano "h160_1 h163_1"
loc y_pg121_mes "h252_1"
loc y_pg122_ano "h160_2 h163_2"
loc y_pg122_mes "0"
* ingreso por intereses (del pais/del extranjero)
loc y_pg131     "h168_1"
loc y_pg132     "h168_2"
* utilidades
loc y_util_per  "g143"
loc y_util_hog  "h170_1 h170_2"
* otras fuentes de capital
loc y_otrok_hog "h164 h165 h166"

// Otros ingresos

loc pagos_atrasados   "g126_7 g134_7"
loc devolucion_fonasa "g258_1"

//  #7 -------------------------------------------------------------------------
//  Últimos retoques -----------------------------------------------------------

* variables que no están disponibles este año
loc bc_yalimpan "0"
loc bc_cuotabps "-13"
loc bc_disse_p  "-13"
loc bc_disse_o  "-13"
loc bc_disse    "-13"
loc bc_pf051    "-13"
loc bc_pf052    "-13"
loc bc_pf053    "-13"
loc bc_pf06     "-13"
