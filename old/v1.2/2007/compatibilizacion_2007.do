u "$rutainterm/fusionado_2007_corregido", clear

g correlat = numero

gen area=.  
replace area=0 if region_4==1 // Montevideo
replace area=1 if region_4==2 // Interior mayores de 5000
replace area=2 if region_4==3 // Interior menores de 5000
replace area=3 if region_4==4 // rurales - rural dispersa

cap drop filtloc
g filtloc=(region_4<3) // localidades de más de 5000 

*-------------------------------------------------------------------------------
* Características generales y de las personas

* sexo
cap drop pe2
g pe2 = e27

* edad
cap drop pe3
g pe3 = e28

* parentesco
g pe4=.
replace pe4=1 if e32==1
replace pe4=2 if e32==2
replace pe4=3 if e32==3| e32==4| e32==5
replace pe4=4 if e32==7|e32==8
replace pe4=5 if e32==6|e32==9|e32==10|e32==11|e32==12 
replace pe4=6 if e32==13
replace pe4=7 if e32==14

* estado civil
gen pe5=.
replace pe5=1 if e39==2
replace pe5=2 if e39==1
replace pe5=3 if e39==0 & (e40==1|e40==2)
replace pe5=4 if e39==0 & (e40==3)
replace pe5=5 if e39==0 & (e40==4)

*-------------------------------------------------------------------------------
* Atención de la Salud

g pe6a=0
replace pe6a=2 if e43_7==1 & e45_1!=3
replace pe6a=3 if e43_7==1 & e45_1==3
replace pe6a=4 if (e43_1==1|e43_2==1|e43_3==1|e43_4==1|e43_5==1|e43_6==1) ///
&(e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1)
replace pe6a=5 if (e43_8==1|e43_9==1|e43_10==1|e45==1)&e43_7!=1
replace pe6a=1 if e43_1!=1&e43_2!=1&e43_3!=1&e43_4!=1&e43_5!=1 ///
&e43_6!=1&e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1

g pe6b=0
replace pe6b=2 if e43_7==1 
replace pe6b=3 if (e43_1==1|e43_2==1|e43_3==1|e43_4==1|e43_5==1|e43_6==1) ///
&(e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1)
replace pe6b=4 if (e43_8==1|e43_9==1|e43_10==1|e45==1)&e43_7!=1
replace pe6b=1 if e43_1!=1&e43_2!=1&e43_3!=1&e43_4!=1&e43_5!=1 ///
&e43_6!=1&e43_7!=1&e43_8!=1&e43_9!=1&e43_10!=1&e47!=1

*-------------------------------------------------------------------------------
* Educación

cap drop pe11
gen pe11=(e50==1) //asiste

cap drop pe12
gen pe12=(e53==1) //asistió

* nivel 
cap drop nivel2
g nivel2=.

replace nivel2=0 if pe11==0 & pe12==0 // nunca asistió
replace nivel2=0 if (e52_1>0)  

replace nivel2=1 if (e50==1&(e52_1!=0|e52_2!=0|e52_3!=0))| ///
(e50==2&(e53==2|e53==0))|(e50==2&e53==1&e52_1_1>=0&e52_2_1==0&e52_3_1==0& ///
e52_4_1==0&e52_5_1==0&e52_6_1==0&e52_7_1==0)|(e50==2&e53==1& ///
e52_3_3==4&e52_4_1==0&e52_5_1==0&e52_6_1==0&e52_7_1==0) 

replace nivel2=2 if (e50==1&(e52_4!=0|e52_5!=0)|(e50==2&e53==1& ///
((e52_2_1<=3&e52_2_1!=.&e52_2_2==2)|(e52_3_3==3&e52_3_1<=3))& ///
e52_4_1==0&e52_5_1==0&e52_6_1==0&e52_7_1==0)) 
 
