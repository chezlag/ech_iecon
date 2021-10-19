**************************************
**************************************
*****     Sintaxis2_cmilitar     *****
**************************************
**************************************


*-------------------------------------------------------------------------------
* CUOTA MILITAR GENERADA Por MIEMBRO DEL HOGAR


* Se calcula cuotas militares, adjudicadas a militar que las genera.
* Se toma a quienes tienen derecho en sanidad militar a través de un miembro de este hogar y a su vez no generan derecho por FONASA ya sea por miembro del hogar o por otro hogar.


*gen at_milit = 1 if e45_4_1 == 1 & ((e45_1_1 != 1 & e45_1_1 !=4 & e45_1_1 != 5 & e45_1_1 !=6) & (e45_2_1 != 1 & e45_2_1!=6 & e45_2_1 !=3 & e45_2_1 !=5) & (e45_3_1 != 1& e45_3_1 !=6 & e45_3_1 !=3 & e45_3_1!=5 ))
gen at_milit = 1 if e45_4_1 == 1 & ((e45_1_1 != 1 & e45_1_1 !=4) & (e45_2_1 != 1 & e45_2_1!=6) & (e45_3_1 != 1& e45_3_1 !=6))
recode at_milit .=0

*Tomo a todos quienes tienen derecho a atención militar y no tienen FONASA ya sea por miembro del hogar o por otro hogar . 

*gen at_milit2 = 1 if e45_4 == 1 & ((e45_1_1 != 1 & e45_1_1 !=4 & e45_1_1 != 5 & e45_1_1 !=6) & (e45_2_1 != 1 & e45_2_1!=6 & e45_2_1 !=3 & e45_2_1 !=5) & (e45_3_1 != 1& e45_3_1 !=6 & e45_3_1 !=3 & e45_3_1!=5 ))
gen at_milit2 = 1 if e45_4 == 1 & ((e45_1_1 != 1 & e45_1_1 !=4) & (e45_2_1 != 1 & e45_2_1!=6) & (e45_3_1 != 1& e45_3_1 !=6))
recode at_milit2 .=0

sort bc_correlat bc_nper

egen cuotmilit1 = sum(at_milit) if e45_4_2>0, by (bc_correlat e45_4_2)
*gen ramamilit_op = 1 if f72_2  == 5222 | f72_2  == 5223 | f72_2  == 8030 |  f72_2  == 8411 | f72_2  == 8421 | f72_2 == 8422 | f72_2  == 8423 | f72_2  == 8430 | f72_2  == 8521 | f72_2  == 8530 | f72_2  == 8610    
tostring f72_2 f91_2, replace
gen ramamilit_op= 1 if substr(f72_2,1,3) == "752" | substr(f72_2,1,3) == "753" | f72_2 == "8511" | substr(f72_2,1,3) == "802" | substr(f72_2,1,3) == "803" | substr(f72_2,1,3) == "751"
recode ramamilit_op .=0

gen cuotmilit_op = cuotmilit1 
replace cuotmilit_op=0 if (ramamilit_op==0|e45_4_2!=bc_nper)

gen valorcuota_op = cuotmilit_op*mto_cuot
gen ytdop_2 = valorcuota_op

***Cuota militar ocupación secundaria.

*gen ramamilit_os =1 if f91_2  == 5222 | f91_2  == 5223 | f91_2  == 8030 |  f91_2  == 8411 | f91_2  == 8421 | f91_2 == 8422 | f91_2  == 8423 | f91_2  == 8430 | f91_2  == 8521 | f91_2  == 8530 | f91_2  == 8610 
     
gen ramamilit_os= 1 if substr(f91_2,1,3) == "752" | substr(f91_2,1,3) == "753" | f91_2 == "8511" | substr(f91_2,1,3) == "802" | substr(f91_2,1,3) == "803" | substr(f91_2,1,3) == "751"
recode ramamilit_os .=0

destring f72_2 f91_2, replace

gen cuotmilit_os = cuotmilit1
replace cuotmilit_os=0 if (ramamilit_os==0|e45_4_2!=bc_nper)
replace cuotmilit_os=0 if cuotmilit_op>0

gen valorcuota_os = cuotmilit_os*mto_cuot
gen ytdos_2 = valorcuota_os

***Se suman todas las cuotas de op, os y las totales sin derecho a FONASA a la vez. 
egen cuotmilit2 = sum(at_milit2) , by(bc_correlat)
egen tot_cuotmilit_op=sum(cuotmilit_op), by(bc_correlat)
egen tot_cuotmilit_os=sum(cuotmilit_os), by(bc_correlat)

g cuotmilit_hogar = (cuotmilit2 - (tot_cuotmilit_op + tot_cuotmilit_os )) * mto_cuot

