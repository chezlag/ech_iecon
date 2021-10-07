*-------------------------------------------------------------------------------
* Variables de identificación general
rename numero bc_correlat
rename nper bc_nper
rename pesoano bc_pesoan
g bc_area=.
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
g bc_pe2=e27

* edad
g bc_pe3=e28

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if e32==1
	replace bc_pe4=2 if e32==2
	replace bc_pe4=3 if e32==3 | e32==4 | e32==5
	replace bc_pe4=4 if e32==7 | e32==8
	replace bc_pe4=5 if e32==6 | e32==9 | e32==10 | e32==11 | e32==12
	replace bc_pe4=6 if e32==13
	replace bc_pe4=7 if e32==14


* estado civil
g bc_pe5=-9
	replace bc_pe5=1 if e39==2
	replace bc_pe5=2 if e39==1
	replace bc_pe5=3 if e39==0 & (e40==1|e40==2 |e40==5 )
	replace bc_pe5=4 if e39==0 & (e40==3)
	replace bc_pe5=5 if e39==0 & (e40==4)

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
recode e50 (0 =-15), g(bc_pe11) 
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
recode e51 (0 =-9), g(bc_pe12)
	replace bc_pe12=-15 if bc_pe11==-15&bc_pe12==-9
	replace bc_pe12=-9 if bc_pe11==1
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.

*asistencia actual pco o privada
/*
recode e54 (0 =-9), g(bc_pe13)
	replace bc_pe13=-15 if bc_pe11==-15&bc_pe12==-15
*/
gen bc_pe13=-13

*nivel sin exigencia
gen bc_nivel=-13
gen nivel_aux=-15

replace nivel_aux=0 if bc_pe11==2 & bc_pe12==2
replace nivel_aux=0 if bc_pe11==1 & e52_1_v!=0 & e52_2_v==0 & e52_3_v==0 & e52_4_v==0 & e52_5_v==0 & e52_6_v==0 & e52_7_v==0 /*
*/ & e52_8_v==0 & e52_9_v==0 & e52_10_v==0 & e52_11_v==0 & e52_12_v==0 & bc_dpto!=1 & bc_mes==1
replace nivel_aux=0 if ((e52_2==0 & e52_3==0)| (e52_1>0 & e52_1<6 & e52_2==9))  & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1)) 

replace nivel_aux=1 if bc_pe11==1 & (e52_2_v>0 | e52_3_v>0) & e52_1_v==0 & e52_4_v==0 & e52_5_v==0 & e52_6_v==0 & e52_7_v==0 /*
*/ & e52_8_v==0 & e52_9_v==0 & e52_10_v==0 & e52_11_v==0 & e52_12_v==0  & bc_dpto!=1 & bc_mes==1
replace nivel_aux=1  if ((((e52_2>0 & e52_2<=6) | (e52_3>0 & e52_3<=6 ) /*
*/ &  e52_4==0) | (e52_2==6 & e52_4==9))  & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1))) 
replace nivel_aux=1 if bc_pe11==2 &  bc_pe12==1 & e54_1_1!=0  & e54_2_1==0 &  e54_3_1==0 & e54_4_1==0 & e54_5_1==0 &  e54_6_1==0 /*
*/  & e54_7_1==0 & bc_dpto!=1 & bc_mes==1

replace nivel_aux=2 if bc_pe11==1 & (e52_4_v!=0 |e52_6_v!=0) & e52_1_v==0  & e52_2_v==0 & e52_3_v==0 & e52_5_v==0 & e52_7_v==0 /*
*/ & e52_8_v==0 & e52_9_v==0 & e52_10_v==0 & e52_11_v==0 & e52_12_v==0 & bc_dpto!=1 & bc_mes==1
replace nivel_aux=2  if  ((((e52_4>0 & e52_4<=3)| (e52_5>0 & e52_5<=3)|(e52_6>0 & e52_4<=6)) & (e52_7_1==0 & e52_8==0 & e52_9==0 & e52_10==0)) /*
*/ | (e52_7_1!=0 & e52_7_2==3) | (e52_4==3 & e52_8==9) | (e52_5==3 & e52_8==9)) & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1))
replace nivel_aux=2 if bc_pe11==2 &  bc_pe12==1 & e54_2_1!=0  &  e54_1_1==0  & e54_3_1==0  & e54_4_1==0 &  e54_5_1==0 & e54_6_1==0 /*
*/  & e54_7_1==0 & bc_dpto!=1 & bc_mes==1

