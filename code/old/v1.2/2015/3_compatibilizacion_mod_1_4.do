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
g bc_filtloc=(region_4<3) // localidades de mÃ¡s de 5000 
recode bc_filtloc (0=2)

*-------------------------------------------------------------------------------
* 1- Características generales y de las personas

* sexo
g bc_pe2=e26

* edad
g bc_pe3=e27

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if e30==1
	replace bc_pe4=2 if e30==2
	replace bc_pe4=3 if e30==3 | e30==4 | e30==5
	replace bc_pe4=4 if e30==7 | e30==8
	replace bc_pe4=5 if e30==6 | e30==9 | e30==10 | e30==11 | e30==12
	replace bc_pe4=6 if e30==13
	replace bc_pe4=7 if e30==14


* estado civil
g bc_pe5=-9
	replace bc_pe5=1 if e35==2 | e35==3
	replace bc_pe5=2 if e35==1
	replace bc_pe5=3 if e35==0 & (e36==1 | e36==2 | e36==3)
	replace bc_pe5=4 if e35==0 & (e36==4 | e36==6)
	replace bc_pe5=5 if e35==0 & (e36==5)

*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-15
	replace bc_pe6a=4 if (e45_1==1 & (e45_1_1!=1 | e45_1_1!=4)) | e45_4==1 | e45_5==1 | e45_6==1
	replace bc_pe6a=2 if e45_2==1 & e45_2_1!=1 & e45_2_1!=6
	replace bc_pe6a=3 if (e45_1==1 & (e45_1_1==1 | e45_1_1==4)) | (e45_2==1 & (e45_2_1==1 |e45_2_1==6)) | (e45_3==1 & (e45_3_1==1 | e45_3_1 ==6))
	replace bc_pe6a=5 if ((e45_3==1 & (e45_3_1!=1 | e45_3_1!=6)) | e46==1) & bc_pe6a!=3
	replace bc_pe6a=1 if e45_1==2 & e45_2==2 & e45_3==2 & e45_4==2 & e45_5==2 & e45_6==2 & e46==2
	
g bc_pe6a1=-15
	replace bc_pe6a1=1 if bc_pe6a==3 & ((pobpcoac==2 & (f82==1|f96==1)) | pobpcoac==5)
	replace bc_pe6a1=2 if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=-9 if bc_pe6a!=3

recode bc_pe6a (2/3=2) (4=3) (5=4), gen(bc_pe6b)
replace bc_pe6b=-9 if bc_pe6a==3
*-------------------------------------------------------------------------------
* 3- Educación

*asiste
g bc_pe11=2 
	replace bc_pe11=1 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1)
	replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
g bc_pe12=e49
	replace bc_pe12=-9 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1)
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.
	
*asistencia actual pco o privada
g bc_pe13=-13

*nivel
g bc_nivel=-13
g nivel_aux=-15

replace nivel_aux=0 if bc_pe11==0 & bc_pe12==0 // nunca asistió
 
replace nivel_aux=0 if ((e51_2==0 & e51_3==0) | ((e193==1 | e193==2) & e51_2==9))  

replace nivel_aux=1  if ((((e51_2>0 & e51_2<=6) | (e51_3>0 & e51_3<=6)) &  e51_4==0) | (e51_2==6 & e51_4==9))  /* //Primaria */

replace nivel_aux=2  if  ((((e51_4>0 & e51_4<=3) | (e51_5>0 & e51_5<=3) | (e51_6>0 & e51_4<=6)) & (e51_7==0 & e51_8==0 & e51_9==0 & e51_10==0)) /* // Secundaria
*/ | (e51_7!=0 & e51_7_1==3) | (e51_4==3 & e51_8==9) | (e51_5==3 & e51_8==9)) 
 
replace nivel_aux=3  if  ((e51_7>0 &  e51_7<=9 & e51_7_1<3) | (e51_7!=0 & e51_4==0 & e51_5==0 & e51_6==0) /* // UTU
*/ & e51_8==0 & e51_9==0 & e51_10==0 )

replace nivel_aux=4  if (e51_8>0 & e51_8<=5) &  e51_9==0 &  e51_10==0 &  e51_11==0  // magisterio o profesorado