***Las cuotas se las asigno al jefe de hogar.

replace cuotmilit_hogar=0 if bc_nper != 1
*-------------------------------------------------------------------------------

**************************************
**************************************
*****      Sintaxis3_fonasa      *****
**************************************
**************************************


*FONASA trabajador ocupación principal.

gen ytdop_3 = 0
replace ytdop_3 = mto_cuot if (((e27>= 14) & (f73 < 3 | f73==8 | f73 == 7) & f82==1) & (e45_1_1 == 1| e45_2_1== 1 | e45_3_1== 1)) 
*FONASA trabajador ocupación secundaria.

gen ytdos_3 = 0
replace ytdos_3 = mto_cuot if (((e27>= 14 & (f92 < 3 | f92 == 7) & ytdop_2==0 & ytdop_3==0) & f96==1) & (e45_1_1 == 1| e45_2_1== 1 | e45_3_1== 1))
*FONASA Trabajador independiente.

gen YTINDE_2 = 0
replace YTINDE_2=mto_cuot if ((e27>= 14 & (f73>2 & f73<7 & f82==1) | e27>= 14 & (f92>2 & f92<7 & f96==1)) & (e45_1_1 == 1| e45_2_1== 1 | e45_3_1== 1) & ytdop_3==0 & ytdos_3==0 & ytdop_2==0 & ytdos_2==0)
*FONASA. Para todos quienes generan derecho por FONASA y no son adjudicables al trabajo.

gen tienefonasaHOG = 1 if (e45_1_1 ==1 | e45_1_1 == 4 | e45_2_1 ==1 | e45_2_1 ==6 | e45_3_1 == 1 | e45_3_1 ==6) & ytdop_3 ==0 & ytdos_3 ==0 & YTINDE_2 ==0
recode tienefonasaHOG .=0
	
*SOLO FONASAS ADJUDICABLES AL HOGAR.
egen totfonasa_hogar = sum(tienefonasaHOG), by(bc_correlat)
replace totfonasa_hogar=0 if e30!=1

