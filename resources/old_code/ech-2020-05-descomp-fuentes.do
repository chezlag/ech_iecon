capture log close
log using "log/ech-2020-05-descomp-fuentes.log", replace text

//  ech-2020-05-descomp-fuentes.do
//  gsl \ 2021-09-29

//  preamble

version 15
clear all
set more off
set linesize 100
macro drop _all
* macros
local date:  di %tdCY-N-D daily("$S_DATE", "DMY")
local tag    "2019-05.do gsl `date'"
local fullnm "ech-2020-05-descomp-fuentes"

// ----------------------------------------------
// use

use "data/tmp/ech-2020-03.dta", clear
datasig confirm
notes _dta

// ----------------------------------------------

*-------------------------------------------------------------------------------
* Se re-definen variables de acuerdo a Iecon

// Tansferencias jubilaciones y pensiones.

* sacamos becas, subsidios y donaciones porque va a canasta "otras"	
egen ytransf_1_iecon = rowtotal(g148_1_1 g148_1_2  g148_1_3  g148_1_4  g148_1_5    ///
	g148_1_6  g148_1_7  g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1 ///
	g148_2_2  g148_2_3  g148_2_4  g148_2_5  g148_2_6  g148_2_7  g148_2_8           ///
	g148_2_9  g148_2_12 g148_2_10 g148_2_11 g148_3    g148_4    g153_1    g153_2)

replace YTRANSF_1 = ytransf_1_iecon if e246==11
drop ytransf_1_iecon

* Asignaciones familiares
replace YTRANSF_2 = 0
replace YTRANSF_2 = monto_afam_cont if g256==2 			// Se incluyen las asignaciones contributivas solo si son cobradas por fuera del sueldo
replace YTRANSF_2 = YTRANSF_2 + monto_afam_pe 			// Todas las asignaciones familiares - plan de equidad son cobradas por fuera del sueldo
														// por esa razón, no se utiliza la restricción dada por g256==1
*Políticas sociales, ingresos por alimentación

* único cambio real respecto al anterior
replace CANASTA = g148_5_1+g148_5_2 if e246==11 // Otras canastas, cambió en ECH 2018

*Se genera una variable de alimentos para todos sin importar si son mayores de 14 años o no
*	saca TUS de YALIMENT
egen    yalim_totV2   = rowtotal(DESAYMER ALMYCEN CANASTA leche)  //Monto tus del iecon va para bc_tarjeta
replace YALIMENT      = yalim_totV2 if bc_pe3>=14
replace YALIMENT_MEN1 = yalim_totV2 if bc_pe3< 14
recode  YALIMENT YALIMENT_MEN1 (. = 0)

* transferencia de alimentos para menores de 14
drop    YALIMENT_MEN
egen    YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
replace YALIMENT_MEN = 0 if !esjefe

* transferencias de alimentos para mayores de 14
replace YTRANSF_4 = YALIMENT

// ingreso de transferencias: total
	
drop YTRANSF
egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)

* emergencia paga por otro hogar

*egen    n_emerotr    = sum(ss_emerotr), by(bc_correlat)
*replace n_emerotr    = 0 if !esjefe
*gen    yt_ss_emerotr = n_emerotr * mto_emer

gen emerg_otrohog_h = n_emerotr * mto_emer

// Valor locativo

cap gen loc=substr(loc_agr, 3,3)
destring loc, replace
/* 
cap drop bc_pg14
gen     bc_pg14 = 0
replace bc_pg14 = d8_3 if (d8_1!=6 & (d8_1!=5 & loc!=900))	// Código compatible
replace bc_pg14 = 0    if ine_ht13==0 & d8_1!=6				// Excepción porque nosotros no podemos identificar zonas rurales en Mdeo, entonces tomamos valor de INE

gen    sal_esp_net = g129_2-bc_pg14 if d8_1==6 & g129_2!=0 // Salario en especie neto de valor locativo para ocupantes en rel. de dependencia
recode sal_esp_net   (. = 0)
	
gen     corr_sal_esp = -bc_pg14 if sal_esp_net>0  // Corrección para salario en especie, es el valor locativo (*-1) si esta diferencia es positiva
replace corr_sal_esp = -g129_2  if sal_esp_net<=0 // Corrección para salario en especie, es todo el salario en especie si la dif entre valor loc y salario es negativa
 */	