replace nivel2=3  if (e50==1&(e52_6!=0|e52_7!=0|e52_8!=0)|(e50==2& ///
e53==1&((e52_2_1>3&e52_2_1!=.)|(e52_3_3==2|(e52_3_3==3&e52_3_1>3))) ///
&e52_4_1==0&e52_5_1==0&e52_6_1==0&e52_7_1==0)) 

replace nivel2=4 if (e50==1&(e52_9!=0|e52_11!=0))|(e50==2&e53==1& ///
(e52_4_1>0|e52_6_1>0|e52_3_3==1)&e52_5_1==0&e52_7_1==0)

replace nivel2=5 if (e50==1&(e52_10!=0|e52_12!=0))|(e50==2&e53==1& ///
(e52_5_1>0|e52_7_1>0))

replace nivel2=0 if nivel2==. 

* años de educación
cap drop edu
g edu=.

*Primaria
replace edu=0 if nivel2==0|(nivel2==1&e52_1!=0)|e53==2
g e52_2a=e52_2
	replace e52_2a=6 if e52_2a>6
replace edu= (e52_2a-1) if  nivel2==1&e52_2a!=0  
replace edu= (e52_3-1) if nivel2==1&e52_2a==0&e52_3!=0
replace edu= e52_3_1 if nivel2==1&e50==2&e52_3_3==4
replace edu= e52_1_1 if nivel2==1&e50==2&e52_1_1!=0
drop e52_2a

*Secundaria
replace edu=(e52_4+5) if (nivel2==2|nivel2==3)&e52_4!=0
replace edu=(e52_6+5) if (nivel2==2|nivel2==3)&e52_6!=0 
replace edu=6+e52_2_1 if (nivel2==2|nivel2==3)&e50==2&e52_2_1!=0

* UTU actual
replace edu=(e52_5+5) if (nivel2==2|nivel2==3)&e52_5!=0 
replace edu=(e52_7+5) if (nivel2==2|nivel2==3)&e52_7!=0 
replace edu=(e52_8+5) if (nivel2==2|nivel2==3)&e52_8!=0
replace edu=6+e52_3_1 if (nivel2==2|nivel2==3)&e50==2&e52_3_1!=0

*magisterio
recode e52_12 22=2, g(e52_12a)
recode e52_10 10=1 40=4, g(e52_10a)
recode e52_11 10=1, g(e52_11a)
recode e52_5_1 42=4, g(e52_5_1a)
recode e52_7_1 13=8 21=2, g(e52_7_1a)

replace edu=(e52_9+11) if nivel2==4&e52_9!=0
replace edu=12+e52_4_1 if nivel2==4&e50==2&e52_4_1!=0
replace edu=(e52_11+11) if nivel2==4&e52_11!=0
replace edu=17 if e52_11>5 & nivel2==4
replace edu=12+e52_6_1 if nivel2==4&e50==2&e52_6_1!=0
replace edu=12+e52_3_1 if nivel2==4&e50==2&e52_3_3==1

*Terciaria
replace edu=(e52_10a+11) if nivel2==5&e52_10a!=0 
replace edu=17 if e52_10a>5 & nivel2==5 
replace edu=12+e52_5_1a if nivel2==5&e50==2&e52_5_1a!=0

replace edu=(e52_12a+16) if nivel2==5&e52_12!=0
replace edu=22 if e52_12a>5 & nivel2==5
replace edu=17+e52_7_1a if nivel2==5&e50==2&e52_7_1a!=0

recode edu 23/38=22

drop e52_12a e52_10a e52_11a e52_5_1a e52_7_1a

*-------------------------------------------------------------------------------
* Mercado de trabajo

* Condición de actividad
g pobp = pobpcoac
recode pobp (10=9)

* Categoría de ocupación
g pf41a=f75
replace pf41a=7 if f75==8

g cat2=.
	replace cat2=1 if f75==1
	replace cat2=2 if f75==2
	replace cat2=3 if f75==4
	replace cat2=4 if f75==5|f75==6
	replace cat2=5 if f75==3|f75==7|f75==8