replace nivel_aux=3 if bc_pe11==1 & (e52_5_v!=0 |e52_7_v!=0 |e52_8_v!=0) & e52_1_v==0  & e52_2_v==0 & e52_3_v==0 & e52_4_v==0 /*
*/ & e52_6_v==0 & e52_9_v==0 & e52_10_v==0 & e52_11_v==0 & e52_12_v==0 & bc_dpto!=1 & bc_mes==1
replace nivel_aux=3 if bc_pe11==2 &  bc_pe12==1 & e54_3_1!=0  & e54_1_1==0 & e54_2_1==0 & e54_4_1==0 &  e54_5_1==0 & e54_6_1==0 /*
*/ & e54_7_1==0  & bc_dpto!=1 & bc_mes==1
replace nivel_aux=3  if  ((e52_7_1>0 &  e52_7_1<=9) | (e52_7_1!=0 & e52_4==0 & e52_5==0 & e52_6==0)) /*
*/ & e52_8==0 & e52_9==0 & e52_10==0 & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1))

replace nivel_aux=4 if bc_pe11==1 &  e52_9_v!=0 & e52_1_v==0  & e52_2_v==0 & e52_3_v==0 & e52_4_v==0 & e52_5_v==0 & e52_6_v==0 /*
*/ & e52_7_v==0 & e52_8_v==0 & e52_10_v==0 & e52_11_v==0 & e52_12_v==0   & bc_dpto!=1 & bc_mes==1
replace nivel_aux=4  if (e52_8>0 & e52_8<=5) &  e52_9==0 &  e52_10==0 &  e52_11==0 & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1)) 
replace nivel_aux=4 if bc_pe11==2 &  bc_pe12==1 & e54_4_1>0 & e54_5_1==0 & e54_7_1==0 & bc_dpto!=1 & bc_mes==1

replace nivel_aux=5 if bc_pe11==1 & (e52_10_v!=0  | e52_11_v!=0 | e52_12_v!=0) & e52_1_v==0  & e52_2_v==0 & e52_3_v==0 & /*
*/ e52_4_v==0 & e52_5_v==0 & e52_6_v==0 & e52_7_v==0 & e52_8_v==0 & e52_9_v==0 & bc_dpto!=1 & bc_mes==1
replace nivel_aux=5  if ((e52_9>0 & e52_9<=9) | (e52_10>0 & e52_10<=9) | (e52_11>0 & e52_11<=9)) & (bc_dpto==1|(bc_dpto!=1 & bc_mes>1)) 
replace nivel_aux=5 if bc_pe11==2 &  bc_pe12==1 & (e54_5_1>0 | e54_6_1>0 | e54_7_1>0 ) & bc_dpto!=1 & bc_mes==1

replace nivel_aux=0 if nivel_aux==-15 & (e52_2==9 | e52_3==9)

*años de bc_educación sin exigencia
gen bc_edu=-15

*Primaria
replace bc_edu=0 if nivel_aux==0
replace bc_edu= e52_2 if nivel_aux==1 & ((e52_2>=e52_3 & e52_2!=9) | (e52_2>0 & e52_2!=9 & e52_3==9))
replace bc_edu= e52_3 if nivel_aux==1 & ((e52_3>e52_2 & e52_3!=9)  | (e52_3>0 & e52_3!=9 & e52_2==9))
replace bc_edu= e54_1_1 if nivel_aux==1 & e54_1_1!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==2 &  bc_pe12==1
replace bc_edu= 6 if e52_2_v>6 & bc_dpto!=1 & bc_mes==1 & nivel_aux==1  & bc_pe11==1
replace bc_edu= (e52_2_v-1) if  nivel_aux==1 & e52_2_v!=0  & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu= (e52_3_v-1) if nivel_aux==1 & e52_2_v==0 & e52_3_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1