replace nivel_aux=5  if ((e51_9>0 & e51_9<=9) | (e51_10>0 & e51_10<=9) | (e51_11>0 & e51_11<=9)) // universidad o similar

replace nivel_aux=0 if nivel_aux==-15 & (e51_2==9 | e51_3==9)

*años de bc_educación
g bc_edu=-15

*Primaria
replace bc_edu=0 if nivel_aux==0
replace bc_edu= e51_2 if nivel_aux==1 & ((e51_2>=e51_3 & e51_2!=9) | (e51_2>0 & e51_2!=9 & e51_3==9))
replace bc_edu= e51_3 if nivel_aux==1 & ((e51_3>e51_2 & e51_3!=9)  | (e51_3>0 & e51_3!=9 & e51_2==9))

*Secundaria
replace bc_edu=6+e51_4 if nivel_aux==2 & e51_4<=3 & e51_4>0
replace bc_edu=9+e51_5 if nivel_aux==2 & e51_4==3 & e51_5<9 & e51_5>0
replace bc_edu=9+e51_6 if nivel_aux==2 & e51_4==3 & e51_6<9 &  e51_6>0
replace bc_edu=9 if nivel_aux==2 & e51_4>0 &  e51_5==0 & e51_6==0  & e201_1==1
replace bc_edu=9 if nivel_aux==2 & e51_4==3 & e51_5==9
replace bc_edu=12 if nivel_aux==2 & e51_4==3 & e51_5==9 & e212_1==1
replace bc_edu=9 if nivel_aux==2 & e51_4==3 & e51_6==9
replace bc_edu=12 if nivel_aux==2 & e51_4==3 & e51_6==9 & e212_1==1
replace bc_edu=6 if nivel_aux==2 & e51_4==9 
replace bc_edu=9 if nivel_aux==2 & e51_4==9 & e201_1==1
replace bc_edu=9+e51_5 if bc_edu==. & nivel_aux==2  & e51_5!=0
replace bc_edu=9+e51_6 if bc_edu==. & nivel_aux==2 

* UTU actual
replace bc_edu=6+e51_7 if nivel_aux==3 & e51_7<9
replace bc_edu=6 if nivel_aux==3 & e51_7==9

*magisterio
replace bc_edu=e51_8+12 if nivel_aux==4 & e51_8<9 & e51_8>0
replace bc_edu=12 if nivel_aux==4 & e51_8==9
replace bc_edu=15 if nivel_aux==4 & e51_8==9 & e215_1==1

*Terciaria
replace bc_edu=e51_9+12 if nivel_aux==5 & e51_9<9  &  e51_9>0
replace bc_edu=e51_10+12 if nivel_aux==5 & e51_10<9  &  e51_10>0
replace bc_edu=e51_11+12+e51_9 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9>=e51_10 
replace bc_edu=e51_11+12+e51_10 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9<e51_10
replace bc_edu=12 if nivel_aux==5 & e51_9==9
replace bc_edu=12 if nivel_aux==5 & e51_10==9
replace bc_edu=15 if nivel_aux==5 & e51_9==9 & e218_1==1
replace bc_edu=16 if nivel_aux==5 & e51_10==9 & e218_1==1
replace bc_edu=12+e51_9 if nivel_aux==5 & e51_11==9  & e51_9>=e51_10
replace bc_edu=12+e51_10 if nivel_aux==5 & e51_11==9  & e51_9<e51_10 

recode bc_edu 23/38=22

*finalizó
g bc_finalizo=-13

*-------------------------------------------------------------------------------
*- Años de educación. Mejor forma de captar años para 2011-2017 
*- (No compatible para 1981-2017)
gen bc_edu_1=.

*Primaria

replace bc_edu_1=0 if nivel_aux==0

replace bc_edu_1= e51_2 if nivel_aux==1 & ((e51_2>=e51_3 & e51_2!=9) | (e51_2>0 & e51_2!=9 & e51_3==9))
replace bc_edu_1= e51_3 if nivel_aux==1 & ((e51_3>e51_2 & e51_3!=9)  | (e51_3>0 & e51_3!=9 & e51_2==9))


