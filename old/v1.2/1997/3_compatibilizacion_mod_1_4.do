*3_ ----------------------------------------------------------------------------
* Variables de identificación general
rename correlat bc_correlat 
rename nper bc_nper 

g bc_filtloc=1
	replace bc_filtloc=2 if dpto==2&pe1g==522
	replace bc_filtloc=2 if dpto==3&(pe1g==526|pe1g==527|pe1g==528|pe1g==628|pe1g==629|pe1g==631)
	replace bc_filtloc=2 if dpto==4&pe1g==721
	replace bc_filtloc=2 if dpto==5&(pe1g==521|pe1g==622)
	replace bc_filtloc=2 if dpto==6&pe1g==721
	replace bc_filtloc=2 if dpto==7&pe1g==721
	replace bc_filtloc=2 if dpto==8&pe1g==624
	replace bc_filtloc=2 if dpto==9&pe1g==522
	replace bc_filtloc=2 if dpto==10&pe1g==521
	replace bc_filtloc=2 if dpto==11&(pe1g==521 | pe1g==695)
	replace bc_filtloc=2 if dpto==12&pe1g==621
	replace bc_filtloc=2 if dpto==15&pe1g==523
	replace bc_filtloc=2 if dpto==16&(pe1g==421|pe1g==621)
	replace bc_filtloc=2 if dpto==17&pe1g==521
	replace bc_filtloc=2 if dpto==18&pe1g==521
	replace bc_filtloc=2 if dpto==19&pe1g==522
/*- Nota: para filtloc se basa en el programa 
S:\empleo\datos\encuestas\ech\programas\compatibilización ECH\varios\filtloc (1991-1997)
*/

*Pesos que cambian los porcentajes de representación de Montevideo e interior
/*
g montint=(dpto==1) if bc_filtloc==1
qui tab montint if bc_filtloc==1, matcell(A)
g bc_pesoan=1+((A[2,1]-A[1,1])/A[1,1]) if dpto!=1
	replace bc_pesoan=1-((A[2,1]-A[1,1])/A[1,1]) if dpto==1

*/
*en la vieja compatibilizada 
g bc_pesoan=0.9670103 if dpto==1
	replace bc_pesoan=1.031068  if dpto!=1

* Los valores anteriores son del servidor
*- En cambio, las bases nuevas tenían el siguiente código
/*
g bc_pesoan=0.9675447 if dpto==1
	replace bc_pesoan=1.032455  if dpto!=1
*/	
g bc_mes=-15
	replace bc_mes=1  if pe1b<=4
	replace bc_mes=2  if pe1b>=5  & pe1b<=8
	replace bc_mes=3  if pe1b>=9  & pe1b<=12
	replace bc_mes=4  if pe1b>=13 & pe1b<=16
	replace bc_mes=5  if pe1b>=17 & pe1b<=20
	replace bc_mes=6  if pe1b>=21 & pe1b<=24
	replace bc_mes=7  if pe1b>=25 & pe1b<=28
	replace bc_mes=8  if pe1b>=29 & pe1b<=32
	replace bc_mes=9  if pe1b>=33 & pe1b<=36
	replace bc_mes=10 if pe1b>=37 & pe1b<=40
	replace bc_mes=11 if pe1b>=41 & pe1b<=44
	replace bc_mes=12 if pe1b>=45 & pe1b!=.

g bc_anio=1997
rename dpto bc_dpto
rename ccz bc_ccz
recode bc_ccz (.=-9)
g bc_area=-13

*-------------------------------------------------------------------------------
* 1- Características generales y de las personas

* sexo
recode pe2 (0 3 4 =-15), g(bc_pe2)

* edad 
recode pe3 (. =-15), g(bc_pe3) // pe3 tiene missing y no tiene ceros a veces

* parentesco
recode pe4 (0 =-9), g(bc_pe4)

* estado civil
recode pe5 (8 =-9), g(bc_pe5)
	replace bc_pe5 =-9 if bc_pe3<14 & bc_pe3!=-15