*Secundaria
replace bc_edu=6+e52_4 if nivel_aux==2 & e52_4<=3 & e52_4>0
replace bc_edu=9+e52_5 if nivel_aux==2 & e52_4==3 & e52_5<9 & e52_5>0
replace bc_edu=9+e52_6 if nivel_aux==2 & e52_4==3 & e52_6<9 &  e52_6>0
replace bc_edu=9 if nivel_aux==2 & e52_4>0 &  e52_5==0 & e52_6==0  & e53_2==1
replace bc_edu=9 if nivel_aux==2 & e52_4==3 & e52_5==9
replace bc_edu=12 if nivel_aux==2 & e52_4==3 & e52_5==9 & e53_2==1
replace bc_edu=9 if nivel_aux==2 & e52_4==3 & e52_6==9
replace bc_edu=12 if nivel_aux==2 & e52_4==3 & e52_6==9 & e53_2==1
replace bc_edu=6 if nivel_aux==2 & e52_4==9 
replace bc_edu=9 if nivel_aux==2 & e52_4==9 & e53_2==1
replace bc_edu=(e52_4_v+5) if nivel_aux==2 & e52_4_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=(e52_6_v+5) if nivel_aux==2 & e52_6_v!=0  & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=6+e54_2_1 if nivel_aux==2 & e54_2_1!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==2 &  bc_pe12==1
replace bc_edu=9+e52_5 if bc_edu==-15 & nivel_aux==2  & e52_5!=0
replace bc_edu=9+e52_6 if bc_edu==-15 & nivel_aux==2 

*UTU actual
replace bc_edu=6+e52_7_1 if nivel_aux==3 & e52_7_1<9 & e52_7_1>0
replace bc_edu=(e52_5_v+5) if nivel_aux==3 & e52_5_v!=0 & bc_dpto!=1 & bc_mes==1  & bc_pe11==1
replace bc_edu=(e52_7_v+5) if nivel_aux==3 & e52_7_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=(e52_8_v+5) if nivel_aux==3  & e52_8_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=6+e54_3_1 if nivel_aux==3  & bc_pe11==2  & e54_3_1!=0 & bc_dpto!=1 & bc_mes==1  & bc_pe11==2 &  bc_pe12==1
recode e52_4 (9 =0), g(auxed1)
recode e52_5 (9 =0), g(auxed2)
replace bc_edu=6+ max(auxed1, auxed2) if bc_edu==-15 &  e52_7_1==9
drop auxed*
*magisterio
replace bc_edu=e52_8+12 if nivel_aux==4 & e52_8<9  &  e52_8>0
replace bc_edu=12 if nivel_aux==4 & e52_8==9
replace bc_edu=15 if nivel_aux==4 & e52_8==9 & e53_2==1
replace bc_edu=(e52_9_v+11) if nivel_aux==4 & e52_9_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=12+e54_4_1 if nivel_aux==4 & e54_4_1!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==2 &  bc_pe12==1

*Terciaria
replace bc_edu=e52_9+12 if nivel_aux==5 & e52_9<9  &  e52_9>0
replace bc_edu=e52_10+12 if nivel_aux==5 & e52_10<9  &  e52_10>0
replace bc_edu=e52_11+12+e52_9 if nivel_aux==5 & e52_11<9 & e52_11>0 & e52_9>=e52_10 
replace bc_edu=e52_11+12+e52_10 if nivel_aux==5 & e52_11<9 & e52_11>0 & e52_9<e52_10
replace bc_edu=12 if nivel_aux==5 & e52_9==9
replace bc_edu=12 if nivel_aux==5 & e52_10==9
replace bc_edu=15 if nivel_aux==5 & e52_9==9 & e53_2==1
replace bc_edu=16 if nivel_aux==5 & e52_10==9 & e53_2==1
replace bc_edu=12+e52_9 if nivel_aux==5 & e52_11==9  & e52_9>=e52_10
replace bc_edu=12+e52_10 if nivel_aux==5 & e52_11==9  & e52_9<e52_10 
replace bc_edu=(e52_10_v+11) if nivel_aux==5 & e52_10_v!=0  & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=17 if e52_10_v>5 & nivel_aux==5 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=12+e54_5_1 if nivel_aux==5 & bc_pe11==2 & e54_5_1!=0 & bc_dpto!=1 & bc_mes==1  & bc_pe11==2 &  bc_pe12==1
replace bc_edu=(e52_11_v+11) if nivel_aux==5  & e52_11_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=17 if e52_11_v>5 & nivel_aux==5 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=12+e54_6_1 if nivel_aux==5 & bc_pe11==2 & e54_6_1!=0 & bc_dpto!=1 & bc_mes==1  & bc_pe11==2 &  bc_pe12==1
replace bc_edu=(e52_12_v+16) if nivel_aux==5  & e52_12_v!=0 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=22 if e52_12_v>5 & nivel_aux==5 & bc_dpto!=1 & bc_mes==1 & bc_pe11==1
replace bc_edu=17+e54_7_1 if nivel_aux==5 & bc_pe11==2 & e54_7_1!=0 & bc_dpto!=1 & bc_mes==1  & bc_pe11==2 &  bc_pe12==1