gen totfonasa_hogar2=totfonasa_hogar*mto_cuot
/*
*CUOTA MUTUAL PAGA Por EL EMPLEADor.



gen CUOT_EMP_IAMC1 =0
*replace CUOT_EMP_IAMC1=1 if (e45_2_1 ==5) & ((e45_1 ==2 | e45_1_1 == 2 | e45_1_1 == 3) & (e45_3 == 2 | e45_3_1 == 2)) el código cambia en 2012

replace CUOT_EMP_IAMC1=1 if (e45_2_1 ==5) & (e45_1 ==2  & e45_3 ==2 & e45_4 == 2)

	
egen CUOT_EMP_IAMC = sum(CUOT_EMP_IAMC1) if e45_2_1_1>0, by (bc_correlat e45_2_1_1)
foreach i of num 1/14 {
	generate aux`i'=0
	replace aux`i'=CUOT_EMP_IAMC if e45_2_1_1==`i'
}
recode CUOT_EMP_IAMC .=0	

foreach i of num 1/14 {
	egen aux`i'_max = max(aux`i'), by(bc_correlat)
}


gen		 CuotasGeneradas  = aux1_max  if bc_nper==1
replace  CuotasGeneradas  = aux2_max  if bc_nper==2
replace  CuotasGeneradas  = aux3_max  if bc_nper==3
replace  CuotasGeneradas  = aux4_max  if bc_nper==4
replace  CuotasGeneradas  = aux5_max  if bc_nper==5
replace  CuotasGeneradas  = aux6_max  if bc_nper==6
replace  CuotasGeneradas  = aux7_max  if bc_nper==7
replace  CuotasGeneradas  = aux8_max  if bc_nper==8
replace  CuotasGeneradas  = aux9_max  if bc_nper==9
replace  CuotasGeneradas  = aux10_max if bc_nper==10
replace  CuotasGeneradas  = aux11_max if bc_nper==11
replace  CuotasGeneradas  = aux12_max if bc_nper==12
replace  CuotasGeneradas  = aux13_max if bc_nper==13
replace  CuotasGeneradas  = aux14_max if bc_nper==14
recode  CuotasGeneradas .=0

g CUOT_EMP_IAMC_TOT = CuotasGeneradas*mto_cuot
drop aux1-aux14_max

*CUOTA SEGURO PRIVADO PAGA Por EL EMPLEADor.


gen CUOT_EMP_PRIV1 =0
*replace CUOT_EMP_PRIV1=1 if (e45_3_1 == 5 ) & ((e45_1 == 2 | e45_1_1 == 2 | e45_1_1 == 3) & (e45_2 == 2 | e45_2_1 == 2)) el código cambia en 2012
replace CUOT_EMP_PRIV1=1 if (e45_3_1 == 5 ) & (e45_1 ==2   & e45_2 == 2 & e45_4 == 2) 
egen CUOT_EMP_PRIV = sum(CUOT_EMP_PRIV1) if e45_3_1_1>0, by (bc_correlat e45_3_1_1)
foreach i of num 1/14 {
	generate aux`i'=0
	replace aux`i'=CUOT_EMP_PRIV if e45_3_1_1==`i'
}
recode CUOT_EMP_PRIV .=0
foreach i of num 1/14 {
	egen aux`i'_max = max(aux`i'), by(bc_correlat)
}	

gen CuotasGeneradas2 	  = aux1_max  if bc_nper==1
replace CuotasGeneradas2  = aux2_max  if bc_nper==2
replace CuotasGeneradas2  = aux3_max  if bc_nper==3
replace CuotasGeneradas2  = aux4_max  if bc_nper==4
replace CuotasGeneradas2  = aux5_max  if bc_nper==5
replace CuotasGeneradas2  = aux6_max  if bc_nper==6
replace CuotasGeneradas2  = aux7_max  if bc_nper==7
replace CuotasGeneradas2  = aux8_max  if bc_nper==8
replace CuotasGeneradas2  = aux9_max  if bc_nper==9
replace CuotasGeneradas2  = aux10_max if bc_nper==10
replace CuotasGeneradas2  = aux11_max if bc_nper==11
replace CuotasGeneradas2  = aux12_max if bc_nper==12
replace CuotasGeneradas2  = aux13_max if bc_nper==13
replace CuotasGeneradas2  = aux14_max if bc_nper==14
recode CuotasGeneradas2  .=0
	
gen CUOT_EMP_PRIV_TOT = CuotasGeneradas2*mto_cuot
drop aux1-aux14_max

*ARMO UNA VARIABLE DE CUOTA MUTUAL PAGA Por EL EMPLEADor TOTAL QUE SUME A LA DE MUTUALISTA Y SEGURO PRIVADO DE SALUD.

gen CUOT_EMP_TOT = CUOT_EMP_PRIV_TOT + CUOT_EMP_IAMC_TOT
*/
*CUOTAS PAGADAS Por ASSE A TRAVÉS DE UN MIEMBRO DEL HOGAR.
/*
No se computa para 2012

gen CUOT_EMP_ASSE1 =0
replace CUOT_EMP_ASSE1=1 if ((e45_1_1 ==5) & (e45_2 ==2  | e45_2_1 ==2) & ( e45_3 ==2 | e45_3_1 == 2))
	
egen CUOT_EMP_ASSE = sum(CUOT_EMP_ASSE1) if e45_1_1_1>0, by (bc_correlat e45_1_1_1)
foreach i of num 1/14 {
	generate aux`i'=0
	replace aux`i'=CUOT_EMP_ASSE if e45_1_1_1==`i'
	}
recode CUOT_EMP_ASSE .=0

foreach i of num 1/14 {
	egen aux`i'_max = max(aux`i'), by(bc_correlat)
	}	
gen 	CuotasGeneradas3 = aux1_max if bc_nper==1
replace CuotasGeneradas3 = aux2_max if bc_nper==2
replace CuotasGeneradas3 = aux3_max if bc_nper==3
replace CuotasGeneradas3 = aux4_max if bc_nper==4
replace CuotasGeneradas3 = aux5_max if bc_nper==5
replace CuotasGeneradas3 = aux6_max if bc_nper==6
replace CuotasGeneradas3 = aux7_max if bc_nper==7
replace CuotasGeneradas3 = aux8_max if bc_nper==8
replace CuotasGeneradas3 = aux9_max if bc_nper==9
replace CuotasGeneradas3 = aux10_max if bc_nper==10
replace CuotasGeneradas3 = aux11_max if bc_nper==11
replace CuotasGeneradas3 = aux12_max if bc_nper==12
replace CuotasGeneradas3 = aux13_max if bc_nper==13
replace CuotasGeneradas3 = aux14_max if bc_nper==14
recode  CuotasGeneradas3 .=0

gen CUOT_EMP_ASSE_TOT = CuotasGeneradas3*mto_cuot
drop aux1-aux14_max
*/
*-------------------------------------------------------------------------------