*Secundaria

replace bc_edu_1=6+e51_4 if nivel_aux==2 & e51_4<=3 & e51_4>0
replace bc_edu_1=9+e51_5 if nivel_aux==2 & e51_4==3 & e51_5<9 & e51_5>0
replace bc_edu_1=9+e51_6 if nivel_aux==2 & e51_4==3 & e51_6<9 &  e51_6>0
replace bc_edu_1=9 if nivel_aux==2 & e51_4>0 &  e51_5==0 & e51_6==0  & e201_1==1


replace bc_edu_1=9 if nivel_aux==2 & e51_4==3 & e51_5==9
replace bc_edu_1=12 if nivel_aux==2 & e51_4==3 & e51_5==9 & e212_1==1

replace bc_edu_1=9 if nivel_aux==2 & e51_4==3 & e51_6==9
replace bc_edu_1=12 if nivel_aux==2 & e51_4==3 & e51_6==9 & e212_1==1

replace bc_edu_1=6 if nivel_aux==2 & e51_4==9 
replace bc_edu_1=9 if nivel_aux==2 & e51_4==9 & e201_1==1

replace bc_edu_1=9+e51_5 if bc_edu_1==. & nivel_aux==2  & e51_5!=0
replace bc_edu_1=9+e51_6 if bc_edu_1==. & nivel_aux==2 

* UTU actual

replace bc_edu_1=12+e51_7 if nivel_aux==3 & e51_7_1==1 & e51_7<9  &  e51_7>0
replace bc_edu_1=9+e51_7 if nivel_aux==3 & e51_7_1==2 & e51_7<9 &  e51_7>0
replace bc_edu_1=6+e51_7 if nivel_aux==3 & e51_7_1==3 & e51_7<9 &  e51_7>0
replace bc_edu_1=e51_7 if nivel_aux==3 & e51_7_1==4 & e51_7<9 &  e51_7>0
 

replace bc_edu_1=16 if nivel_aux==3 & e51_7_1==1 & e51_7>0 & e212_1==1
replace bc_edu_1=12 if nivel_aux==3 & e51_7_1==2 & e51_7>0 & e212_1==1
replace bc_edu_1=9 if nivel_aux==3 & e51_7_1==3 & e51_7>0 & e212_1==1
replace bc_edu_1=6 if nivel_aux==3 & e51_7_1==4 & e51_7>0& e212_1==1

replace bc_edu_1=12 if nivel_aux==3 & e51_7_1==1 & e51_7==9
replace bc_edu_1=15 if nivel_aux==3 & e51_7_1==1 & e51_7==9 & e212_1==1

replace bc_edu_1=9 if nivel_aux==3 &  e51_7_1==2 & e51_7==9
replace bc_edu_1=12 if nivel_aux==3 &  e51_7_1==2 & e51_7==9 & e212_1==1

replace bc_edu_1=6 if nivel_aux==3 & e51_7_1==3 & e51_7==9
replace bc_edu_1=9 if nivel_aux==3 & e51_7_1==3 & e51_7==9 & e212_1==1

*magisterio

replace bc_edu_1=e51_8+12 if nivel_aux==4 & e51_8<9  &  e51_8>0

replace bc_edu_1=12 if nivel_aux==4 & e51_8==9
replace bc_edu_1=15 if nivel_aux==4 & e51_8==9 & e215_1==1

*Terciaria

replace bc_edu_1=e51_9+12 if nivel_aux==5 & e51_9<9  &  e51_9>0
replace bc_edu_1=e51_10+12 if nivel_aux==5 & e51_10<9  &  e51_10>0
replace bc_edu_1=e51_11+12+e51_9 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9>=e51_10 
replace bc_edu_1=e51_11+12+e51_10 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9<e51_10

replace bc_edu_1=12 if nivel_aux==5 & e51_9==9
replace bc_edu_1=12 if nivel_aux==5 & e51_10==9

replace bc_edu_1=15 if nivel_aux==5 & e51_9==9 & (e218_1==1 | e221_1==1)
replace bc_edu_1=16 if nivel_aux==5 & e51_10==9 & (e218_1==1 | e221_1==1)