recode bc_edu 23/38=22

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
g bc_pf081=-9
	replace bc_pf081=1 if (f80==1 | f80==2 | f80==3) //tamaño chico
	replace bc_pf081=2 if (f80==4 | f80==5) //tamaño grande

g bc_pf082=-9
	replace bc_pf082=1 if f80==1
	replace bc_pf082=2 if f80==2
	replace bc_pf082=3 if f80==3

* Rama del establecimiento (en 2011 se utiliza ciiu rev 3)
destring f74_2, replace
g bc_pf40=f74_2

gen bc_rama=-9
gen ram_aux=.
replace ram_aux=trunc(f74_2/100) 
replace bc_rama=1 if ram_aux>0 & ram_aux<=14 & pobp==2 // ciu3
replace bc_rama=2 if ram_aux>14 & ram_aux<40 & pobp==2
replace bc_rama=3 if ram_aux>39 & ram_aux<42 & pobp==2
replace bc_rama=4 if ram_aux==45 & pobp==2
replace bc_rama=5 if ram_aux>45 & ram_aux<=55 & pobp==2 
replace bc_rama=6 if ram_aux>55 & ram_aux<=64 & pobp==2 
replace bc_rama=7 if ram_aux>64 & ram_aux<75 & pobp==2
replace bc_rama=8 if ram_aux>74 & ram_aux!=. & pobp==2
drop ram_aux

* Tipo de ocupación 
destring f73_2, replace
g bc_pf39=f73_2
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
g bc_horas_hab=f88_1+f101 // horas semanales trabajadas habitualmente en total
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f88_1   // horas semanales trabajadas habitualmente en trabajo principal
recode bc_horas_hab_1 (0=-9)

g bc_horas_sp=-13 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=-13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
g bc_pf04=f71
recode bc_pf04 (3=4) (4=3) (5/6=4) (0=-9)

* Busqueda de trabajo
g bc_pf21= f110 // buscó trabajo la semana pasada
recode bc_pf21 (0=-9)

g bc_pf22=f111 // causa por la que no buscó trabajo
recode bc_pf22 (1=4) (2=1) (3=2) (4=3) (5/6=4) (0=-9)

* Duración desempleo (semanas)
g bc_pf26=f108
replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

g bc_pf34=f125 // causas por las que dejó último trabajo
recode bc_pf34 (1=2) (2=1) (4/9=3) (0=-9) 

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo'
	replace bc_reg_disse=1 if (e45_1==3 | bc_pf41==2) & pobp==2
	replace bc_reg_disse=2 if (e45_1!=3 & bc_pf41!=2) & pobp==2

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