**************************************
**************************************
*****    Sintaxis4_emergencia    *****
**************************************
**************************************
/*
*EMERGENCIA MOVIL PAGA Por EL EMPLEADOR

gen EMER_EMP=0
replace EMER_EMP=1 if e47==4
egen EMER_EMP2 = sum(EMER_EMP), by (bc_correlat e47_1)

foreach i of num 1/14 {
	gen aux`i'=0
	replace aux`i'=EMER_EMP2 if e47_1==`i'
}
recode EMER_EMP2 .=0

foreach i of num 1/14 {
	egen aux`i'_max = max(aux`i'), by(bc_correlat)
}	

gen		emergeneradas = aux1_max if bc_nper==1
replace emergeneradas = aux2_max if bc_nper==2
replace emergeneradas = aux3_max if bc_nper==3
replace emergeneradas = aux4_max if bc_nper==4
replace emergeneradas = aux5_max if bc_nper==5
replace emergeneradas = aux6_max if bc_nper==6
replace emergeneradas = aux7_max if bc_nper==7
replace emergeneradas = aux8_max if bc_nper==8
replace emergeneradas = aux9_max if bc_nper==9
replace emergeneradas = aux10_max if bc_nper==10
replace emergeneradas = aux11_max if bc_nper==11
replace emergeneradas = aux12_max if bc_nper==12
replace emergeneradas = aux13_max if bc_nper==13
replace emergeneradas = aux14_max if bc_nper==14
recode  emergeneradas .=0

gen EMER_EMP_TOT = emergeneradas*mto_emer
recode EMER_EMP_TOT .=0	
drop aux1-aux14_max

*EMERGENCIA MOVIL PAGA Por OTRO HOGAR

gen EMER_OTRO =0
replace EMER_OTRO=1 if e47==3
egen EMER_OTRO2 = sum(EMER_OTRO), by (bc_correlat)	
replace EMER_OTRO2=0 if bc_nper!=1
gen EMER_OTRO_TOT = EMER_OTRO2*mto_emer
*/
*-------------------------------------------------------------------------------

**************************************
**************************************
*****     Sintaxis5_Ytrabajo     *****
**************************************
**************************************

*Ingresos por trabajo-Ocupación Principal dependiente

g ytdop_1=g126_1+g126_2+g126_3+g126_4+g126_5+g126_6+g126_7+g126_8+(g127_1*mto_desa)+(g127_2*mto_almu)+g127_3+g128_1+g129_2+g130_1+/*
*/g131_1+(g132_1*mto_vaca)+(g132_2*mto_ovej)+(g132_3*mto_caba)+g133_1+(g133_2/12)
	recode ytdop_1 .=0
g  YTDOP =  ytdop_1 + ytdop_2 + ytdop_3  // + CUOT_EMP_ASSE_TOT + + CUOT_EMP_TOT + EMER_EMP_TOT

*Ingresos por trabajo. Ocupación Secundaria dependiente

g ytdos_1 = g134_1+g134_2+g134_3+g134_4+g134_5+g134_6+g134_7+g134_8+(g135_1*mto_desa)+(g135_2*mto_almu)+g135_3+g136_1 + g137_2+/*
*/g138_1+g139_1+(g140_1*mto_vaca)+(g140_2*mto_ovej)+(g140_3*mto_caba)+g141_1+(g141_2/12)

g  YTDOS =  ytdos_1 + ytdos_2 + ytdos_3

*Ingresos por trabajo-Ocupación independiente

g YTINDE_1 = g142 + (g143/12) + g144_1 + g144_2_1 + g144_2_2  + g144_2_3 + g144_2_4 + g144_2_5 + (g145/12) + (g146/12) + (g147/12)
g YTINDE = YTINDE_1 + YTINDE_2	

*-------------------------------------------------------------------------------

**************************************
**************************************
*****    Sintaxis6_ASIG_HCONS    *****
**************************************
**************************************

*ASIGNACIONES FAMILIARES
/*
g YTRANSF_2 = g257
	replace YTRANSF_2=0 if g256 == 1
*/
/*
* Enero
gen afameq=0
replace afameq=  764*((g151_1+g151_2+g151_3)^0.6)+  327*(g151_3^0.6) if bc_mes==1 & g150==1 & g150_1!=1 & g152==1

*Resto del año.
replace afameq = 809.44*((g151_1+g151_2+g151_3)^0.6)+ 346.91*(g151_3^0.6) if bc_mes>1 & g150==1 & g150_1!=1 & g152==1

* Se identifican los núcleos familiares.


gen monto_asig=0
replace monto_asig=356.16 if suma3<=13356
replace monto_asig=178.08 if suma3>13356

gen asig_total= monto_asig*(g151_1+g151_2+g151_3+(g151_4*2))

gen afam= asig_total if g152 == 2 & g150!=1
recode afam .=0


*Se suma el total de asignaciones

gen YTRANSF_2  = afam + afameq
*/
** calcular asignaciones