* Tamaño del establecimiento
cap drop pf081
gen pf081=0
replace pf081=1 if f80>=1 & f80<=3
replace pf081=2 if f80>3

g pf082a=0
replace pf082a=1 if f80==1
replace pf082a=2 if f80==2
replace pf082a=3 if f80==3

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
g pf40=f74_2a

g rama=0
g ram_aux=trunc(f74_2a/100) 
replace rama=1 if ram_aux>0 & ram_aux<=14 & pobp==2 // ciu3
replace rama=2 if ram_aux>14 & ram_aux<40 & pobp==2 
replace rama=3 if ram_aux>39 & ram_aux<42 & pobp==2
replace rama=4 if ram_aux==45 & pobp==2
replace rama=5 if ram_aux>45 & ram_aux<=55 & pobp==2 
replace rama=6 if ram_aux>55 & ram_aux<=64 & pobp==2 
replace rama=7 if ram_aux>64 & ram_aux<75 & pobp==2
replace rama=8 if ram_aux>74 & ram_aux!=. & pobp==2
replace rama=. if rama==0
drop ram_aux f74_2a

* Tipo de ocupación
cap drop pf39
g f73_2a=f73_2
destring f73_2a, replace
g pf39=f73_2a
drop f73_2a

cap drop pf39aux
g pf39aux=pf39
replace pf39aux=0 if pf39>0 & pf39<130

cap drop tipo_ocup
gen tipo_ocup=trunc(pf39aux/1000)
drop pf39aux

* Cantidad de empleos
g pf07=f72

* Horas trabajadas
g horas=f88+f101  // horas semanales trabajadas en total
g horas_1=f88    // horas semanales del trabajo principal

* Motivo por el que no trabaja
g pf04a=f71
recode pf04a (3=4) (4=3)

* Busqueda de trabajo
g pf21=(f110==1) // buscó trabajo la semana pasada

g pf22a=f111 // causa por la que no buscó trabajo
recode pf22a (1=4) (2=1) (3=2) (4=3)

* Duración desempleo (semanas)
g pf26=f116

g pf34a=f125 // causas por las que dejó último trabajo
recode pf34a (1=2) (2=1) (4/9=3)

* Trabajo registrado
g reg_disse=. // esta variable estaba generada en el do 'calidad de empleo'
replace reg_disse=1 if (e45_1==3|pf41a==2)&pobp==2
replace reg_disse=0 if (e45_1!=3&pf41a!=2)&pobp==2

g register=.
replace register=0 if pobpcoac==2
replace register=1 if pobpcoac==2&f85==1

g register2=.
replace register2=0 if pobpcoac==2
replace register2=1 if pobpcoac==2&(f85==1|f99==1)

* Subocupado
g subocupado=.
replace subocupado=1 if f105==1&f106==1&f107==4&f108!=6&horas>0& ///
horas<40&horas!=. 

*-------------------------------------------------------------------------------
* ipc
cap drop ipc
g ipc=.
replace	ipc=	1.00000000	if	mes==	1	&	anio==	2007
replace	ipc=	0.98258326	if	mes==	2	&	anio==	2007
replace	ipc=	0.97661504	if	mes==	3	&	anio==	2007
replace	ipc=	0.96792226	if	mes==	4	&	anio==	2007
replace	ipc=	0.95624469	if	mes==	5	&	anio==	2007
replace	ipc=	0.94902821	if	mes==	6	&	anio==	2007
replace	ipc=	0.94774957	if	mes==	7	&	anio==	2007
replace	ipc=	0.93999248	if	mes==	8	&	anio==	2007
replace	ipc=	0.92401790	if	mes==	9	&	anio==	2007
replace	ipc=	0.92020276	if	mes==	10	&	anio==	2007
replace	ipc=	0.92231419	if	mes==	11	&	anio==	2007
replace	ipc=	0.92443532	if	mes==	12	&	anio==	2007

save "$rutainterm/p7_siningr", replace
