*3_ ----------------------------------------------------------------------------
* Variables de identificación general
rename correlat bc_correlat 
rename nper bc_nper 

g bc_filtloc=1
	replace bc_filtloc=2 if dpto==2&ha8==522
	replace bc_filtloc=2 if dpto==3&(ha8==526|ha8==527|ha8==528|ha8==628|ha8==629|ha8==631)
	replace bc_filtloc=2 if dpto==4&ha8==721
	replace bc_filtloc=2 if dpto==5&(ha8==521|ha8==622)
	replace bc_filtloc=2 if dpto==6&ha8==721
	replace bc_filtloc=2 if dpto==7&ha8==721
	replace bc_filtloc=2 if dpto==8&ha8==624
	replace bc_filtloc=2 if dpto==9&ha8==522
	replace bc_filtloc=2 if dpto==10&ha8==521
	replace bc_filtloc=2 if dpto==11&(ha8==521|ha8==695)
	replace bc_filtloc=2 if dpto==12&ha8==621
	replace bc_filtloc=2 if dpto==15&ha8==523
	replace bc_filtloc=2 if dpto==16&(ha8==421|ha8==621)
	replace bc_filtloc=2 if dpto==17&ha8==521
	replace bc_filtloc=2 if dpto==18&ha8==521
	replace bc_filtloc=2 if dpto==19&ha8==522
/*- Nota: para filtloc se basa en el programa 
S:\empleo\datos\encuestas\ech\programas\compatibilización ECH\varios\filtloc (1991-1997)
*/

g bc_pesoan=1 // muestra autoponderada
	
g bc_mes=-15
	replace bc_mes=1  if ha2<=4
	replace bc_mes=2  if ha2>=5  & ha2<=8
	replace bc_mes=3  if ha2>=9  & ha2<=12
	replace bc_mes=4  if ha2>=13 & ha2<=16
	replace bc_mes=5  if ha2>=17 & ha2<=20
	replace bc_mes=6  if ha2>=21 & ha2<=24
	replace bc_mes=7  if ha2>=25 & ha2<=28
	replace bc_mes=8  if ha2>=29 & ha2<=32
	replace bc_mes=9  if ha2>=33 & ha2<=36
	replace bc_mes=10 if ha2>=37 & ha2<=40
	replace bc_mes=11 if ha2>=41 & ha2<=44
	replace bc_mes=12 if ha2>=45 & ha2!=.

g bc_anio=1990
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
destring pe5, replace
recode pe5 (8 =-9), g(bc_pe5) // para este año dejo la codificación de 1991 etc
	replace bc_pe5 =-9 if bc_pe3<14 & bc_pe3!=-15
*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-13

g bc_pe6a1=-13

g bc_pe6b=-13

*-------------------------------------------------------------------------------
* 3- Educación

*asiste 
recode asist (0 . =-15), g(bc_pe11)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
/*
g bc_pe12=-15
	replace bc_pe12=-9 if bc_pe11==1
	replace bc_pe12=1 if bc_pe11==2&nivel>0
	replace bc_pe12=2 if bc_pe11==2&nivel==0
*/
gen bc_pe12 = -13	
	
*asistencia actual pco o privada
g bc_pe13=-13

*nivel 
g bc_nivel=-15
	replace bc_nivel=0 if nivel==0 | nivel==1 & anios==0
	replace bc_nivel=1 if nivel==1 & anios>0 & anios!=.
	replace bc_nivel=2 if nivel==2 | nivel==3
	replace bc_nivel=3 if nivel==4 
	replace bc_nivel=4 if nivel==5
	replace bc_nivel=5 if nivel==6 | nivel==7

*años de educación
/* 
Supuestos para armar edu 
-> nivel==2 secundaria es de 1° a 4°
-> nivel==3 preparatorios es 5° y 6° 
*/
g bc_edu=-15
	replace bc_edu=0 if bc_nivel==0

*Primaria
	replace bc_edu=anios if bc_nivel==1 & anios<=6
	replace bc_edu=6 if bc_nivel==1 & anios>6

*Secundaria	
	replace bc_edu=6+anios if bc_nivel==2&nivel==2
	replace bc_edu=6+4+anios if bc_nivel==2&nivel==3

*UTU actual
	replace bc_edu=6+anios if bc_nivel==3&anios<=6
	replace bc_edu=12 if bc_nivel==3&anios>6

*magisterio
	replace bc_edu=anios+12 if bc_nivel==4&anios<=4
	replace bc_edu=16 if bc_nivel==4&anios>4

*Terciaria
	replace bc_edu=12+anios if bc_nivel==5
	
recode bc_edu (23/38 =22) (. =-15)

*finalizó
g bc_finalizo=-13

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad
g bc_pobp=-15
	replace bc_pobp=1 if pobpcoa2==6
	replace bc_pobp=2 if pobpcoa2==1
	replace bc_pobp=3 if pobpcoa2==3
	replace bc_pobp=4 if pobpcoa2==2
	replace bc_pobp=5 if pobpcoa2==4
	replace bc_pobp=6 if inactivo==2
	replace bc_pobp=7 if inactivo==1
	replace bc_pobp=8 if inactivo==4
	replace bc_pobp=9 if inactivo==3
	replace bc_pobp=11 if inactivo==5|inactivo==6
	replace bc_pobp=11 if pobpcoa2==5&inactivo==.