*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-15
	replace bc_pe6a=2 if pe6==2|pe6==3|pe6==5
	replace bc_pe6a=3 if pe6==4
	replace bc_pe6a=4 if pe6==6|pe6==8|pe6==7
	replace bc_pe6a=5 if pe6==9
	replace bc_pe6a=1 if pe6==1

g bc_pe6b=-15
	replace bc_pe6b=2 if pe6==2|pe6==3|pe6==5
	replace bc_pe6b=3 if pe6==6|pe6==7|pe6==8
	replace bc_pe6b=4 if pe6==9
	replace bc_pe6b=1 if pe6==1
	replace bc_pe6b=-9 if bc_pe6a==3 // este valor NC para estos casos

g bc_pe6a1=-13
*-------------------------------------------------------------------------------
* 3- Educación

*asiste 
recode pe11 (0 . =-15), g(bc_pe11)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
recode pe12 (0 3 .=-15), g(bc_pe12) 
	replace bc_pe12=-9 if bc_pe11==1&(bc_pe12==-15|bc_pe12==1)
	replace bc_pe12=-9 if bc_pe11==1&bc_pe12==2
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.
	
*asistencia actual pco o privada
recode pe13 (3 =2) (0 8 . =-15), g(bc_pe13)
	replace bc_pe13=-9 if bc_pe11==2&bc_pe13==-15
	replace bc_pe13=-9 if bc_pe11==2&bc_pe13>0

*nivel 
recode pe141 (3 =2) (4 =3) (5 =4) (6 7 =5) (8 =0) (9 . =-15), g(bc_nivel)
	replace bc_nivel=0 if pe142==0&pe141==1
	replace bc_nivel=0 if pe12==2
	replace bc_nivel=0 if (pe142==0|pe142==.)&(pe11==1|pe11==2&pe12==1)&pe141==1

*años de educación
recode pe142 (. =0), g(auxanios)
	replace auxanios=0 if pe141==8
	replace auxanios=0 if pe12==2
g auxniv=.
	replace auxniv=1 if pe141==. 
g auxan=.
	replace auxan=1 if pe142==.
*correcciones por edad
	replace auxanios=0 if auxniv==1&(bc_anio==1995|bc_anio==1997) //antes: auxniv==1&bc_anio==1995&bc_anio==1997 
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&pe11==1&bc_pe3<=7
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&pe11==1&bc_pe3<=14&pe141==2
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&bc_pe11==1&bc_pe3<=17&pe141==3
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&pe11==1&(bc_pe3==18|bc_pe3==19)&pe141==5
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&pe11==1&(bc_pe3==18|bc_pe3==19)&pe141==6
	replace auxanios=0 if auxan==1&auxniv==.&pe141!=8&pe11==1&(bc_pe3==18|bc_pe3==19)&pe141==7

g bc_edu=-15
	replace bc_edu=0 if bc_nivel==0

*Primaria
	replace bc_edu=auxanios if bc_nivel==1 & auxanios<=6
	replace bc_edu=6 if bc_nivel==1 & auxanios>6

*Secundaria	
	replace bc_edu=6+auxanios if bc_nivel==2&pe141==2&auxanios<=3&pe3<30
	replace bc_edu=6+auxanios if bc_nivel==2&pe141==2&auxanios<=4&pe3>=30
	replace bc_edu=6+3 if bc_nivel==2&pe141==2&auxanios>3&pe3<30
	replace bc_edu=6+4 if bc_nivel==2&pe141==2&auxanios>4&pe3>=30
	
	replace bc_edu=9 +auxanios if bc_nivel==2&pe141==3&auxanios<=3&pe3<30
	replace bc_edu=10+auxanios if bc_nivel==2&pe141==3&auxanios<=2&pe3>=30
	replace bc_edu=9+3  if bc_nivel==2&pe141==3&auxanios>3&pe3<30
	replace bc_edu=10+2 if bc_nivel==2&pe141==3&auxanios>2&pe3>=30
	*casos pe3>30&pe11==1 (asisten actualmente)
	replace bc_edu=9+auxanios if bc_nivel==2&pe141==3&auxanios<=3&pe3>=30&pe11==1

