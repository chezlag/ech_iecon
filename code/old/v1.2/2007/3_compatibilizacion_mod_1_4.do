
g bc_correlat = numero
gen bc_nper= nper

g bc_area=-15  
replace bc_area=1 if region_4==1 // Montevideo
replace bc_area=2 if region_4==2 // Interior mayores de 5000
replace bc_area=3 if region_4==3 // Interior menores de 5000
replace bc_area=4 if region_4==4 // rurales - rural dispersa

cap drop bc_filtloc
g bc_filtloc=(region_4<3) // localidades de más de 5000 
recode bc_filtloc (0=2)
*-------------------------------------------------------------------------------
* 1- Características generales y de las personas

* sexo
cap drop bc_pe2
g bc_pe2=e27

* edad
cap drop bc_pe3
g bc_pe3=e28

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if e32==1
	replace bc_pe4=2 if e32==2
	replace bc_pe4=3 if e32==3|e32==4| e32==5
	replace bc_pe4=4 if e32==7|e32==8
	replace bc_pe4=5 if e32==6|e32==9|e32==10|e32==11|e32==12 
	replace bc_pe4=6 if e32==13
	replace bc_pe4=7 if e32==14

* estado civil
g bc_pe5=-9
	replace bc_pe5=1 if e39==2
	replace bc_pe5=2 if e39==1
	replace bc_pe5=3 if e39==0&(e40==1|e40==2)
	replace bc_pe5=4 if e39==0&(e40==3)
	replace bc_pe5=5 if e39==0&(e40==4)


*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-15
	replace bc_pe6a=2 if e43_7==1&e45_1!=3
	replace bc_pe6a=3 if e43_7==1&e45_1==3
	replace bc_pe6a=4 if (e43_1==1|e43_2==1|e43_3==1|e43_4==1|e43_5==1|e43_6==1)&(e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1)
	replace bc_pe6a=5 if (e43_8==1|e43_9==1|e43_10==1|e47==1)&e43_7!=1
	replace bc_pe6a=1 if e43_1!=1&e43_2!=1&e43_3!=1&e43_4!=1&e43_5!=1&e43_6!=1&e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1
	
g bc_pe6a1=-15
	replace bc_pe6a1=1 if bc_pe6a==3 & ((pobpcoac==2 & (f85==1|f99==1)) | pobpcoac==5)
	replace bc_pe6a1=2 if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=-9 if bc_pe6a!=3
	
recode bc_pe6a (2/3=2) (4=3) (5=4), gen(bc_pe6b)
replace bc_pe6b=-9 if bc_pe6a==3
*-------------------------------------------------------------------------------
* 3- Educación

*asiste
recode e50 (.=-15), g(bc_pe11)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
recode e53 (0 =-9), g(bc_pe12)
	replace bc_pe12=-15 if bc_pe11==-15&bc_pe12==-9
	replace bc_pe12=-9 if bc_pe11==1
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.

*asistencia actual pco o privada
/*
recode e51 (0 =-9), g(bc_pe13)
	replace bc_pe13=-15 if bc_pe11==-15&bc_pe12==-15
*/
gen bc_pe13=-13
	
*nivel 
g bc_nivel=-13
g nivel_aux=-15

 replace nivel_aux=0 if bc_pe11==0 & bc_pe12==0 // nunca asistió
 replace nivel_aux=0 if (e50==2&e53==2) | (e50==1&e53==0&e52_1>0)
 replace nivel_aux=1 if (e50==1&e53==0&(e52_2>0|e52_3>0)) | ((e50==2&e53==1)&e54_1_1>0&e54_1_1!=.)
 replace nivel_aux=2 if (e50==1&e53==0&(e52_4>0|e52_5>0|e52_6>0|e52_8>0)) | ((e50==2&e53==1)&e54_2_1>0&e54_2_1!=.)
 replace nivel_aux=3 if (e50==1&e53==0&(e52_7>0)) | ((e50==2&e53==1)&e54_3_1>0&e54_3_1!=.) 
 replace nivel_aux=4 if (e50==1&e53==0&(e52_9>0)) | ((e50==2&e53==1)&e54_4_1>0&e54_4_1!=.)
 replace nivel_aux=5 if (e50==1&e53==0&(e52_10>0|e52_11>0|e52_12>0)) | ((e50==2&e53==1)&((e54_5_1>0&e54_5_1!=.)|(e54_6_1>0&e54_6_1!=.)|(e54_7_1>0&e54_7_1!=.)))

