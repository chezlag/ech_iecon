*3_ ----------------------------------------------------------------------------
* Variables de identificación general
rename correlat bc_correlat 
rename nper bc_nper 

g bc_filtloc=1
/*- Nota: 
De 1998 - 2005 representativo de localidades de más de 5000 hab.
*/

rename pesoan bc_pesoan
rename mes bc_mes
rename anio bc_anio
rename dpto bc_dpto
rename ccz bc_ccz
recode bc_ccz (0=-9)
g bc_area=-13

*-------------------------------------------------------------------------------
* 1- Características generales y de las personas

* sexo
g bc_pe2=e1

* edad 
g bc_pe3=e2

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if e3==1
	replace bc_pe4=2 if e3==2
	replace bc_pe4=3 if e3==3|e3==4|e3==5
	replace bc_pe4=4 if e3==8
	replace bc_pe4=5 if e3==6|e3==7|e3==9
	replace bc_pe4=6 if e3==11
	replace bc_pe4=7 if e3==10

* estado civil
recode e4 (2=1) (1=2) (4=3) (5=4) (6=5) (. =-9), g(bc_pe5)
	replace bc_pe5 =-9 if bc_pe3<14 & bc_pe3!=-15
*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-15
	replace bc_pe6a=2 if e5==1&e6!=1
	replace bc_pe6a=3 if e6==1&e5==1
	replace bc_pe6a=4 if (e8_1==1|e8_2==1|e8_3==1|e8_4_1==1)&e5!=1&e7!=1
	replace bc_pe6a=5 if e7==1&e5!=1
	replace bc_pe6a=1 if e5!=1&e7!=1&e8_1!=1&e8_2!=1&e8_3!=1&e8_4_1!=1

g bc_pe6a1=-15
	replace bc_pe6a1=1 if bc_pe6a==3 & ((pobpcoac==2 & (f10_1==1|f16_1==1)) | pobpcoac==5)
	replace bc_pe6a1=2 if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=-9 if bc_pe6a!=3
	
recode bc_pe6a (2/3=2) (4=3) (5=4), gen(bc_pe6b)
replace bc_pe6b=-9 if bc_pe6a==3
*-------------------------------------------------------------------------------
* 3- Educación

*asiste 
recode e9 (.=-15), g(bc_pe11)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
recode e10 (0=-9) (.=-15), g(bc_pe12) 
	replace bc_pe12=-9 if bc_pe11==1&(bc_pe12==-15|bc_pe12==1)
	replace bc_pe12=-9 if bc_pe11==1&bc_pe12==2
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.
	
*asistencia actual pco o privada 
recode e14 (0=-9) (8 .=-15), g(bc_pe13)
	replace bc_pe13=-9 if bc_pe11==2&bc_pe13==-15
	replace bc_pe13=-9 if bc_pe11==2&bc_pe13>0 // los que no asisten actualmente
	
*nivel 
g bc_nivel=-13
g nivel_aux=-15

replace nivel_aux=0 if e11_2==0
replace nivel_aux=0 if e11_2==0.5
replace nivel_aux=1 if (e11_2<=6 & e11_2>0.5) &  (e11_3==0 & e11_4==0) 
replace nivel_aux=2 if (e11_3>0) & (e11_4==0) & (e11_3<=6)
replace nivel_aux=3 if (e11_4>0) & e11_6==0 & e11_5==0
replace nivel_aux=4 if e11_5>0 & e11_6==0 
replace nivel_aux=5 if e11_6>0

gen bc_edu=-15
replace bc_edu=0 if nivel_aux==0
*primaria
replace bc_edu= e11_2 if nivel_aux==1

*secundaria
replace bc_edu=6+e11_3 if nivel_aux==2 
replace bc_edu=6 if nivel_aux==2  & e11_3==0.5

*utu
replace bc_edu=6+e11_4 if nivel_aux==3
replace bc_edu=6 if  nivel_aux==3 & e11_4==0.5

*Terciaria
replace bc_edu=e11_5+12 if nivel_aux==4 & e11_5<=4
replace bc_edu=16 if nivel_aux==4 & e11_5>4 
replace bc_edu=e11_6+12 if nivel_aux==5 
replace bc_edu=12 if  nivel_aux==4 & e11_5==0.5
replace bc_edu=12 if  nivel_aux==5 & e11_6==0.5

recode bc_edu (23/38 =22)

*finalizó
recode e13 (0=-9), g (bc_finalizo)

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad

recode pobpcoac (9/10=9), g(bc_pobp)

* Categoría de ocupación

gen bc_pf41 = f7

recode bc_pf41 (0 .=-9)

recode bc_pf41 (1=1) (2=2) (4=3) (5/6=4) (3/8=5), g(bc_cat2) 

recode bc_cat2 (0 .=-15)



*recode pf41 (8=7) (0 .=-15), g(bc_pf41)


* Tamaño del establecimiento //1 (menos de 10), 2(10 o más) 
recode f8 (0 .=-15) (1/3=1) (4/5=2) , g(bc_pf081)
	replace bc_pf081=-9 if bc_pobp==1|bc_pobp>2
	replace bc_pf081=-15 if bc_pobp==11&bc_pf081>0
	
* Tamaño del establecimiento por tramos // 1, 2(dos a cuatro), 3 (cinco a nueve)

recode f8 (0 . =-15) (1=1) (2=2) (3=3), g(bc_pf082)
	replace bc_pf082=-15 if f8>3
	replace bc_pf082=-9 if bc_pf081==-9|bc_pf081==2|(bc_pf081==-15&bc_pf082>0)

* Rama del establecimiento
recode f6_2 (0 .=-15), g(bc_pf40)

g bc_rama=-15
replace bc_rama=1 if bc_pf40>0 &bc_pf40<=14&bc_pobp==2 // CIIU3
	replace bc_rama=2 if bc_pf40>14&bc_pf40<40&bc_pobp==2 
	replace bc_rama=3 if bc_pf40>39&bc_pf40<42&bc_pobp==2
	replace bc_rama=4 if bc_pf40==45&bc_pobp==2
	replace bc_rama=5 if bc_pf40>45&bc_pf40<=55&bc_pobp==2 
	replace bc_rama=6 if bc_pf40>55&bc_pf40<=64&bc_pobp==2 
	replace bc_rama=7 if bc_pf40>64&bc_pf40<75&bc_pobp==2
	replace bc_rama=8 if bc_pf40>74&bc_pf40!=.&bc_pobp==2
	replace bc_rama=-9 if bc_rama==-15&bc_pobp!=2

* Tipo de ocupación

recode f5_2 (0 . =-15), g (bc_pf39)
	replace bc_pf39=-9 if bc_pobp!=2
	*replace bc_pf39= 0 if bc_pf39>0&bc_pf39<13&bc_pobp==2 //militares hasta marzo2005  
	replace bc_pf39=-15 if bc_pf39==.&bc_pobp==2

g bc_tipo_ocup=trunc(bc_pf39/100)
	replace bc_tipo_ocup=-9 if bc_pobp!=2
	replace bc_tipo_ocup=-15 if bc_tipo_ocup==.&bc_pobp==2

* Cantidad de empleos
recode f4 (0=-15), g(bc_pf07)
	replace bc_pf07=-9 if bc_pobp!=2

* Horas trabajadas
g bc_pf051= -13
g bc_pf052= -13
g bc_pf053= -13
gen bc_pf06= -13

gen bc_horas_hab_1=f17_1 // horas semanales habituales del trabajo principal
	recode bc_horas_hab_1 (.=-15)
	replace bc_horas_hab_1=-9 if bc_pobp!=2
gen horas_hab_2=f17_2
	recode horas_hab_2 (.=-15)
	replace horas_hab_2=-9 if bc_pobp!=2
gen bc_horas_hab=bc_horas_hab_1+horas_hab_2 // horas semanales habitualmente trabajadas en total
	replace bc_horas_hab=-9 if bc_pobp!=2
	
gen bc_horas_sp= -13 // horas semanales trabajadas semana pasada en total
gen bc_horas_sp_1= -13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
recode f3 (0 .=-9), g(bc_pf04)
	replace bc_pf04=-9 if bc_pobp!=2

* Busqueda de trabajo
// buscó trabajo la semana pasada
recode f23 (0=-9), g(bc_pf21) 
	replace bc_pf21=-9 if bc_pobp==1|bc_pobp==2 // sigo criterio de salto para ocupados

// causa por la que no buscó trabajo
recode f24 (1 5 =4) (2=1) (3=2) (4=3) (.=-9), g(bc_pf22) 
	replace bc_pf22=-9 if bc_pf21!=2

* Duración desempleo (semanas)
recode f29 (.=-15), g(bc_pf26)
	replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