cap drop bc_ipc
g bc_ipc=.
replace	bc_ipc=	0.92163446	if	bc_mes==	1	&	bc_anio==	2008
replace	bc_ipc=	0.91452019	if	bc_mes==	2	&	bc_anio==	2008
replace	bc_ipc=	0.90623616	if	bc_mes==	3	&	bc_anio==	2008
replace	bc_ipc=	0.89599172	if	bc_mes==	4	&	bc_anio==	2008
replace	bc_ipc=	0.89304134	if	bc_mes==	5	&	bc_anio==	2008
replace	bc_ipc=	0.88531425	if	bc_mes==	6	&	bc_anio==	2008
replace	bc_ipc=	0.87410687	if	bc_mes==	7	&	bc_anio==	2008
replace	bc_ipc=	0.87022074	if	bc_mes==	8	&	bc_anio==	2008
replace	bc_ipc=	0.86146192	if	bc_mes==	9	&	bc_anio==	2008
replace	bc_ipc=	0.85631681	if	bc_mes==	10	&	bc_anio==	2008
replace	bc_ipc=	0.85349208	if	bc_mes==	11	&	bc_anio==	2008
replace	bc_ipc=	0.85190384	if	bc_mes==	12	&	bc_anio==	2008
replace bc_ipc=	0.844051146	if  bc_mes==	1	& 	bc_anio==	2009
replace bc_ipc=	0.837425595	if  bc_mes==	2	& 	bc_anio==	2009
replace bc_ipc=	0.839674724	if  bc_mes==	3	& 	bc_anio==	2009
replace bc_ipc=	0.833271637	if  bc_mes==	4	& 	bc_anio==	2009
replace bc_ipc=	0.83361108	if  bc_mes==	5	& 	bc_anio==	2009
replace bc_ipc=	0.830229041	if  bc_mes==	6	& 	bc_anio==	2009
replace bc_ipc=	0.820903687	if  bc_mes==	7	& 	bc_anio==	2009
replace bc_ipc=	0.812870143	if  bc_mes==	8	& 	bc_anio==	2009
replace bc_ipc=	0.8029822	if  bc_mes==	9	& 	bc_anio==	2009
replace bc_ipc=	0.801124635	if  bc_mes==	10	& 	bc_anio==	2009
replace bc_ipc=	0.80121018	if  bc_mes==	11	& 	bc_anio==	2009
replace bc_ipc=	0.800754153	if  bc_mes==	12	& 	bc_anio==	2009
replace bc_ipc=	0.797011649	if  bc_mes==	1	& 	bc_anio==	2010
replace bc_ipc=	0.789630617	if  bc_mes==	2	& 	bc_anio==	2010
replace bc_ipc=	0.78525082	if  bc_mes==	3	& 	bc_anio==	2010
replace bc_ipc=	0.777869929	if  bc_mes==	4	& 	bc_anio==	2010
replace bc_ipc=	0.776501432	if  bc_mes==	5	& 	bc_anio==	2010
replace bc_ipc=	0.775271224	if  bc_mes==	6	& 	bc_anio==	2010
replace bc_ipc=	0.773087887	if  bc_mes==	7	& 	bc_anio==	2010
replace bc_ipc=	0.764787823	if  bc_mes==	8	& 	bc_anio==	2010
replace bc_ipc=	0.755749538	if  bc_mes==	9	& 	bc_anio==	2010
replace bc_ipc=	0.753498025	if  bc_mes==	10	& 	bc_anio==	2010
replace bc_ipc=	0.748686224	if  bc_mes==	11	& 	bc_anio==	2010
replace bc_ipc=	0.749259395	if  bc_mes==	12	& 	bc_anio==	2010
replace	bc_ipc=	0.74533956	if	bc_mes==	1	&	bc_anio==	2011
replace	bc_ipc=	0.73642877	if	bc_mes==	2	&	bc_anio==	2011
replace	bc_ipc=	0.72958062	if	bc_mes==	3	&	bc_anio==	2011
replace	bc_ipc=	0.71943973	if	bc_mes==	4	&	bc_anio==	2011
replace	bc_ipc=	0.71646598	if	bc_mes==	5	&	bc_anio==	2011
replace	bc_ipc=	0.71365335	if	bc_mes==	6	&	bc_anio==	2011
replace	bc_ipc=	0.71025306	if	bc_mes==	7	&	bc_anio==	2011
replace	bc_ipc=	0.70507952	if	bc_mes==	8	&	bc_anio==	2011
replace	bc_ipc=	0.70063880	if	bc_mes==	9	&	bc_anio==	2011
replace	bc_ipc=	0.69696985	if	bc_mes==	10	&	bc_anio==	2011
replace	bc_ipc=	0.69173045	if	bc_mes==	11	&	bc_anio==	2011
replace	bc_ipc=	0.68917204	if	bc_mes==	12	&	bc_anio==	2011
replace	bc_ipc=	0.68417437	if	bc_mes==	1	&	bc_anio==	2012
replace	bc_ipc=	0.67955831	if	bc_mes==	2	&	bc_anio==	2012
replace	bc_ipc=	0.67305360	if	bc_mes==	3	&	bc_anio==	2012
replace	bc_ipc=	0.66685117	if	bc_mes==	4	&	bc_anio==	2012
replace	bc_ipc=	0.66181811	if	bc_mes==	5	&	bc_anio==	2012
replace	bc_ipc=	0.65918419	if	bc_mes==	6	&	bc_anio==	2012
replace	bc_ipc=	0.65651331	if	bc_mes==	7	&	bc_anio==	2012
replace	bc_ipc=	0.65386399	if	bc_mes==	8	&	bc_anio==	2012
replace	bc_ipc=	0.64783969	if	bc_mes==	9	&	bc_anio==	2012
replace	bc_ipc=	0.64010611	if	bc_mes==	10	&	bc_anio==	2012
replace	bc_ipc=	0.63319986	if	bc_mes==	11	&	bc_anio==	2012
replace	bc_ipc=	0.63137616	if	bc_mes==	12	&	bc_anio==	2012
replace	bc_ipc=	0.63530477	if	bc_mes==	1	&	bc_anio==	2013
replace	bc_ipc=	0.62418521	if	bc_mes==	2	&	bc_anio==	2013
replace	bc_ipc=	0.61797493	if	bc_mes==	3	&	bc_anio==	2013
replace	bc_ipc=	0.61425709	if	bc_mes==	4	&	bc_anio==	2013
replace	bc_ipc=	0.61148540	if	bc_mes==	5	&	bc_anio==	2013
replace	bc_ipc=	0.60888780	if	bc_mes==	6	&	bc_anio==	2013
replace	bc_ipc=	0.60557325	if	bc_mes==	7	&	bc_anio==	2013
replace	bc_ipc=	0.60045078	if	bc_mes==	8	&	bc_anio==	2013
replace	bc_ipc=	0.59489150	if	bc_mes==	9	&	bc_anio==	2013
replace	bc_ipc=	0.58748290	if	bc_mes==	10	&	bc_anio==	2013
replace	bc_ipc=	0.58170574	if	bc_mes==	11	&	bc_anio==	2013
replace	bc_ipc=	0.58075390	if	bc_mes==	12	&	bc_anio==	2013
replace	bc_ipc=	0.58357310	if	bc_mes==	1	&	bc_anio==	2014
replace	bc_ipc=	0.57070410	if	bc_mes==	2	&	bc_anio==	2014
replace	bc_ipc=	0.56218099	if	bc_mes==	3	&	bc_anio==	2014
replace	bc_ipc=	0.55880909	if	bc_mes==	4	&	bc_anio==	2014
replace	bc_ipc=	0.55922836	if	bc_mes==	5	&	bc_anio==	2014
replace	bc_ipc=	0.55693010	if	bc_mes==	6	&	bc_anio==	2014
replace	bc_ipc=	0.55427944	if	bc_mes==	7	&	bc_anio==	2014
replace	bc_ipc=	0.55010669	if	bc_mes==	8	&	bc_anio==	2014
replace	bc_ipc=	0.54643663	if	bc_mes==	9	&	bc_anio==	2014
replace	bc_ipc=	0.54108135	if	bc_mes==	10	&	bc_anio==	2014
replace	bc_ipc=	0.53749157	if	bc_mes==	11	&	bc_anio==	2014
replace	bc_ipc=	0.53671748	if	bc_mes==	12	&	bc_anio==	2014
replace	bc_ipc=	0.53846233	if	bc_mes==	1	&	bc_anio==	2015
replace	bc_ipc=	0.52789826	if	bc_mes==	2	&	bc_anio==	2015
replace	bc_ipc=	0.52154472	if	bc_mes==	3	&	bc_anio==	2015
replace	bc_ipc=	0.51813664	if	bc_mes==	4	&	bc_anio==	2015
replace	bc_ipc=	0.51530666	if	bc_mes==	5	&	bc_anio==	2015
replace	bc_ipc=	0.51261318	if	bc_mes==	6	&	bc_anio==	2015
replace	bc_ipc=	0.51008730	if	bc_mes==	7	&	bc_anio==	2015
replace	bc_ipc=	0.50374396	if	bc_mes==	8	&	bc_anio==	2015
replace	bc_ipc=	0.49855489	if	bc_mes==	9	&	bc_anio==	2015
replace	bc_ipc=	0.49448654	if	bc_mes==	10	&	bc_anio==	2015
replace	bc_ipc=	0.49125993	if	bc_mes==	11	&	bc_anio==	2015
replace	bc_ipc=	0.48913214	if	bc_mes==	12	&	bc_anio==	2015
replace	bc_ipc=	0.49119517	if	bc_mes==	1	&	bc_anio==	2016
replace	bc_ipc=	0.48015175	if	bc_mes==	2	&	bc_anio==	2016
replace	bc_ipc=	0.47218217	if	bc_mes==	3	&	bc_anio==	2016
replace	bc_ipc=	0.46726823	if	bc_mes==	4	&	bc_anio==	2016
replace	bc_ipc=	0.46508147	if	bc_mes==	5	&	bc_anio==	2016
replace	bc_ipc=	0.46113937	if	bc_mes==	6	&	bc_anio==	2016
replace	bc_ipc=	0.45937723	if	bc_mes==	7	&	bc_anio==	2016
replace	bc_ipc=	0.45740384	if	bc_mes==	8	&	bc_anio==	2016
replace	bc_ipc=	0.45469714	if	bc_mes==	9	&	bc_anio==	2016
replace	bc_ipc=	0.45347990	if	bc_mes==	10	&	bc_anio==	2016
replace	bc_ipc=	0.45276367	if	bc_mes==	11	&	bc_anio==	2016
replace	bc_ipc=	0.45215940	if	bc_mes==	12	&	bc_anio==	2016