* Categoría de ocupación
recode pf41 (8=7) (0 9 .=-9), g(bc_pf41)
	/* OJO!! en el período los trabajadores agropecuarios están aparte
	 pf41==9 son los trabajadores agropec, sus categorias de ocup están en catag
	 en otras variables del mercado de trabajo tienen la información aparte
	 pej: hrstragr pqnotr30 mayngr tpotragr otraocup tipoempl tieneoo tamestag tamayact catag 
	*/
	replace bc_pf41=catag if agropec==1&bc_pobp==2
	
recode pf41 (4=3) (5 6=4) (3 7 8=5) (0 9 .=-15), g(bc_cat2)
	replace bc_cat2=1 if catag==1&agropec==1&bc_pobp==2
	replace bc_cat2=2 if catag==2&agropec==1&bc_pobp==2
	replace bc_cat2=3 if catag==4&agropec==1&bc_pobp==2
	replace bc_cat2=4 if (catag==5|catag==6)&agropec==1&bc_pobp==2
	replace bc_cat2=5 if (catag==3|catag==7|catag==8)&agropec==1&bc_pobp==2

* Tamaño del establecimiento
g bc_pf081=-15
	replace bc_pf081=1 if tamest>0&tamest<10
	replace bc_pf081=2 if tamest>9&tamest<9999
	replace bc_pf081=1 if tamestag>0&tamestag<10&agropec==1
	replace bc_pf081=2 if tamestag>9&tamestag<9999&agropec==1
	replace bc_pf081=-9 if bc_pobp==1|bc_pobp>2

g bc_pf082=-15
	replace bc_pf082=1 if tamest==1|(tamestag==1&agropec==1)
	replace bc_pf082=2 if tamest>1&tamest<5|(tamestag>1&tamestag<5&agropec==1)
	replace bc_pf082=3 if tamest>4&tamest<10|(tamestag>4&tamestag<10&agropec==1)
	replace bc_pf082=-9 if bc_pf081==2

* Rama del establecimiento
recode pf40 (. 0=-15), g(bc_pf40)

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
	replace bc_pf053=hrstragr  if agropec==1&bc_pobp==2
g bc_pf06=-13

g bc_horas_sp=bc_pf053 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=bc_pf051 // horas semanales trabajadas semana pasada en trabajo principal

g bc_horas_hab=-13 // horas semanales habitualmente trabajadas en total
g bc_horas_hab_1=-13 // horas semanales habitualmente trabajadas en trabajo principal

* Motivo por el que no trabaja
recode pqnotra (3=1) (5 =3) (1 4 6=4) (0 .=-15), g(bc_pf04)
	replace bc_pf04=-9 if bc_pobp!=2

* Busqueda de trabajo
// buscó trabajo la semana pasada
recode pf21 (5 6 =-15) (.=-15), g(bc_pf21) 
	replace bc_pf21=-9 if bc_pobp==1|bc_pobp==2 // sigo criterio de salto para ocupados

// causa por la que no buscó trabajo
recode pqnobus (1=2) (2=1) (3/5=4) (.=-15), g(bc_pf22) 
	replace bc_pf22=-9 if bc_pf21!=2

* Duración desempleo (semanas)
recode pf26 (.=-15), g(bc_pf26)
	replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

// causas por las que dejó último trabajo
recode pqdejo (4=2) (7=1) (1/3 5 6 8=3) (0 .=-15), g(bc_pf34)
	replace bc_pf34=-9 if bc_pobp<4

* Trabajo registrado
g bc_reg_disse=-13 // esta variable estaba generada en el do 'calidad de empleo'

g bc_register=-13
g bc_register2=-13

* Subocupado
g bc_subocupado=-13
g bc_subocupado1=-13

*-------------------------------------------------------------------------------
* ipc
g bc_ipc=-15
replace bc_ipc=57.8680593712128 if bc_mes==1&bc_anio==1990
replace bc_ipc=55.0768633394332 if bc_mes==2&bc_anio==1990
replace bc_ipc=51.5434515496232 if bc_mes==3&bc_anio==1990
replace bc_ipc=47.2993435913554 if bc_mes==4&bc_anio==1990
replace bc_ipc=44.1996313704897 if bc_mes==5&bc_anio==1990
replace bc_ipc=41.8549438928595 if bc_mes==6&bc_anio==1990
replace bc_ipc=38.1938716284292 if bc_mes==7&bc_anio==1990
replace bc_ipc=36.154002948521 if bc_mes==8&bc_anio==1990
replace bc_ipc=34.2473682312212 if bc_mes==9&bc_anio==1990
replace bc_ipc=29.8683734986136 if bc_mes==10&bc_anio==1990
replace bc_ipc=28.0531992418978 if bc_mes==11&bc_anio==1990
replace bc_ipc=26.6459482910339 if bc_mes==12&bc_anio==1990

g bc_ipc_nuevo=-13
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* Drop servicio doméstico y sin hogar

preserve 
keep if bc_pe4==7
save "$rutainterm/servdom90",replace
restore
drop if bc_pe4==7