// causas por las que dejó último trabajo
recode f35 (2=1) (3=2) (1 4 5=3) (0 .=-9), g(bc_pf34)
	replace bc_pf34=-9 if bc_pobp<4

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo'
	replace bc_reg_disse=1 if (bc_pf41==2|bc_pe6a==3)&bc_pobp==2
	replace bc_reg_disse=2 if bc_pf41!=2&bc_pe6a!=3 &bc_pobp==2

g bc_register=-9
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2&f10_2==1
	
g bc_register2=-9
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2&(f10_2==1 | f16_2==1)

* Subocupado
g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if (f18==1|f18==2|f18==3)&f20==4&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=. 
	
g bc_subocupado1=-9
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f18==1|f18==2|f18==3)&f19==1&f20==4&f21!=6&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.

*-------------------------------------------------------------------------------
* ipc
g bc_ipc=-15
replace bc_ipc=	1.725962276	if bc_mes==	1	& bc_anio==	2001
replace bc_ipc=	1.720290409	if bc_mes==	2	& bc_anio==	2001
replace bc_ipc=	1.715308999	if bc_mes==	3	& bc_anio==	2001
replace bc_ipc=	1.708928029	if bc_mes==	4	& bc_anio==	2001
replace bc_ipc=	1.695157768	if bc_mes==	5	& bc_anio==	2001
replace bc_ipc=	1.684501983	if bc_mes==	6	& bc_anio==	2001
replace bc_ipc=	1.691972339	if bc_mes==	7	& bc_anio==	2001
replace bc_ipc=	1.677222264	if bc_mes==	8	& bc_anio==	2001
replace bc_ipc=	1.681984607	if bc_mes==	9	& bc_anio==	2001
replace bc_ipc=	1.676847437	if bc_mes==	10	& bc_anio==	2001
replace bc_ipc=	1.672362556	if bc_mes==	11	& bc_anio==	2001
replace bc_ipc=	1.670996956	if bc_mes==	12	& bc_anio==	2001
replace	bc_ipc=	1.66617321	if	bc_mes==1	& bc_anio==	2002
replace	bc_ipc=	1.65174640	if	bc_mes==2	& bc_anio==	2002
replace	bc_ipc=	1.64079015	if	bc_mes==3	& bc_anio==	2002
replace	bc_ipc=	1.62644509	if	bc_mes==4	& bc_anio==	2002
replace	bc_ipc=	1.60065420	if	bc_mes==5	& bc_anio==	2002
replace	bc_ipc=	1.58186929	if	bc_mes==6	& bc_anio==	2002
replace	bc_ipc=	1.55434332	if	bc_mes==7	& bc_anio==	2002
replace	bc_ipc=	1.48228632	if	bc_mes==8	& bc_anio==	2002
replace	bc_ipc=	1.40065957	if	bc_mes==9	& bc_anio==	2002
replace	bc_ipc=	1.35831523	if	bc_mes==10	& bc_anio==	2002
replace	bc_ipc=	1.34532632	if	bc_mes==11	& bc_anio==	2002
replace	bc_ipc=	1.33956201	if	bc_mes==12	& bc_anio==	2002
replace	bc_ipc=	1.32295034	if	bc_mes==1	& bc_anio==	2003
replace	bc_ipc=	1.29867882	if	bc_mes==2	& bc_anio==	2003
replace	bc_ipc=	1.28130692	if	bc_mes==3	& bc_anio==	2003
replace	bc_ipc=	1.26560216	if	bc_mes==4	& bc_anio==	2003
replace	bc_ipc=	1.25368978	if	bc_mes==5	& bc_anio==	2003
replace	bc_ipc=	1.24902896	if	bc_mes==6	& bc_anio==	2003
replace	bc_ipc=	1.24702233	if	bc_mes==7	& bc_anio==	2003
replace	bc_ipc=	1.24083568	if	bc_mes==8	& bc_anio==	2003
replace	bc_ipc=	1.22656931	if	bc_mes==9	& bc_anio==	2003
replace	bc_ipc=	1.21682253	if	bc_mes==10	& bc_anio==	2003
replace	bc_ipc=	1.21047537	if	bc_mes==11	& bc_anio==	2003
replace	bc_ipc=	1.20852572	if	bc_mes==12	& bc_anio==	2003



g bc_ipc_nuevo=-13
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* Drop servicio doméstico y sin hogar

drop _merge

preserve 
keep if bc_pe4==7
save "$rutainterm/servdom3",replace
restore
drop if bc_pe4==7