* nuevo sistema

cap drop afameq

*g men_tot=g151_1+g151_2+g151_3
 * replace men_tot=4 if men_tot>4
 
g afameq=764*((g151_1+g151_2+g151_3)^ 0.6)+ 327*(g151_3 ^ 0.6) if (bc_mes != 1 & (g150==1 & g150_1!=1 & g152==1)) //la última variable indica que cobra todos los meses

replace afameq=700* ((g151_1+g151_2+g151_3) ^ 0.6)+ 300*(g151_3 ^ 0.6) if (bc_mes == 1 & (g150==1 & g150_1!= 1 & g152==1)) 

recode afameq .=0

save  "$rutainterm\p9.dta", replace

* viejo sistema

* la idea es que puede declarar cobrar asignación tanto el jefe como el cónyuge pero también declarar el ingreso correspondiente uno u otro..

keep if ((e30==1 & g150==1 & g152==2) | e30==2 ) // deja jefes que cobran cada dos meses o cónyugues

collapse (sum) a=g126_1 b=g126_2 c=g126_3  d=g134_1  e=g134_2  f=g134_3, by(bc_correlat) 

g suma= (a+b+c+d+e+f) * 1.22 // genera salario nominal total para comparar y ver qué monto le toca

drop a b c d e f

g monto_jefe =311.04 if suma<= 11664
replace monto_jefe=311.04 if suma>11664

g e30=1

sort bc_correlat e30
save "$rutainterm\jefe.dta", replace

* se pega al jefe, independientemente de quién haya declarado el ingreso

use "$rutainterm\p9.dta", clear
cap drop monto_jefe
sort bc_correlat e30
merge m:1 bc_correlat e30 using "$rutainterm\jefe.dta"
drop if _merge==2
cap drop asig_jefe
g asig_jefe=monto_jefe* (g151_1 + g151_2 + g151_3)

recode asig_jefe 0=.

save, replace 

keep if ((e30 ==2 & g150 ==1 & g152== 2) | e30==1 ) // deja cónyuges que cobran cada dos meses o jefes

collapse (sum) a=g126_1 b=g126_2 c=g126_3  d=g134_1  e=g134_2  f=g134_3, by(bc_correlat)

g suma= (a+b+c+d+e+f) * 1.22

drop a b c d e f

g monto_cony =311.04 if suma<= 11664
replace monto_cony=155.52 if suma>11664

g e30=2

sort bc_correlat e30
save "$rutainterm\conyu", replace

use "$rutainterm\p9.dta", clear
cap drop monto_cony
cap drop _merge
sort bc_correlat e30
merge m:1 bc_correlat e30 using "$rutainterm\conyu.dta"
drop if _merge==2

cap drop asig_conyu
g asig_conyu=monto_cony* (g151_1 + g151_2 + g151_3)

recode asig_conyu 0=.

save, replace 

** para otros miembros del hogar

keep if e30>2 & e30<14 & g150==1 & g152 ==2 

collapse (sum) a=g126_1 b=g126_2 c=g126_3  d=g134_1  e=g134_2  f=g134_3, by(bc_correlat bc_nper)

g suma= (a+b+c+d+e+f) * 1.22

drop a b c d e f

g monto_otro=329.76 if suma<= 12366
replace monto_otro=164.88 if suma>12366

sort bc_correlat bc_nper
save "$rutainterm\otro.dta", replace

use "$rutainterm\p9.dta", clear
cap drop monto_otro
cap drop _merge
sort bc_correlat bc_nper
merge m:1 bc_correlat bc_nper using "$rutainterm\otro.dta"
drop if _merge==2

cap drop asig_otro
g asig_otro=monto_otro* (g151_1 + g151_2 + g151_3)

recode asig_otro 0=.

save, replace 

*se crea la variable afam como agregación de asignaciones del cónyuge y otros miembros
recode  asig_jefe .=0
recode  asig_conyu .=0
recode  asig_otro .=0

*cap drop afam
g afam=asig_jefe+asig_conyu+asig_otro if g152==2 & g150_1!=1

recode afam .=0

cap drop YTRANSF_2
generate YTRANSF_2= afameq if g152==1 & g150_1!=1 // cobra todos los meses y no las declaró en el sueldo (nuevo sistema)
replace YTRANSF_2= afam if g152==2 & g150_1!=1    // cobra cada dos meses y no las declaró en el sueldo
recode YTRANSF_2 .=0
*HOGAR CONSTITUIDO
g YTRANSF_3=mto_hogc if (g149 ==1& g149_1==2)
	recode YTRANSF_3 .=0
*-------------------------------------------------------------------------------