gen bc_pg14      = ine_ht13 // en p19: compare ht13 bc_pg14 solo son != en 22 obs. good enough
gen sal_esp_net  = 0
gen corr_sal_esp = 0


//  #2
//  ingresos por rubros

replace deppub_op = bc_pf41==2

* Comienza a generar variables de ingresos para los ocupados en relación de dependencia. ocupación principal

gen bc_pg11p = g126_1           if bc_pf41==1 // sueldos o jornales líquidos trabajadores dependientes privados
gen bc_pg21p = g126_1           if bc_pf41==2 // sueldos o jornales líquidos trabajadores dependientes públicos
gen bc_pg12p = g126_2 + g126_3  if bc_pf41==1 // complementos salariales privados
gen bc_pg22p = g126_2 + g126_3  if bc_pf41==2 // complementos salariales públicos
gen bc_pg14p = g126_5           if bc_pf41==1 // aguinaldo privados
gen bc_pg24p = g126_5           if bc_pf41==2 // aguinaldo públicos
gen bc_pg15p = g126_6           if bc_pf41==1 // salario vacacional privados
gen bc_pg25p = g126_6           if bc_pf41==2 // salario vacacional públicos
gen bc_pg16p = g126_4           if bc_pf41==1 // propinas privados
gen bc_pg26p = g126_4           if bc_pf41==2 // propinas públicos