*UTU actual
	replace bc_edu=auxanios+6 if bc_nivel==3&pe141==4&auxanios<=6
	replace bc_edu=12 if bc_nivel==3&pe141==4&auxanios>6

*magisterio
	replace bc_edu=auxanios+12 if bc_nivel==4&pe141==5&auxanios<=4
	replace bc_edu=16 if bc_nivel==4&pe141==5&auxanios>4&auxanios!=8
	replace bc_edu=16 if bc_nivel==4&pe141==5&auxanios==8

*Terciaria
	replace bc_edu=auxanios+12 if bc_nivel==5&pe141==6&auxanios<=8
	replace bc_edu=auxanios+12 if bc_nivel==5&pe141==7&auxanios<=8

recode bc_edu (23/38 =22) (. =-15)

drop auxanios auxniv auxan

*finalizó
recode pe15 (0 3/9 . =-15), g(bc_finalizo)

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad
recode pobpcoac (40=1) (11/12=2) (23=3) (21=4) (22=5) (34=6) (33=7) (32=8) (30/31=9) (35/38=11) (99=-15), g(bc_pobp)

* Categoría de ocupación
recode pf41 (8=7) (0 .=-9), g(bc_pf41)

recode pf41 (4=3) (5 6=4) (3 7 8=5) (0 .=-15), g(bc_cat2)

* Tamaño del establecimiento
recode pf081 (0 .=-15), g(bc_pf081)
	replace bc_pf081=-9 if bc_pobp==1|bc_pobp>2
	replace bc_pf081=-15 if bc_pobp==11&bc_pf081>0

recode pf082 (0 . =-15) (2/4=2) (5/9=3), g(bc_pf082)
	replace bc_pf082=-9 if bc_pf081==-9|bc_pf081==2|(bc_pf081==-15&bc_pf082>0)

* Rama del establecimiento
recode pf40 (.=-15), g(bc_pf40)

g bc_rama=-15
	replace bc_rama=1 if bc_pf40>=10&bc_pf40<30&bc_pobp==2 // CIIU2
	replace bc_rama=2 if bc_pf40>=30&bc_pf40<40&bc_pobp==2
	replace bc_rama=3 if bc_pf40>=40&bc_pf40<50&bc_pobp==2
	replace bc_rama=4 if bc_pf40>=50&bc_pf40<60&bc_pobp==2
	replace bc_rama=5 if bc_pf40>=60&bc_pf40<70&bc_pobp==2 
	replace bc_rama=6 if bc_pf40>=70&bc_pf40<80&bc_pobp==2
	replace bc_rama=7 if bc_pf40>=80&bc_pf40<90&bc_pobp==2
	replace bc_rama=8 if bc_pf40>=90&bc_pf40!=.&bc_pobp==2
	replace bc_rama=-9 if bc_rama==-15&bc_pobp!=2
	
* Tipo de ocupación
g bc_pf39=pf39
	replace bc_pf39=-9 if bc_pobp!=2
	replace bc_pf39= 0 if pf39>0&pf39<13&bc_pobp==2 //militares hasta marzo2005  
	replace bc_pf39=-15 if bc_pf39==.&bc_pobp==2

g auxpf39=pf39
	replace auxpf39=0 if pf39>0&pf39<13 // Esta línea para el período a continuación ((bc_anio>1985&bc_anio<2005)|(bc_anio==2005&(bc_mes==1|bc_mes==2|bc_mes==3))) // militares 
	replace auxpf39=pf39*10 if pf39>12&pf39<1000 // ídem anterior 
	*replace auxpf39=0 if pf39>0&pf39<130 // Esta línea para el período a continuación (bc_anio>2005|(bc_anio==2005&bc_mes>3)) //militares 