replace bc_edu_1=12+e51_9 if nivel_aux==5 & e51_11==9  & e51_9>=e51_10
replace bc_edu_1=12+e51_10 if nivel_aux==5 & e51_11==9  & e51_9<e51_10 

recode bc_edu_1 23/38=22

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad
g bc_pobp = pobpcoac
recode bc_pobp (10=9)

* Categoría de ocupación
g bc_pf41=f73
	replace bc_pf41=7 if f73==8
	replace bc_pf41=-9 if f73==0

g bc_cat2=-9
	replace bc_cat2=1 if f73==1
	replace bc_cat2=2 if f73==2
	replace bc_cat2=3 if f73==4
	replace bc_cat2=4 if f73==5|f73==6
	replace bc_cat2=5 if f73==3|f73==7|f73==8
	
* Tamaaño del establecimiento
g bc_pf081=-9
	replace bc_pf081=1 if (f77==1 | f77==2 | f77==3) //tamaÃ±o chico
	replace bc_pf081=2 if (f77==5 | f77==6 | f77==7) //tamaÃ±o grande

g bc_pf082=-9
	replace bc_pf082=1 if f77==1
	replace bc_pf082=2 if f77==2
	replace bc_pf082=3 if f77==3

* Rama del establecimiento
destring f72_2, replace
g bc_pf40=f72_2

g bc_rama=-9
	replace bc_rama=1 if f72_2>0000 & f72_2<1000
	replace bc_rama=2 if f72_2>1000 & f72_2<3500
	replace bc_rama=3 if f72_2>3500 & f72_2<3700
	replace bc_rama=4 if f72_2>4000 & f72_2<4500
	replace bc_rama=5 if (f72_2>=4500&f72_2<4900)|(f72_2>=5500&f72_2<5700)
	replace bc_rama=6 if (f72_2>=4900&f72_2<5500)|(f72_2>=5800&f72_2<6400)
	replace bc_rama=7 if f72_2>=6400&f72_2<8300
	replace bc_rama=8 if f72_2>=8300&f72_2<9910 | (f72_2>= 3700 & f72_2<=3900)

* Tipo de ocupación 
destring f71_2, replace
g bc_pf39=f71_2
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
g bc_pf07=f70
recode bc_pf07 (0=-9)

* Horas trabajadas
g bc_horas_hab=f85+f98 // horas semanales trabajadas habitualmente en total
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f85   // horas semanales trabajadas habitualmente en trabajo principal
recode bc_horas_hab_1 (0=-9)

g bc_horas_sp=-13 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=-13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
g bc_pf04=f69
recode bc_pf04 (3=4) (4=3) (5/6=4) (0=-9)

* Busqueda de trabajo
g bc_pf21= f107 // buscó trabajo la semana pasada
recode bc_pf21 (0=-9)

g bc_pf22=f108 // causa por la que no buscó trabajo
recode bc_pf22 (1=4) (2=1) (3=2) (4=3) (5/6=4) (0=-9)

* Duración desempleo (semanas)
g bc_pf26=f113
replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

g bc_pf34=f122 // causas por las que dejó último trabajo
recode bc_pf34 (1=2) (2=1) (4/9=3) (0=-9)

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo' (que iba hasta 2010)
	replace bc_reg_disse=2 if bc_pobp==2
	replace bc_reg_disse=1 if (e45_1_1==1 | e45_2_1==1 | e45_3_1==1 | bc_pf41==2) & bc_pobp==2

g bc_register=-9
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2&f82==1

g bc_register2=-9
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2&(f82==1|f96==1)

* Subocupado
g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if f102==1&f104==5&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.

g bc_subocupado1=-9
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f101==1|f102==1)&f103==1&f104==5&f105!=7&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.

*-------------------------------------------------------------------------------
* ipc

cap drop bc_ipc
g bc_ipc=.
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