* Modifico años cursados para los que cursan actualmente
forvalues i=2/12 {
g e52_`i'm = e52_`i'-1 
 replace e52_`i'm = 0 if e52_`i'==0
}

*años de bc_educación
g bc_edu=-15

*Primaria
 replace bc_edu=0 if nivel_aux==0
 replace bc_edu=e52_2m+e52_3m if nivel_aux==1 & (e50==1&e53==0) //esto se puede hacer para 2007
 replace bc_edu=e54_1_1 if nivel_aux==1 & (e50==2&e53==1)

*Secundaria
 replace bc_edu=6+e52_4m+e52_5m+e52_6m+e52_8m if nivel_aux==2 & (e50==1&e53==0) //esto se puede hacer para 2007
 replace bc_edu=6+e54_2_1 if nivel_aux==2 & (e50==2&e53==1)
 
* UTU 
 replace bc_edu=6+e52_7m if nivel_aux==3 & (e50==1&e53==0) 
 replace bc_edu=6+e54_3_1 if nivel_aux==3 & (e50==2&e53==1) 

*Magisterio
 replace bc_edu=12+e52_9m if nivel_aux==4 & (e50==1&e53==0)
 replace bc_edu=12+e54_4_1 if nivel_aux==4 & (e50==2&e53==1) 

*Terciaria
 replace bc_edu=12+e52_10m+e52_11m if nivel_aux==5 & (e50==1&e53==0) & e52_12m==0
 replace bc_edu=17+e52_12m if nivel_aux==5 & (e50==1&e53==0) & e52_12>0 & e52_12!=. //para los posgrados asumo 12+5
 replace bc_edu=12+e54_5_1+e54_6_1 if nivel_aux==5 & (e50==2&e53==1) & e54_7_1==0
 replace bc_edu=17+e54_7_1 if nivel_aux==5 & (e50==2&e53==1) & e54_7_1>0 & e54_7_1!=. //para los posgrados asumo 12+5

recode bc_edu 23/38=22

drop e52_2m-e52_12m

*finalizó
g bc_finalizo=-13

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad
g bc_pobp = pobpcoac
recode bc_pobp (10=9)

* Categoría de ocupación
g bc_pf41=f75
	replace bc_pf41=7 if f75==8
	replace bc_pf41=-9 if f75==0

g bc_cat2=-9
	replace bc_cat2=1 if f75==1
	replace bc_cat2=2 if f75==2
	replace bc_cat2=3 if f75==4
	replace bc_cat2=4 if f75==5|f75==6
	replace bc_cat2=5 if f75==3|f75==7|f75==8

* Tamaño del establecimiento
cap drop bc_pf081
g bc_pf081=-9
	replace bc_pf081=1 if f80>=1 & f80<=3
	replace bc_pf081=2 if f80>3

g bc_pf082=-9
	replace bc_pf082=1 if f80==1
	replace bc_pf082=2 if f80==2
	replace bc_pf082=3 if f80==3

* Rama del establecimiento
cap drop pf40 
g f74_2a=f74_2
	replace f74_2a="0111" if f74_2=="111"
	replace f74_2a="0112" if f74_2=="112"
	replace f74_2a="0121" if f74_2=="121"
	replace f74_2a="0122" if f74_2=="122"
	replace f74_2a="0123" if f74_2=="123"
	replace f74_2a="0140" if f74_2=="140"
destring f74_2a, replace
g bc_pf40=f74_2a

g bc_rama=-9
g ram_aux=trunc(f74_2a/100) 
	replace bc_rama=1 if ram_aux>0 &ram_aux<=14&bc_pobp==2 // ciu3
	replace bc_rama=2 if ram_aux>14&ram_aux<40&bc_pobp==2 
	replace bc_rama=3 if ram_aux>39&ram_aux<42&bc_pobp==2
	replace bc_rama=4 if ram_aux==45& bc_pobp==2
	replace bc_rama=5 if ram_aux>45&ram_aux<=55&bc_pobp==2 
	replace bc_rama=6 if ram_aux>55&ram_aux<=64&bc_pobp==2 
	replace bc_rama=7 if ram_aux>64&ram_aux<75&bc_pobp==2
	replace bc_rama=8 if ram_aux>74&ram_aux!=.&bc_pobp==2