g bc_ipc_nuevo=0
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* BPC

cap drop bpc
gen bpc=.
replace bpc = 3611 if bc_mes>1  & bc_anio==2017
replace bpc = 3340 if bc_mes==1 & bc_anio==2017
replace bpc = 3340 if bc_mes>1  & bc_anio==2016
replace bpc = 3052 if bc_mes==1 & bc_anio==2016
replace bpc = 3052 if bc_mes>1  & bc_anio==2015
replace bpc = 2819 if bc_mes==1 & bc_anio==2015
replace bpc = 2819 if bc_mes>1  & bc_anio==2014
replace bpc = 2598 if bc_mes==1 & bc_anio==2014
replace bpc = 2598 if bc_mes>1  & bc_anio==2013
replace bpc = 2417 if bc_mes==1 & bc_anio==2013
replace bpc = 2417 if bc_mes>1  & bc_anio==2012
replace bpc = 2226 if bc_mes==1 & bc_anio==2012
replace bpc = 2226 if bc_mes>1  & bc_anio==2011
replace bpc = 2061 if bc_mes==1 & bc_anio==2011
replace bpc = 2061 if bc_mes>1  & bc_anio==2010
replace bpc = 1944 if bc_mes==1 & bc_anio==2010
replace bpc = 1944 if bc_mes>1  & bc_anio==2009
replace bpc = 1775 if bc_mes==1 & bc_anio==2009
replace bpc = 1775 if bc_mes>1  & bc_anio==2008
replace bpc = 1636 if bc_mes==1 & bc_anio==2008
replace bpc = 1636 if bc_mes>1  & bc_anio==2007
replace bpc = 1482 if bc_mes==1 & bc_anio==2007
replace bpc = 1482 if bc_mes>1  & bc_anio==2006
replace bpc = 1397 if bc_mes==1 & bc_anio==2006

*-------------------------------------------------------------------------------
* Drop servicio doméstico
preserve
keep if e32==14
save "$rutainterm/servdom8",replace
restore
drop if e32==14
