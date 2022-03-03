/*
	ech_2013_specs.do
	Parámetros específicos de la ECH 2013.
*/

//  #1 -------------------------------------------------------------------------
//  correcciones de datos ------------------------------------------------------

gen dummy0  = 0
gen dummy13 = -13

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
* check: son variables numericas
confirm numeric variable `nper_d_asseemp' `nper_d_iamcemp' `nper_d_privemp' `nper_d_mili' `nper_d_emeremp'

//  trabajo ----------------------------------------------------------

* condición de actividad
local bc_pobp "pobpcoac (10 = 9)"

* formalidad
loc formal_op "f82==1" 
loc formal_os "f96==1" 

* categoría de ocupación principal y secundaria
local catocup_op "f73 (8 = 7)"
local catocup_os "f92 (0 = 0)"

* tamaño del establecimiento
loc pf081 "f77 (1/3 = 1) (5/7 = 2) (0 = .c)"
loc pf082 "f77 (0 4/7 = .c)"

* ciiu ocupacion principal y ocupacion secundaria
loc ciiu_op "f72_2"
loc ciiu_os "f91_2"

* revisión de la ciiu usada este año –– ver lib/local_ciiu_rama8.do
loc ciiurev "4"

* cantidad de empleos
loc pf07 "f70 (0 = .c)"

* horas trabajadas habitualmente (total/op)
loc bc_horas_hab    "f85 f98"
loc bc_horas_hab_op "f85"
* horas trabajadas la semana pasada (total/op)
loc bc_horas_sp    "dummy13"
loc bc_horas_sp_op "dummy13"

* motivo por el que no trabaja
loc pf04 "f69 (3 5/6 = 4) (4 = 3) (0 = .c)"

//  #4 -------------------------------------------------------------------------
//  educación ------------------------------------------------------------------

//  #5 -------------------------------------------------------------------------
//  reconstrucción de ingresos -------------------------------------------------

// ingresos laborales

* monetizo pagos en especie – dependientes op
cap gen y_g127_1 = g127_1 * mto_desa
cap gen y_g127_2 = g127_2 * mto_almu
cap gen y_g132_1 = g132_1 * mto_vaca
cap gen y_g132_2 = g132_2 * mto_ovej
cap gen y_g132_3 = g132_3 * mto_caba
* monetizo pagos en especie – depedientes os
cap gen y_g135_1 = g135_1 * mto_desa
cap gen y_g135_2 = g135_2 * mto_almu
cap gen y_g140_1 = g140_1 * mto_vaca
cap gen y_g140_2 = g140_2 * mto_ovej
cap gen y_g140_3 = g140_3 * mto_caba
* divido entre 12 pagos en especie anuales
cap gen y_g133_2 = g133_2 / 12
cap gen y_g141_2 = g141_2 / 12

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

// ingresos laborales

* ingreso monetario ocupación principal
loc yl_rem_salario_op    "g126_1"
loc yl_rem_comisiones_op "g126_2 g126_3"
loc yl_rem_aguinaldo_op  "g126_5"
loc yl_rem_vacacional_op "g126_6"
loc yl_rem_propina_op    "g126_4"
* ingreso monetario ocupación secundaria
loc yl_rem_salario_os    "g134_1"
loc yl_rem_comisiones_os "g134_2 g134_3 g139_1" // ??
loc yl_rem_aguinaldo_os  "g134_5"
loc yl_rem_vacacional_os "g134_6"
loc yl_rem_propina_os    "g134_4"

* ingreso en especie
loc yl_rem_esp_op "g126_8 g127_3 g128_1 g129_2 g130_1 y_g127_1 y_g127_2 g131_1 y_g132_1 y_g132_2 y_g132_3 g133_1 y_g133_2"
loc yl_rem_esp_os "g134_8 g135_3 g136_1 g137_2 g138_1 y_g135_1 y_g135_2 y_g140_1 y_g140_2 y_g140_3 g141_1 y_g141_2"

* ingreso por beneficios sociales
loc yl_ben_mon    "g148_4"

* ingreso por negocios propios
loc yl_mix_mon_mes "g142"
loc yl_mix_mon_ano "g145 g146 g147"
loc yl_mix_esp     "g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5"

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
loc y_pg122_mes "dummy0"
* ingreso por intereses (del pais/del extranjero)
loc y_pg131     "h168_1"
loc y_pg132     "h168_2"
* utilidades
loc yk_util_per  "g143"
loc yk_util_hog  "h170_1 h170_2"
* otras fuentes de capital
loc yk_otro_hog "h164 h165 h166"

// Otros ingresos

loc yl_rem_atrasado_op "g126_7"
loc yl_rem_atrasado_os "g134_7"
loc devolucion_fonasa  "g258_1"

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