cap drop bc_ipc_nuevo
g bc_ipc_nuevo=.
replace	bc_ipc_nuevo=	1.00000000	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.98804466	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.97885670	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.96525097	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.96126117	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.95748755	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.95292548	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.94598430	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.94002632	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.93510380	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.92807425	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.92464170	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.91793648	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.91174325	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.90301607	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.89469446	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.88794175	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.88440789	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.88082445	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.87726994	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.86918731	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.85881141	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.84954549	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.84709869	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.85236959	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.83745080	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82911865	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82413054	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82041185	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.81692672	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.81247969	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.80560702	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.79814830	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.78820840	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.78045735	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.77918030	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.78296273	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.76569678	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75426158	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.74973759	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75030012	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.74721662	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.74366030	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73806185	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73313783	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.72595281	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.72113651	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.72009793	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.72243895	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.70826546	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.69974110	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.69516858	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.69137168	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.68775791	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.68436901	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.67585834	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.66889632	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.66343794	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.65910888	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.65625410	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.65902201	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.64420537	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.63351283	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62691994	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62398602	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.61869702	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.61633282	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.61368518	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.61005368	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.60842054	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.60745960	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.60664887	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.60879094	if	bc_mes==	1	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.59417706	if	bc_mes==	2	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.59021425	if	bc_mes==	3	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58616647	if	bc_mes==	4	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58486373	if	bc_mes==	5	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58383933	if	bc_mes==	6	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58244510	if	bc_mes==	7	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58061894	if	bc_mes==	8	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.57597051	if	bc_mes==	9	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.57286893	if	bc_mes==	10	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.57019044	if	bc_mes==	11	&	bc_dpto==	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.56850483	if	bc_mes==	12	&	bc_dpto==	1	&	bc_anio==	2017


replace	bc_ipc_nuevo=	1.00000000	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.98726429	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.97799511	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.96422717	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.96190843	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.95950873	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.95776267	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.95047999	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.94598430	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.94144229	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.93519125	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.93083869	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2011
replace	bc_ipc_nuevo=	0.92464170	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.91717876	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.91124476	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.90163195	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.89365505	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.89023413	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.88880988	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.88809947	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.87973960	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.86918731	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.85881141	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.85499316	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2012
replace	bc_ipc_nuevo=	0.86266391	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.84509423	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.83696016	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.83097889	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82726671	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82576383	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.82345191	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.81806283	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.80860354	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.79662232	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.79182833	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.78988942	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2013
replace	bc_ipc_nuevo=	0.79808460	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.77724234	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.76312576	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75884049	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75918615	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75786283	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75648687	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.75097627	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.74460164	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73708263	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73351427	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73243976	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2014
replace	bc_ipc_nuevo=	0.73833432	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.72030541	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.71357214	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.70826546	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.70407660	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.70096733	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.69817776	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.69041701	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.68110612	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.67764451	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.67408156	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.67136623	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2015
replace	bc_ipc_nuevo=	0.67622397	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.65880493	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.64922418	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.64267352	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.63987714	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.63283129	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.63011972	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62802236	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62468766	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62332481	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62189055	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62169723	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2016
replace	bc_ipc_nuevo=	0.62676277	if	bc_mes==	1	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60968175	if	bc_mes==	2	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60808756	if	bc_mes==	3	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60408361	if	bc_mes==	4	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60273642	if	bc_mes==	5	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60237335	if	bc_mes==	6	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60222824	if	bc_mes==	7	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.60024010	if	bc_mes==	8	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.59594756	if	bc_mes==	9	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.59276823	if	bc_mes==	10	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.59021425	if	bc_mes==	11	&	bc_dpto!=	1	&	bc_anio==	2017
replace	bc_ipc_nuevo=	0.58792404	if	bc_mes==	12	&	bc_dpto!=	1	&	bc_anio==	2017

cap drop bc_ipc_tot
g bc_ipc_tot=.