local   varl "bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p"
recode `varl' (. = 0)

gen bc_pg17p=g126_8+g127_3+g128_1+g129_2+g130_1+(g127_1*mto_desa)+(g127_2*mto_alm) /*
*/ +g131_1+(g132_1*mto_vac)+(g132_2*mto_ovej)+(g132_3*mto_cab)+g133_1+(g133_2/12)+EMER_EMP_TOT +CUOT_EMP_PRIV_TOT + CUOT_EMP_IAMC_TOT+CUOT_EMP_ASSE_TOT +corr_sal_esp if bc_pf41==1

gen bc_pg27p=g126_8+g127_3+g128_1+g129_2+g130_1+(g127_1*mto_desa)+(g127_2*mto_alm) /*
*/ +g131_1+(g132_1*mto_vac)+(g132_2*mto_ovej)+(g132_3*mto_cab)+g133_1+(g133_2/12)+EMER_EMP_TOT+CUOT_EMP_PRIV_TOT+CUOT_EMP_IAMC_TOT+CUOT_EMP_ASSE_TOT +corr_sal_esp if bc_pf41==2

replace mto_hogc=0 if g149!=1 | g149_1==1   /*monto hog constituido=0 para los que no cobran o que declaran incluido en el sueldo*/

** ingresos por transferencia: asignaciones básicamente
cap drop bc_pg13p bc_pg23p bc_pg13o bc_pg23o
mvencode YTRANSF_2 g148_4 mto_hogc YTRANSF_4 , mv(0) override 

gen bc_pg13p=g148_4+mto_hogc if bc_pf41==1 
replace bc_pg13p=YTRANSF_2+g148_4+mto_hogc   if bc_pf41==1&(g150==1&g256!=1)&afam_pe==0

gen bc_pg23p=g148_4+mto_hogc if bc_pf41==2 
replace bc_pg23p=YTRANSF_2+g148_4+mto_hogc if bc_pf41==2&(g150==1&g256!=1)&afam_pe==0

// Otras ocupaciones en relación de dependencia

capture drop bc_pg11o bc_pg12o bc_pg14o bc_pg15o bc_pg16o pg17o_cf pg17o_sf bc_pg21o bc_pg22o  bc_pg24o bc_pg25o bc_pg26o pg27o_cf pg27o_sf bc_pg13o bc_pg23o
gen bc_pg11o = g134_1                   if deppri_os // sueldos o jornales líquidos trabajadores dependientes privados
gen bc_pg21o = g134_1                   if deppub_os // sueldos o jornales líquidos trabajadores dependientes públicos
gen bc_pg12o = g134_2 + g134_3 + g139_1 if deppri_os // complementos salariales privados
gen bc_pg22o = g134_2 + g134_3 + g139_1 if deppub_os // complementos salariales públicos
gen bc_pg14o = g134_5                   if deppri_os // aguinaldo privados
gen bc_pg24o = g134_5                   if deppub_os // aguinaldo públicos
gen bc_pg15o = g134_6                   if deppri_os // salario vacacional privados
gen bc_pg25o = g134_6                   if deppub_os // salario vacacional públicos
gen bc_pg16o = g134_4                   if deppri_os // propinas privados
gen bc_pg26o = g134_4                   if deppub_os // propinas publicos

gen bc_pg17o = g134_8 + g135_3 + g136_1 + g137_2 + g138_1 ///
	+ (g135_1*mto_des) + (g135_2*mto_alm) ///
	+ (g140_1*mto_vac) + (g140_2*mto_ove) + (g140_3*mto_cab) ///
	+ g141_1 + (g141_2/12) ///
	if deppri_os // asalariados privados
* agrega cuotas mutuales si no son dependientes en ocupación principal
replace bc_pg17o = bc_pg17o ///
	+ yt_ss_emeremp + yt_ss_privemp + yt_ss_iamcemp + yt_ss_asseemp ///
	if deppri_os & !inlist(bc_pf41, 1, 2)

* en especie público otras ocupaciones
gen bc_pg27o = g134_8 + g135_3 + g136_1 + g137_2 + g138_1 ///
	+ (g135_1*mto_des) + (g135_2*mto_alm) ///
	+ (g140_1*mto_vac) + (g140_2*mto_ove) + (g140_3*mto_cab) ///
	+ g141_1 + (g141_2/12) ///
	if deppub_os

*asignaciones de ocupación secundaria no declaradas en el sueldo
* privados en ocupacion secundaria
gen     bc_pg13o = g148_4 + mto_hogc             if deppri_os & !inlist(bc_pf41, 1, 2, 3, 5, 6)
replace bc_pg13o = g148_4 + mto_hogc + YTRANSF_2 if deppri_os & !inlist(bc_pf41, 1, 2, 3, 5, 6) ///
												  & g150==1 & g256!=1 & afam_pe==0
* públicos en ocupación secundaria
gen     bc_pg23o = g148_4 + mto_hogc             if deppub_os & !inlist(bc_pf41, 1, 2, 3, 5, 6)
replace bc_pg23o = g148_4 + mto_hogc & YTRANSF_2 if deppub_os & !inlist(bc_pf41, 1, 2, 3, 5, 6) ///
												  & g150==1 & g256!=1 & afam_pe==0

*total
capture drop bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t_cf bc_pg17t_sf
mvencode bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p bc_pg27p bc_pg11o bc_pg12o bc_pg13o bc_pg14o bc_pg15o bc_pg16o bc_pg17o bc_pg21o bc_pg22o bc_pg23o bc_pg24o bc_pg25o bc_pg26o bc_pg27o, mv(0) override
gen bc_pg11t = bc_pg11o + bc_pg21o
gen bc_pg12t = bc_pg12o + bc_pg22o
gen bc_pg13t = bc_pg13o + bc_pg23o
gen bc_pg14t = bc_pg14o + bc_pg24o
gen bc_pg15t = bc_pg15o + bc_pg25o
gen bc_pg16t = bc_pg16o + bc_pg26o
gen bc_pg17t = bc_pg17o + bc_pg27o // Se introduce el cambio por no descomponer fonasa por fuentes


// Ingresos laborales en ocupaciones no dependientes

* ingresos por transferencia para ocupación principal
capture drop  bc_pg32p
capture drop  bc_pg42p
capture drop  bc_pg72p
gen bc_pg32p=0
replace bc_pg32p=g148_4+mto_hogc  if bc_pf41==5  // Cuenta propia sin local
replace bc_pg32p=YTRANSF_2+g148_4+mto_hogc if bc_pf41==5 & (g150==1&g256!=1)&afam_pe==0 // Cuenta propia sin local
gen bc_pg42p=0
replace bc_pg42p=g148_4+mto_hogc if bc_pf41==6   // Cuenta propia con local
replace bc_pg42p=YTRANSF_2+g148_4+mto_hogc  if bc_pf41==6 & (g150==1&g256!=1)&afam_pe==0 // Cuenta propia con local
gen bc_pg72p=0
replace bc_pg72p=g148_4+mto_hogc if bc_pf41==3 // Cooperativista
replace bc_pg72p=YTRANSF_2+g148_4+mto_hogc if bc_pf41==3 & (g150==1&g256!=1)&afam_pe==0 // Cooperativista

* ingresos por transferencias ocupaciones secundarias
capture drop  bc_pg32o
capture drop  bc_pg42o
capture drop  bc_pg72o
gen bc_pg32o=0
replace bc_pg32o=g148_4+mto_hogc if f92==5 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1) 
replace bc_pg32o=YTRANSF_2+g148_4+mto_hogc if f92==5 & (g150==1&g256!=1)&(bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0
gen bc_pg42o=0
replace bc_pg42o=g148_4+mto_hogc if f92==6  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)
replace bc_pg42o=YTRANSF_2+g148_4+mto_hogc  if f92==6 & (g150==1&g256!=1)&(bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0
gen bc_pg72o=0
replace bc_pg72o=g148_4+mto_hogc if f92==3  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)
replace bc_pg72o=YTRANSF_2+g148_4+mto_hogc if f92==3 &(g150==1&g256!=1)&(bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & bc_pf41!=2 & bc_pf41!=1)&afam_pe==0

// trabajador no dependiente - ingresos por negocios propios

egen y_negocios_dinero       = rowtotal(g142)
egen y_negocios_dinero_anual = rowtotal(g145 g146 g147)
egen y_negocios_especie      = rowtotal(g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5)

egen y_cuotasmutuales = rowtotal(yt_ss_emeremp yt_ss_privemp yt_ss_iamcemp yt_ss_asseemp)

* ocupación principal
gen bc_pg31p = y_negocios_dinero + y_negocios_dinero_anual/12 if bc_pf41==5 // Cp sin local - Dinero
gen bc_pg41p = y_negocios_dinero + y_negocios_dinero_anual/12 if bc_pf41==6  // Cp con local - Dinero
gen bc_pg51p = y_negocios_dinero + y_negocios_dinero_anual/12 if bc_pf41==4  // patrón - Dinero
gen bc_pg71p = y_negocios_dinero + y_negocios_dinero_anual/12 if bc_pf41==3  // cooperativista
gen bc_pg33p = y_negocios_especie + y_cuotasmutuales          if bc_pf41==5  // Cp sin local - Especie
gen bc_pg43p = y_negocios_especie + y_cuotasmutuales          if bc_pf41==6  // Cp con local - Especie
gen bc_pg52p = y_negocios_especie + y_cuotasmutuales          if bc_pf41==4 // patrón - Especie
gen bc_pg73p = y_negocios_especie + y_cuotasmutuales          if bc_pf41==3 // cooperativista - Especie

* ocupación secundaria
gen bc_pg31o = y_negocios_dinero + y_negocios_dinero_anual/12 if inlist(bc_pg31p,0, .) & f92==5 & !inrange(bc_pf41, 3, 6) 
gen bc_pg41o = y_negocios_dinero + y_negocios_dinero_anual/12 if inlist(bc_pg41p,0, .) & f92==6 & !inrange(bc_pf41, 3, 6)
gen bc_pg51o = y_negocios_dinero + y_negocios_dinero_anual/12 if inlist(bc_pg51p,0, .) & f92==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg71o = y_negocios_dinero + y_negocios_dinero_anual/12 if inlist(bc_pg71p,0, .) & f92==3 & !inrange(bc_pf41, 3, 6)
gen bc_pg33o = y_negocios_especie                             if                         f92==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg43o = y_negocios_especie                             if                         f92==6 & !inrange(bc_pf41, 3, 6)
gen bc_pg52o = y_negocios_especie                             if                         f92==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg73o = y_negocios_especie                             if                         f92==3 & !inrange(bc_pf41, 3, 6)


// otros ingresos laborales

capture drop bc_otros_lab

* ocupación principal
cap drop bc_otros_lab
gen bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
    + (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
    + g133_1 + (g133_2/12) + g131_1 + corr_sal_esp  ///
    if !inlist(bc_pf41, 1, 2)

replace bc_otros_lab = g142 + g144_1 + (g145 + g146 + g147)/12 ///
	if !independiente_op & !independiente_os 

replace bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
	+ (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
	+ g133_1 + (g133_2/12) + g142 + g144_1 + (g145 + g146 + g147)/12 + corr_sal_esp  ///
	if !inrange(bc_pf41, 1, 6) & !independiente_os  // Otras actividades

replace bc_otros_lab = g126_1 + g126_2 + g126_3 + g126_4 + g126_5 + g126_6 + g126_8 ///
	+ g127_3 + g128_1 + g129_2 + g130_1 ///
	+ (g127_1*mto_des) + (g127_2*mto_alm) + (g132_1*mto_vac) + (g132_2*mto_ove) + (g132_3*mto_cab) ///
	+ g133_1 + (g133_2/12) + g142 + g144_1 +(g145 + g146 + g147)/12 ///
	+ g144_2_1 + g144_2_2 + g144_2_3 + g144_2_4 + g144_2_5 + g131_1 ///
	+ corr_sal_esp ///
	if bc_pf41==-9

* recode  bc_otros_lab (. = 0)

* otras ocupaciones
capture drop bc_otros_lab2
gen bc_otros_lab2 = g134_1 + g134_2 + g134_3 + g134_4 + g134_5 + g134_6 + g134_8 ///
	+ g135_3 + g136_1 + g137_2 + g138_1 + (g135_1*mto_des) + (g135_2*mto_alm) ///
	+ (g140_1*mto_vac) + (g140_2*mto_ove) + (g140_3*mto_cab) + g141_1 + (g141_2/12) + g139_1 ///
	if !inlist(f92, 1, 2)
recode  bc_otros_lab2 (. = 0)

capture drop bc_otros_benef
gen     bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1
replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 if afam_pe>0 // 2/6/20 cambio hay que ver si no está duplicando para bc_pf41 = 7 o 4????
replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(f92, 1, 2, 3, 5, 6)

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 // esta linea borra todo lo anterior

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(f92, 1, 2, 3, 5, 6)

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 ///
	if (g150==1 | g257>0) & (afam_pe>0) // 08/04/19 cambio

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 +             g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(f92, 1, 2, 3, 5, 6) & esjefe

replace bc_otros_benef = YTRANSF_4 + YALIMENT_MEN1 + YTRANSF_2 + g148_4 + mto_hogc ///
	if !inlist(bc_pf41, 1, 2, 3, 5, 6) & !inlist(f92, 1, 2, 3, 5, 6) & esjefe

/* las últimas dos lineas son contradictorias / gsl 2021-09-20 */

* pagos atrasados
cap drop bc_pag_at
gen bc_pag_at=g126_7+g134_7



*-------------------------------------------------------------------------------
*- Jubilaciones

gen bc_pg911 = g148_1_1+ g148_1_2+g148_1_3+g148_1_4+g148_1_5+g148_1_6+g148_1_7+g148_1_8+g148_1_9+g148_1_10+g148_1_12 ///
			 if f124_1==1
gen bc_pg912 = g148_2_1+g148_2_2+g148_2_3+g148_2_4+g148_2_5+g148_2_6+g148_2_7+g148_2_8+g148_2_9+g148_2_10+g148_2_12 /// 
			 if f124_2==1
recode bc_pg911 bc_pg912 (. = 0)

gen bc_pg921 = g148_1_11 
gen bc_pg922 = g148_2_11

gen bc_pg91  = bc_pg911+bc_pg912
gen bc_pg92  = bc_pg921+bc_pg922


gen     bc_pg101 = g148_3 + g148_5_1
replace bc_pg101 = g148_3            if e246==11 // Monto g148_5_1 va a canasta
gen     bc_pg102 = g148_5_2
replace bc_pg102 = 0                 if e246==11 // Monto g148_5_2 va a canasta

gen     bc_pg111 = g153_1
replace bc_pg111 = bc_pg111 + emerg_otrohog_h + h155_1 + h156_1 if esjefe
gen     bc_pg112 = g153_2
replace bc_pg112 = bc_pg112 + h172_1/12                         if esjefe

gen bc_pg121 = h160_1/12  + h163_1/12   + h252_1 + h269_1/12
gen bc_pg122 = h163_2/12  + h160_2/12
gen bc_pg131 = h167_1_1/12+ h167_2_1/12 + h167_3_1/12 + h167_4_1/12
gen bc_pg132 = h167_1_2/12+ h167_2_2/12 + h167_3_2/12 + h167_4_2/12

*-------------------------------------------------------------------------------
*- Ingresos de capital

mvencode  h170_2 h170_1  h164  h166  h171_1 , mv(0) override

gen bc_pg60p      = g143/12 if bc_pf41==4
gen bc_pg80p      = g143/12 if bc_pf41==3
gen bc_pg60p_cpsl = g143/12 if bc_pf41==5
gen bc_pg60p_cpcl = g143/12 if bc_pf41==6

gen bc_pg60o      = g143/12 if inlist(bc_pg60p, 0, .)      & f92==4 & !inrange(bc_pf41, 3, 6)
gen bc_pg80o      = g143/12 if inlist(bc_pg80p, 0, .)      & f92==3 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpsl = g143/12 if inlist(bc_pg60p_cpsl, 0, .) & f92==5 & !inrange(bc_pf41, 3, 6)
gen bc_pg60o_cpcl = g143/12 if inlist(bc_pg60p_cpcl, 0, .) & f92==6 & !inrange(bc_pf41, 3, 6)

* Utilidades para quienes no son patrón, cooperativista o cuenta propia c/s local
gen     bc_otras_utilidades = g143/12                               if !inrange(bc_pf41, 3, 6) & !inrange(f92, 3, 6)
replace bc_otras_utilidades = g143/12+h170_1/12+h170_2/12+h271_1/12 if !inrange(bc_pf41, 3, 6) & !inrange(f92, 3, 6) & esjefe
recode  bc_otras_utilidades (. = 0)

* Utilidades a nivel de hogar de patrón, cooperativista o cuenta propia c/s local
gen bc_ot_utilidades = h170_1/12+h170_2/12+h271_1/12 if (inlist(bc_pf41, 3, 4, 5, 6) | inlist(f92, 3, 4, 5, 6)) & esjefe
recode bc_ot_utilidades (. = 0)

* Medianería, pastoreo y ganado a capitalizar a nivel de hogar
gen    bc_otras_capital = (h164+h165+h166)/12               if esjefe
recode bc_otras_capital (. = 0)
gen     otros = bc_pag_at + g154_1 + g258_1/12 
replace otros = bc_pag_at + g154_1 + g258_1/12 + h171_1/12  if esjefe


// ----------------------------------------------
// save

quietly compress		
notes: ech-2020-04.dta \ ingreso ht11 iecon \ `tag'
label data "ECH 2020 [tmp 4] \ `date'"
datasignature set, reset
save  "data/tmp/ech-2020-04.dta", replace

// ----------------------------------------------

log close
exit