**************************************
**************************************
*****  Sintaxis7_transferencias  *****
**************************************
**************************************

*Políticas sociales, ingresos por alimentación

g DESAYMER = 0
	replace DESAYMER = (e57_3_1+e57_3_3)*4.3*mto_desa 
g ALMYCEN = 0
	replace ALMYCEN = (e57_3_2 + e57_3_4)* 4.3 * mto_almu 
/*
g CANASTA1 = 0
	replace CANASTA1 = e247*indabajo if e246 == 1
	replace CANASTA1 = e247*indaplom if e246 == 2
	replace CANASTA1 = e247*indadiab if e246 == 4
	replace CANASTA1 = e247*indarena if e246 == 5
	replace CANASTA1 = e247*indarend if e246 == 6
	replace CANASTA1 = e247*indaceli if e246 == 7
	replace CANASTA1 = e247*indatube if e246 == 8
	replace CANASTA1 = e247*indaonco if e246 == 9
	replace CANASTA1 = e247*indasida if e246 == 10
	
g CANASTA2 = 0
	replace CANASTA2 = e249*indabajo if e248 == 1
	replace CANASTA2 = e249*indaplom if e248 == 2
	replace CANASTA2 = e249*indadiab if e248 == 4
	replace CANASTA2 = e249*indarena if e248 == 5
	replace CANASTA2 = e249*indarend if e248 == 6
	replace CANASTA2 = e249*indaceli if e248 == 7
	replace CANASTA2 = e249*indatube if e248 == 8
	replace CANASTA2 = e249*indaonco if e248 == 9
	replace CANASTA2 = e249*indasida if e248 == 10
	
g CANASTA = CANASTA1+CANASTA2
*/
g CANASTA = (e59_2_1*indabajo)+(e59_3_1*indaplom)+(e59_4_1*indapens) + (e59_5_1*indadiab)+(e59_6_1*indarena)+(e59_7_1*indarend)+(e59_8_1*indaceli) +(e59_9_1*indatube) /*
*/ +(e59_10_1*indaonco)+(e59_11_1*indasida)+ (e59_12_1*contcrit)+ (e59_13_1*otrcanas)

/*
*Tickets alimentos del INDA

g tickets = e254*4.3
recode tickets .=0
*Se genera una variable de alimentos para todos sin importar si son mayores de 14 años o no
*/
g YALIMENT=DESAYMER + ALMYCEN + CANASTA // + tickets

*Variable para menores

g YALIMENT_MEN1 = 0
	replace YALIMENT_MEN1 = YALIMENT if (e27<=13)
	replace YALIMENT =0 if (e27<=13)

g YTRANSF_4 = YALIMENT

egen YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
	replace YALIMENT_MEN=0 if bc_nper>1

*Tansferencias jubilaciones y pensiones.

g YTRANSF_1 = 0
	replace YTRANSF_1 = g148_1_1 + g148_1_2 + g148_1_3 + g148_1_4 + g148_1_5 + g148_1_6 + /*
	*/ g148_1_7 + g148_1_8 + g148_1_9  + g148_1_10 + g148_1_11+ g148_2_1+ g148_2_2 /*
	*/+ g148_2_3 + g148_2_4+ g148_2_5+ g148_2_6+ g148_2_7+ g148_2_8+ g148_2_9 +  /*
	*/ g148_2_10+ g148_2_11+ g148_3 + g148_4 + g148_5_1 + g148_5_2+ g153_1+ g153_2 // + g148_1_12 + g148_2_12
cap drop ytransf_5
g ytransf_5 = 0 
recode cuotmilit1 (.=0)
  replace ytransf_5= cuotmilit1 if pobpcoac==9|pobpcoac==10
g YTRANSF =0
	replace YTRANSF = YTRANSF_1+YTRANSF_2+YTRANSF_3+YTRANSF_4 + ytransf_5

*Transferencias imputables al hogar

*Cuota para otro hogar
g CUOT_OTROHOG=mto_cuot if ((e45_1_1 == 6) & (e45_2 == 2 | e45_2_1 == 2) & (e45_3 == 2 | e45_3_1 == 2))
	replace CUOT_OTROHOG=mto_cuot if ((e45_2_1 == 3) & (e45_1 == 2 | e45_1_1 == 2 | e45_1_1 == 3) & (e45_3 == 2 | e45_3_1 == 2))
	replace CUOT_OTROHOG=mto_cuot if ((e45_3_1 = =3) & (e45_1 == 2 | e45_1_1 == 2 | e45_1_1 == 3) & (e45_2 == 2 | e45_2_1 == 2))
	recode CUOT_OTROHOG .=0