replace	bc_ipc_tot=	0.74533956	if	bc_mes==	1	&	bc_anio==	2011
replace	bc_ipc_tot=	0.73613784	if	bc_mes==	2	&	bc_anio==	2011
replace	bc_ipc_tot=	0.72929507	if	bc_mes==	3	&	bc_anio==	2011
replace	bc_ipc_tot=	0.71909268	if	bc_mes==	4	&	bc_anio==	2011
replace	bc_ipc_tot=	0.71667265	if	bc_mes==	5	&	bc_anio==	2011
replace	bc_ipc_tot=	0.71433732	if	bc_mes==	6	&	bc_anio==	2011
replace	bc_ipc_tot=	0.71181316	if	bc_mes==	7	&	bc_anio==	2011
replace	bc_ipc_tot=	0.70648299	if	bc_mes==	8	&	bc_anio==	2011
replace	bc_ipc_tot=	0.70255402	if	bc_mes==	9	&	bc_anio==	2011
replace	bc_ipc_tot=	0.69899612	if	bc_mes==	10	&	bc_anio==	2011
replace	bc_ipc_tot=	0.69404931	if	bc_mes==	11	&	bc_anio==	2011
replace	bc_ipc_tot=	0.69115315	if	bc_mes==	12	&	bc_anio==	2011
replace	bc_ipc_tot=	0.68631635	if	bc_mes==	1	&	bc_anio==	2012
replace	bc_ipc_tot=	0.68129759	if	bc_mes==	2	&	bc_anio==	2012
replace	bc_ipc_tot=	0.67567724	if	bc_mes==	3	&	bc_anio==	2012
replace	bc_ipc_tot=	0.66906603	if	bc_mes==	4	&	bc_anio==	2012
replace	bc_ipc_tot=	0.66364487	if	bc_mes==	5	&	bc_anio==	2012
replace	bc_ipc_tot=	0.66105504	if	bc_mes==	6	&	bc_anio==	2012
replace	bc_ipc_tot=	0.65906761	if	bc_mes==	7	&	bc_anio==	2012
replace	bc_ipc_tot=	0.65732389	if	bc_mes==	8	&	bc_anio==	2012
replace	bc_ipc_tot=	0.65123596	if	bc_mes==	9	&	bc_anio==	2012
replace	bc_ipc_tot=	0.64342158	if	bc_mes==	10	&	bc_anio==	2012
replace	bc_ipc_tot=	0.63611808	if	bc_mes==	11	&	bc_anio==	2012
replace	bc_ipc_tot=	0.63389995	if	bc_mes==	12	&	bc_anio==	2012
replace	bc_ipc_tot=	0.63857056	if	bc_mes==	1	&	bc_anio==	2013
replace	bc_ipc_tot=	0.62665172	if	bc_mes==	2	&	bc_anio==	2013
replace	bc_ipc_tot=	0.62049580	if	bc_mes==	3	&	bc_anio==	2013
replace	bc_ipc_tot=	0.61644162	if	bc_mes==	4	&	bc_anio==	2013
replace	bc_ipc_tot=	0.61370075	if	bc_mes==	5	&	bc_anio==	2013
replace	bc_ipc_tot=	0.61173634	if	bc_mes==	6	&	bc_anio==	2013
replace	bc_ipc_tot=	0.60908683	if	bc_mes==	7	&	bc_anio==	2013
replace	bc_ipc_tot=	0.60444373	if	bc_mes==	8	&	bc_anio==	2013
replace	bc_ipc_tot=	0.59823385	if	bc_mes==	9	&	bc_anio==	2013
replace	bc_ipc_tot=	0.59018098	if	bc_mes==	10	&	bc_anio==	2013
replace	bc_ipc_tot=	0.58536053	if	bc_mes==	11	&	bc_anio==	2013
replace	bc_ipc_tot=	0.58416769	if	bc_mes==	12	&	bc_anio==	2013
replace	bc_ipc_tot=	0.58841048	if	bc_mes==	1	&	bc_anio==	2014
replace	bc_ipc_tot=	0.57439855	if	bc_mes==	2	&	bc_anio==	2014
replace	bc_ipc_tot=	0.56503643	if	bc_mes==	3	&	bc_anio==	2014
replace	bc_ipc_tot=	0.56175728	if	bc_mes==	4	&	bc_anio==	2014
replace	bc_ipc_tot=	0.56209620	if	bc_mes==	5	&	bc_anio==	2014
replace	bc_ipc_tot=	0.56032142	if	bc_mes==	6	&	bc_anio==	2014
replace	bc_ipc_tot=	0.55839044	if	bc_mes==	7	&	bc_anio==	2014
replace	bc_ipc_tot=	0.55423822	if	bc_mes==	8	&	bc_anio==	2014
replace	bc_ipc_tot=	0.55010669	if	bc_mes==	9	&	bc_anio==	2014
replace	bc_ipc_tot=	0.54463979	if	bc_mes==	10	&	bc_anio==	2014
replace	bc_ipc_tot=	0.54143510	if	bc_mes==	11	&	bc_anio==	2014
replace	bc_ipc_tot=	0.54064961	if	bc_mes==	12	&	bc_anio==	2014
replace	bc_ipc_tot=	0.54352772	if	bc_mes==	1	&	bc_anio==	2015
replace	bc_ipc_tot=	0.53173971	if	bc_mes==	2	&	bc_anio==	2015
replace	bc_ipc_tot=	0.52596116	if	bc_mes==	3	&	bc_anio==	2015
replace	bc_ipc_tot=	0.52231223	if	bc_mes==	4	&	bc_anio==	2015
replace	bc_ipc_tot=	0.51936420	if	bc_mes==	5	&	bc_anio==	2015
replace	bc_ipc_tot=	0.51684319	if	bc_mes==	6	&	bc_anio==	2015
replace	bc_ipc_tot=	0.51452406	if	bc_mes==	7	&	bc_anio==	2015
replace	bc_ipc_tot=	0.50838248	if	bc_mes==	8	&	bc_anio==	2015
replace	bc_ipc_tot=	0.50245352	if	bc_mes==	9	&	bc_anio==	2015
replace	bc_ipc_tot=	0.49902220	if	bc_mes==	10	&	bc_anio==	2015
replace	bc_ipc_tot=	0.49603325	if	bc_mes==	11	&	bc_anio==	2015
replace	bc_ipc_tot=	0.49392946	if	bc_mes==	12	&	bc_anio==	2015
replace	bc_ipc_tot=	0.49666126	if	bc_mes==	1	&	bc_anio==	2016
replace	bc_ipc_tot=	0.48480523	if	bc_mes==	2	&	bc_anio==	2016
replace	bc_ipc_tot=	0.47717001	if	bc_mes==	3	&	bc_anio==	2016
replace	bc_ipc_tot=	0.47227193	if	bc_mes==	4	&	bc_anio==	2016
replace	bc_ipc_tot=	0.47012713	if	bc_mes==	5	&	bc_anio==	2016
replace	bc_ipc_tot=	0.46563351	if	bc_mes==	6	&	bc_anio==	2016
replace	bc_ipc_tot=	0.46377920	if	bc_mes==	7	&	bc_anio==	2016
replace	bc_ipc_tot=	0.46196824	if	bc_mes==	8	&	bc_anio==	2016
replace	bc_ipc_tot=	0.45934892	if	bc_mes==	9	&	bc_anio==	2016
replace	bc_ipc_tot=	0.45821933	if	bc_mes==	10	&	bc_anio==	2016
replace	bc_ipc_tot=	0.45737577	if	bc_mes==	11	&	bc_anio==	2016
replace	bc_ipc_tot=	0.45692714	if	bc_mes==	12	&	bc_anio==	2016
replace	bc_ipc_tot=	0.45943386	if	bc_mes==	1	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44778586	if	bc_mes==	2	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44556406	if	bc_mes==	3	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44257441	if	bc_mes==	4	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44160419	if	bc_mes==	5	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44102932	if	bc_mes==	6	&	bc_anio==	2017
replace	bc_ipc_tot=	0.44037788	if	bc_mes==	7	&	bc_anio==	2017
replace	bc_ipc_tot=	0.43897730	if	bc_mes==	8	&	bc_anio==	2017
replace	bc_ipc_tot=	0.43561634	if	bc_mes==	9	&	bc_anio==	2017
replace	bc_ipc_tot=	0.43328657	if	bc_mes==	10	&	bc_anio==	2017
replace	bc_ipc_tot=	0.43130580	if	bc_mes==	11	&	bc_anio==	2017
replace	bc_ipc_tot=	0.42986306	if	bc_mes==	12	&	bc_anio==	2017

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
keep if e30==14
save "$rutainterm/servdom15",replace
restore
drop if e30==14