drop ram_aux f74_2a

* Tipo de ocupación
cap drop pf39
g f73_2a=f73_2
destring f73_2a, replace
g bc_pf39=f73_2a
drop f73_2a

	replace bc_pf39=-9 if bc_pf39==.&bc_pobp!=2
	replace bc_pf39=-15 if bc_pf39==.&bc_pobp==2
	
cap drop pf39aux
g pf39aux=bc_pf39
	replace pf39aux=0 if bc_pf39>0 & bc_pf39<130

cap drop bc_tipo_ocup
g bc_tipo_ocup=trunc(pf39aux/1000)
	replace bc_tipo_ocup=-9 if bc_tipo_ocup==0&bc_pobp!=2
drop pf39aux

* Cantidad de empleos
g bc_pf07=f72
recode bc_pf07 (0=-9)

* Horas trabajadas
g bc_horas_hab=f88+f101  // horas semanales trabajadas habitualmente en total
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f88    // horas semanales trabajadas habitualmente en trabajo principal
recode bc_horas_hab_1 (0=-9)

g bc_horas_sp=-13 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=-13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
g bc_pf04=f71
recode bc_pf04 (3=4) (4=3) (0=-9)

* Busqueda de trabajo
g bc_pf21= f110 // buscó trabajo la semana pasada
recode bc_pf21 (0=-9)

g bc_pf22=f111 // causa por la que no buscó trabajo
recode bc_pf22 (1=4) (2=1) (3=2) (4=3) (5=4) (0=-9)

* Duración desempleo (semanas)
g bc_pf26=f116
replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

g bc_pf34a=f125 // causas por las que dejó último trabajo
recode bc_pf34 (1=2) (2=1) (4/9=3) (0=-9)

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo'
	replace bc_reg_disse=1 if (e45_1==3|bc_pf41==2)&bc_pobp==2
	replace bc_reg_disse=2 if (e45_1!=3&bc_pf41!=2)&bc_pobp==2

g bc_register=-9
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2&f85==1

g bc_register2=-9
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2&(f85==1|f99==1)

* Subocupado
g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if f105==1&f107==4&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=. 

g bc_subocupado1=-9
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f104==2|f105==1)&f106==1&f107==4&f108!=6&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=. 

*-------------------------------------------------------------------------------
* ipc
cap drop ipc
g bc_ipc=-15
	replace	bc_ipc=	1.00000000	if	bc_mes==	1	&	bc_anio==	2007
	replace	bc_ipc=	0.98258326	if	bc_mes==	2	&	bc_anio==	2007
	replace	bc_ipc=	0.97661504	if	bc_mes==	3	&	bc_anio==	2007
	replace	bc_ipc=	0.96792226	if	bc_mes==	4	&	bc_anio==	2007
	replace	bc_ipc=	0.95624469	if	bc_mes==	5	&	bc_anio==	2007
	replace	bc_ipc=	0.94902821	if	bc_mes==	6	&	bc_anio==	2007
	replace	bc_ipc=	0.94774957	if	bc_mes==	7	&	bc_anio==	2007
	replace	bc_ipc=	0.93999248	if	bc_mes==	8	&	bc_anio==	2007
	replace	bc_ipc=	0.92401790	if	bc_mes==	9	&	bc_anio==	2007
	replace	bc_ipc=	0.92020276	if	bc_mes==	10	&	bc_anio==	2007
	replace	bc_ipc=	0.92231419	if	bc_mes==	11	&	bc_anio==	2007
	replace	bc_ipc=	0.92443532	if	bc_mes==	12	&	bc_anio==	2007

g bc_ipc_nuevo=bc_ipc
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* Drop servicio doméstico
preserve 
keep if bc_pe4==7
save "$rutainterm/servdom7",replace
restore
drop if bc_pe4==7