*Se suman a los ingresos del hogar, sea mayor de 14 años o no.
egen CUOT_OTROHOG2 = sum(CUOT_OTROHOG), by(bc_correlat)
	replace CUOT_OTROHOG2=0 if bc_nper!=1

*-------------------------------------------------------------------------------
	
**************************************
**************************************
*****       Sintaxis8_Y_PT       *****
**************************************
**************************************

g OTROSY= 0
	*replace OTROSY = (g258_1/12) + g154_1
	replace OTROSY  = g154_1

*PT1. Ingresos personales por todo concepto. Se le cambia el nombre para no coincidir con los originales INE

g pt1_iecon=0
	replace pt1_iecon = YTDOP + YTDOS + YTINDE + YTRANSF + OTROSY

egen HPT1=sum(pt1_iecon), by(bc_correlat)
	replace HPT1 =0 if bc_nper!=1
**PT2 INGRESOS DE LA OCUPACIÓN PRINCIPAL.


*PRIVADOS.

g PT2PRIV = 0
	replace PT2PRIV=YTDOP if f73==1

*PÚBLICOS.

g PT2PUB = 0
	replace PT2PUB=YTDOP if (f73==2 | f73==8)

*INDEPENDIENTE.


g PT2NODEP= 0
	replace PT2NODEP=YTINDE if (f73>2 & f73<7)

*PT2 TOTAL.

g pt2_iecon= 0
	replace pt2_iecon= PT2PRIV + PT2PUB + PT2NODEP


**** PT4******.

**TOTAL DE INGRESOS Por TRABAJO. PARA ACTIVIDAD PRIMARIA Y SECUNDARIA; PUBLICA, PRIVADA E INDEPENDIENTE.

g pt4_iecon = 0
	replace pt4_iecon = YTDOP + YTDOS + YTINDE
	
*-------------------------------------------------------------------------------

**************************************
**************************************
*****   Sintaxis9_YHOG_HT11PT    *****
**************************************
**************************************

*INGRESO DEL HOGAR.

g yhog_iecon = 0

replace yhog_iecon= h155_1+h156_1+ h157_1 + (h160_1/12)+(h160_2/12)+(h163_1/12)+(h163_2/12)+/*
*/(h164/12)+(h165/12)+(h166/12) +(h168_1/12)+(h168_2/12)+(h170_1/12)+(h170_2/12)+(h171_1/12)+(h172_1/12)/*
*/+ cuotmilit_hogar + YALIMENT_MEN + totfonasa_hogar2 + CUOT_OTROHOG2 // +EMER_OTRO_TOT+ 

egen YHOG_MAX=max(yhog_iecon), by(bc_correlat)
	
replace yhog_iecon=YHOG_MAX
drop YHOG_MAX

g ht11_iecon= HPT1+ine_ht13+yhog_iecon
	replace ht11_iecon=0 if bc_nper!=1
compare ine_pt1 pt1_iecon if abs( ine_pt1- pt1_iecon)>1
compare ine_pt2 pt2_iecon if abs( ine_pt2- pt2_iecon)>1
compare ine_pt4 pt4_iecon if abs( ine_pt4- pt4_iecon)>1	
compare ine_yhog yhog_iecon if abs(ine_yhog -yhog_iecon)>1


compare ht11 ht11_iecon if abs( ht11- ht11_iecon)>3 & bc_nper==1

/* Hasta aquí se replican los resultados de INE*/

*-------------------------------------------------------------------------------
* ASIGNACIONES
*AFAM-PE


g afam_pe=0
	replace afam_pe=1 if g152==1 & (f73!=2 & f92!=2)
	replace afam_pe=1 if g150==1 & (pobpcoac==1 | pobpcoac==3 | pobpcoac==4 | pobpcoac==6 | /*
	*/ pobpcoac==7 | pobpcoac==8 | pobpcoac==11 | (pobpcoac==2 & f82!=1 & f96!=1))
	
*Otras AFAM

g afam_cont=0
	replace afam_cont=1 if g150==1 & afam_pe==0
g afam_cont_pub=0
	replace afam_cont_pub=1 if afam_cont==1 & (f73==2 | f92==2)
g afam_cont_priv=0
	replace afam_cont_priv=1 if afam_cont==1 & afam_cont_pub==0


*** BENEFICIARIOS ***
g cant_af=(g151_1+g151_2+g151_3)
total cant_af if afam_pe==1 [fw=bc_pesoan]
total cant_af if afam_cont_pub==1 [fw=bc_pesoan]
total cant_af if afam_cont_priv==1 [fw=bc_pesoan]
*** HOGARES ***
egen afam_pe_hog=max(afam_pe), by (bc_correlat)
egen afam_cont_hog=max(afam_cont), by (bc_correlat)
egen afam_cont_pub_hog=max(afam_cont_pub), by (bc_correlat)
egen afam_cont_priv_hog=max(afam_cont_priv), by (bc_correlat)
total afam_pe_hog afam_cont_pub_hog afam_cont_priv_hog if bc_nper==1 [fw=bc_pesoan]