g bc_tipo_ocup=trunc(auxpf39/1000)
	replace bc_tipo_ocup=-9 if bc_pobp!=2
	replace bc_tipo_ocup=-15 if bc_tipo_ocup==.&bc_pobp==2
drop auxpf39

* Cantidad de empleos
recode pf07 (.=-15), g(bc_pf07)
	replace bc_pf07=-9 if bc_pobp!=2

* Horas trabajadas
recode pf051 (.=-15), g(bc_pf051)
	replace bc_pf051=-9 if bc_pobp!=2
recode pf052 (.=-15), g(bc_pf052)
	replace bc_pf052=-9 if bc_pobp!=2
recode pf053 (.=-15), g(bc_pf053)
	replace bc_pf053=-9 if bc_pobp!=2
recode pf06 (.=-15), g(bc_pf06)
	replace bc_pf06=-9 if bc_pobp!=2

g bc_horas_sp=bc_pf053 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=bc_pf051 // horas semanales trabajadas semana pasada en trabajo principal

g bc_horas_hab=bc_pf06 // horas semanales habitualmente trabajadas en total
g bc_horas_hab_1=-13 // horas semanales habitualmente trabajadas en trabajo principal

* Motivo por el que no trabaja
recode pf04 (6=2) (4 2 =3) (3 5 7 8=4) (0 .=-15), g(bc_pf04)
	replace bc_pf04=-9 if bc_pobp!=2

* Busqueda de trabajo
// buscó trabajo la semana pasada
recode pf21 (5 6 =-15) (.=-15), g(bc_pf21) 
	replace bc_pf21=-9 if bc_pobp==1|bc_pobp==2 // sigo criterio de salto para ocupados

// causa por la que no buscó trabajo
recode pf22 (1 5 6=4) (2=1) (3=2) (4=3) (.=-15), g(bc_pf22) 
	replace bc_pf22=-9 if bc_pf21!=2

* Duración desempleo (semanas)
recode pf26 (.=-15), g(bc_pf26)
	replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

// causas por las que dejó último trabajo
recode pf34 (4=1) (3=2) (1 2 5/10=3) (0 .=-15), g(bc_pf34)
	replace bc_pf34=-9 if bc_pobp<4

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo'
	replace bc_reg_disse=1 if (bc_pf41==2|bc_pe6a==3)&bc_pobp==2
	replace bc_reg_disse=2 if bc_pf41!=2&bc_pe6a!=3 &bc_pobp==2

g bc_register=-13
g bc_register2=-13

* Subocupado
g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if pf18==1&pf20==4&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=. 

g bc_subocupado1=-13
*-------------------------------------------------------------------------------
* ipc
g bc_ipc=-15
replace bc_ipc=2.36289215735722 if bc_mes==1&bc_anio==1997
replace bc_ipc=2.31701195504087 if bc_mes==2&bc_anio==1997
replace bc_ipc=2.27972424042939 if bc_mes==3&bc_anio==1997
replace bc_ipc=2.25100000000000 if bc_mes==4&bc_anio==1997
replace bc_ipc=2.21948333662000 if bc_mes==5&bc_anio==1997
replace bc_ipc=2.19011480832847 if bc_mes==6&bc_anio==1997
replace bc_ipc=2.16192854398771 if bc_mes==7&bc_anio==1997
replace bc_ipc=2.13344706662876 if bc_mes==8&bc_anio==1997
replace bc_ipc=2.11719337848006 if bc_mes==9&bc_anio==1997
replace bc_ipc=2.10040123168797 if bc_mes==10&bc_anio==1997
replace bc_ipc=2.08425925925926 if bc_mes==11&bc_anio==1997
replace bc_ipc=2.06684418327059 if bc_mes==12&bc_anio==1997

g bc_ipc_nuevo=-13
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* Drop servicio doméstico y sin hogar

drop _merge

preserve 
keep if bc_pe4==7
save "$rutainterm/servdom97",replace
restore
drop if bc_pe4==7