*** MONTO AFAM-PE
g monto_afam_pe=0
	replace monto_afam_pe=700*((g151_1+g151_2+g151_3)^0.6)+ 300*(g151_3^0.6) if bc_mes==1 & afam_pe == 1
	replace monto_afam_pe=(764.34*((g151_1+g151_2+g151_3)^0.6)+327.58*(g151_3^0.6)) if afam_pe==1 & bc_mes != 1
	
*-------------------------------------------------------------------------------
* AFAM_CON - Código Iecon

gen suma_jefe=0
	replace suma_jefe= (g126_1 + g126_2 + g126_3 + g134_1 + g134_2 + g134_3)*1.22 if e30==1
	
gen suma_cony=0
	replace suma_cony= (g126_1 + g126_2 + g126_3 + g134_1 + g134_2 + g134_3)*1.22 if e30==2
	
gen suma_otro=0
	replace suma_otro= (g126_1 + g126_2 + g126_3 + g134_1 + g134_2 + g134_3)*1.22 if (e30>2 & e30<14)
	
gen monto_afam_cont= 311.04*(g151_1 + g151_2 + g151_3) if (suma_jefe <= 11664 | suma_cony <= 11664 | suma_otro <= 11664) & afam_cont==1
	replace monto_afam_cont= 155.52*(g151_1 + g151_2 + g151_3) if (suma_jefe>11664 | suma_cony >11664 | suma_otro>11664) & afam_cont==1

*gen monto_afam_cont=afam if afam_cont==1
recode monto_afam_cont .=0
*-------------------------------------------------------------------------------
* TUS
* No hay forma de asignar TUS, por lo que se utiliza el monto declarado.
gen monto_tus_iecon=h157_1
replace monto_tus_iecon=0 if bc_nper!=1
/*
gen menores= 1  if e27<18
recode menores .=0
bys bc_correlat: egen n_menores=sum(menores)

gen monto_tus_iecon = 0
by bc_correlat: replace monto_tus_iecon = 435 if (n_menores==1 | n_menores==0) & bc_mes<7   & h157==1
by bc_correlat: replace monto_tus_iecon = 479 if (n_menores==1 | n_menores==0) & bc_mes>6   & h157==1

by bc_correlat: replace monto_tus_iecon = 660 if (n_menores==2) & bc_mes<7   & h157==1
by bc_correlat: replace monto_tus_iecon = 726 if (n_menores==2) & bc_mes>6   & h157==1

by bc_correlat: replace monto_tus_iecon = 840 if (n_menores==3) & bc_mes<7   & h157==1
by bc_correlat: replace monto_tus_iecon = 924 if (n_menores==3) & bc_mes>6   & h157==1

by bc_correlat: replace monto_tus_iecon = 1170 if (n_menores>3) & bc_mes<7   & h157==1
by bc_correlat: replace monto_tus_iecon = 1287 if (n_menores>3) & bc_mes>6   & h157==1


replace monto_tus_iecon = 0 if bc_nper!=1
*/
*-------------------------------------------------------------------------------
* Vector salud. Código Iecon

*- Cuota otro hogar
gen     cuota_otrohog =mto_cuot if ((e45_1_1==6)&(e45_2==2|e45_2_1==2)&(e45_3==2|e45_3_1==2))
replace cuota_otrohog =mto_cuot if ((e45_2_1==3)&(e45_1==2|e45_1_1==2|e45_1_1==3)&(e45_3==2|e45_3_1==2))
replace cuota_otrohog =mto_cuot if ((e45_3_1==3)&(e45_1==2|e45_1_1==2|e45_1_1==3)&(e45_2==2|e45_2_1==2))
replace cuota_otrohog =0        if bc_pe4==7
recode  cuota_otrohog .=0
cap drop cuota_otrohog_h
egen cuota_otrohog_h=sum(cuota_otrohog), by(bc_correlat)

gen fonasa = ytdop_3 + ytdos_3 + YTINDE_2 // Se suman cuotas mutuales por fonasa ($)
gen salud = fonasa + ytdos_2 +ytdop_2  // A fonasa, se le suman cuotas mutuales militar ($)

bys bc_correlat: egen saludh= sum(salud)
replace saludh=saludh+totfonasa_hogar2+cuotmilit_hogar // Dejo afuera cuota_otrohog_h 26/11/2018
 