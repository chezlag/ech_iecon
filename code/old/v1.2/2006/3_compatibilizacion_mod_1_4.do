*3_ ----------------------------------------------------------------------------
* Variables de identificación general
rename numero bc_correlat 
rename nper bc_nper 

g bc_filtloc=(region_4<3) // localidades de más de 5000 
recode bc_filtloc (0=2)

rename pesoano bc_pesoan
rename mes bc_mes
rename anio bc_anio
rename dpto bc_dpto
rename ccz bc_ccz
recode bc_ccz (0=-9)
g bc_area=region_4

*-------------------------------------------------------------------------------
* 1- Características generales y de las personas

* sexo
g bc_pe2=e26

* edad
g bc_pe3=e27

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if e31==1
	replace bc_pe4=2 if e31==2
	replace bc_pe4=3 if e31==3|e31==4|e31==5
	replace bc_pe4=4 if e31==7|e31==8
	replace bc_pe4=5 if e31==6|e31==9|e31==10|e31==11|e31==12 
	replace bc_pe4=6 if e31==13
	replace bc_pe4=7 if e31==14

* estado civil
g bc_pe5=-9
	replace bc_pe5=1 if e36==2
	replace bc_pe5=2 if e36==1
	replace bc_pe5=3 if e36==0&(e37==1|e37==2)
	replace bc_pe5=4 if e36==0&(e37==3)
	replace bc_pe5=5 if e36==0&(e37==4)

*-------------------------------------------------------------------------------
* 2- Atención de la Salud

g bc_pe6a=-15
	replace bc_pe6a=2 if e42_7==1 & e44_1!=3
	replace bc_pe6a=3 if e42_7==1 & e44_1==3
	replace bc_pe6a=4 if (e42_1==1|e42_2==1|e42_3==1|e42_4==1|e42_5==1|e42_6==1)&(e42_7!=1&e42_8!=1&e42_9!=1&e42_10!=1&e45!=1)
	replace bc_pe6a=5 if (e42_8==1|e42_9==1|e42_10==1|e45==1) & (e42_7!=1)
	replace bc_pe6a=1 if e42_1!=1 & e42_2!=1 & e42_3!=1 & e42_4!=1 & e42_5!=1&e42_6!=1&e42_7!=1&e42_8!=1&e42_9!=1&e42_10!=1&e45!=1

g bc_pe6a1=-15
	replace bc_pe6a1=1 if bc_pe6a==3 & ((pobpcoac==2 & (f78==1|f91==1)) | pobpcoac==5)
	replace bc_pe6a1=2 if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=-9 if bc_pe6a!=3
	
recode bc_pe6a (2/3=2) (4=3) (5=4), gen(bc_pe6b)
replace bc_pe6b=-9 if bc_pe6a==3
*-------------------------------------------------------------------------------
* 3- Educación

*asiste
recode e48 (.=-15) (0=-15), g(bc_pe11)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
recode e51 (0 =-9), g(bc_pe12)
    replace bc_pe12=-15 if bc_pe11==-15&bc_pe12==-9
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.
	
*asistencia actual pco o privada
recode e49 (0 =-9), g(bc_pe13)
	replace bc_pe13=-15 if bc_pe11==-15&bc_pe12==-15
	
*nivel 
g bc_nivel=-13
g nivel_aux=-15

 replace nivel_aux=0 if bc_pe11==0 & bc_pe12==0 // nunca asistió
 replace nivel_aux=0 if (e48==2&e51==2) | (e48==1&e51==0&e50_1>0)
 replace nivel_aux=1 if (e48==1&e51==0&(e50_2>0|e50_3>0)) | ((e48==2&e51==1)&e52_1_1>0&e52_1_1!=.)
 replace nivel_aux=2 if (e48==1&e51==0&(e50_4>0|e50_5>0|e50_6>0|e50_8>0)) | ((e48==2&e51==1)&e52_2_1>0&e52_2_1!=.)
 replace nivel_aux=3 if (e48==1&e51==0&(e50_7>0)) | ((e48==2&e51==1)&e52_3_1>0&e52_3_1!=.) 
 replace nivel_aux=4 if (e48==1&e51==0&(e50_9>0)) | ((e48==2&e51==1)&e52_4_1>0&e52_4_1!=.)
 replace nivel_aux=5 if (e48==1&e51==0&(e50_10>0|e50_11>0|e50_12>0)) | ((e48==2&e51==1)&((e52_5_1>0&e52_5_1!=.)|(e52_6_1>0&e52_6_1!=.)|(e52_7_1>0&e52_7_1!=.)))

* Modifico años cursados para los que cursan actualmente
forvalues i=2/12 {
g e50_`i'm = e50_`i'-1 
 replace e50_`i'm = 0 if e50_`i'==0
}

*años de bc_educación
g bc_edu=-15

*Primaria
 replace bc_edu=0 if nivel_aux==0
 replace bc_edu=e50_2m+e50_3m if nivel_aux==1 & (e48==1&e51==0) //esto se puede hacer para 2006
 replace bc_edu=e52_1_1 if nivel_aux==1 & (e48==2&e51==1)

*Secundaria
 replace bc_edu=6+e50_4m+e50_5m+e50_6m+e50_8m if nivel_aux==2 & (e48==1&e51==0) //esto se puede hacer para 2006
 replace bc_edu=6+e52_2_1 if nivel_aux==2 & (e48==2&e51==1)
 
* UTU 
 replace bc_edu=6+e50_7m if nivel_aux==3 & (e48==1&e51==0) 
 replace bc_edu=6+e52_3_1 if nivel_aux==3 & (e48==2&e51==1) 
 
*Magisterio
 replace bc_edu=12+e50_9m if nivel_aux==4 & (e48==1&e51==0)
 replace bc_edu=12+e52_4_1 if nivel_aux==4 & (e48==2&e51==1) 

*Terciaria
 replace bc_edu=12+e50_10m+e50_11m if nivel_aux==5 & (e48==1&e51==0) & e50_12m==0
 replace bc_edu=17+e50_12m if nivel_aux==5 & (e48==1&e51==0) & e50_12>0 & e50_12!=. //para los posgrados asumo 12+5
 replace bc_edu=12+e52_5_1+e52_6_1 if nivel_aux==5 & (e48==2&e51==1) & e52_7_1==0
 replace bc_edu=17+e52_7_1 if nivel_aux==5 & (e48==2&e51==1) & e52_7_1>0 & e52_7_1!=. //para los posgrados asumo 12+5

recode bc_edu 23/38=22
drop e50_2m-e50_12m

*finalizó
g bc_finalizo=-13

*-------------------------------------------------------------------------------
* 4- Mercado de trabajo

* Condición de actividad
recode pobpcoac (10=9), g(bc_pobp)

* Categoría de ocupación
recode f69 (8=7) (0=-9), g(bc_pf41)

recode f69 (4=3) (5 6=4) (3 7 8=5) (0=-9), g(bc_cat2)

* Tamaño del establecimiento
recode f75 (2 3=1) (4 5=2) (0=-9),g(bc_pf081)

recode f75 (4 5 0 =-9), g(bc_pf082)

* Rama del establecimiento
g f68_2a=f68_2
	replace f68_2a="" if f68_2=="X211"
	replace f68_2a="" if f68_2=="<"
	replace f68_2a="" if f68_2=="+512"
	replace f68_2a="" if f68_2=="15 4"
destring f68_2a, replace
g bc_pf40=f68_2a

g bc_rama=-15
g ram_aux=trunc(f68_2a/100) 
	replace bc_rama=1 if ram_aux>0 &ram_aux<=14&bc_pobp==2 // CIIU3
	replace bc_rama=2 if ram_aux>14&ram_aux<40&bc_pobp==2 
	replace bc_rama=3 if ram_aux>39&ram_aux<42&bc_pobp==2
	replace bc_rama=4 if ram_aux==45&bc_pobp==2
	replace bc_rama=5 if ram_aux>45&ram_aux<=55&bc_pobp==2 
	replace bc_rama=6 if ram_aux>55&ram_aux<=64&bc_pobp==2 
	replace bc_rama=7 if ram_aux>64&ram_aux<75&bc_pobp==2
	replace bc_rama=8 if ram_aux>74&ram_aux!=.&bc_pobp==2
	replace bc_rama=-9 if bc_rama==-15&bc_pobp!=2
drop ram_aux f68_2a

* Tipo de ocupación
g f67_2a=f67_2
	replace f67_2a="" if f67_2=="X211"
destring f67_2a, replace
g bc_pf39=f67_2a
	replace bc_pf39=-9 if bc_pf39==.&bc_pobp!=2
	replace bc_pf39=-15 if bc_pf39==.&bc_pobp==2
drop f67_2a

g pf39aux=bc_pf39
	replace pf39aux=0 if bc_pf39>0&bc_pf39<130

g bc_tipo_ocup=trunc(pf39aux/1000)
	replace bc_tipo_ocup=-9 if bc_tipo_ocup==0&bc_pobp!=2
drop pf39aux

* Cantidad de empleos
recode f66 (0=-9), g(bc_pf07)

* Horas trabajadas
g bc_pf051=-13
g bc_pf052=-13
g bc_pf053=-13
g bc_pf06=-13

g bc_horas_hab=f81+f93  // horas semanales trabajadas habitualmente en total
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f81    // horas semanales trabajadas habitualmente en trabajo principal
recode bc_horas_hab_1 (0=-9)
g bc_horas_sp=-13 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=-13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
recode f65 (3=4) (4=3) (0=-9), g(bc_pf04)
	replace bc_pf04=-9 if bc_pobp!=2

* Busqueda de trabajo
// buscó trabajo la semana pasada
recode f102 (0=-9), g(bc_pf21) 
	replace bc_pf21=-9 if bc_pobp==1|bc_pobp==2 // parece que salta para ocupados

// causa por la que no buscó trabajo
recode f103 (1 5=4) (2=1) (3=2) (4=3) (0=-9), g(bc_pf22) 
	replace bc_pf22=-9 if bc_pf21!=2

* Duración desempleo (semanas)
g bc_pf26=f108
	replace bc_pf26=-9 if bc_pobp<3|bc_pobp>5

// causas por las que dejó último trabajo
recode f117 (1=2) (2=1) (4/9=3) (0=-9), g(bc_pf34)

* Trabajo registrado
g bc_reg_disse=-9 // esta variable estaba generada en el do 'calidad de empleo'
	replace bc_reg_disse=1 if (e44_1==3|bc_pf41==2)&bc_pobp==2
	replace bc_reg_disse=2 if (e44_1!=3&bc_pf41!=2)&bc_pobp==2

g bc_register=-9
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2&f78==1

g bc_register2=-9
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2&(f78==1|f91==1)

* Subocupado
g bc_subocupado=-9
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if f97==1&f99==4&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=.
	
g bc_subocupado1=-9
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f97==1|f96==2)&f98==1&f99==4&f100!=6&bc_horas_hab>0&bc_horas_hab<40&bc_horas_hab!=. 

*-------------------------------------------------------------------------------
* ipc
g bc_ipc=-15
replace bc_ipc=1.06379962192817 if bc_mes==1 & bc_anio==2006
replace bc_ipc=1.04946617557928 if bc_mes==2 & bc_anio==2006
replace bc_ipc=1.0425157465728 if bc_mes==3 & bc_anio==2006
replace bc_ipc=1.03919486634966 if bc_mes==4 & bc_anio==2006
replace bc_ipc=1.03380178194177 if bc_mes==5 & bc_anio==2006
replace bc_ipc=1.02733786682488 if bc_mes==6 & bc_anio==2006
replace bc_ipc=1.02406623902461 if bc_mes==7 & bc_anio==2006
replace bc_ipc=1.01542764345002 if bc_mes==8 & bc_anio==2006
replace bc_ipc=1.0074743767623 if bc_mes==9 & bc_anio==2006
replace bc_ipc=1.00209232960869 if bc_mes==10 & bc_anio==2006
replace bc_ipc=1.00410384512445 if bc_mes==11 & bc_anio==2006
replace bc_ipc=1.00374565236779 if bc_mes==12 & bc_anio==2006

g bc_ipc_nuevo=-13
g bc_ipc_tot=bc_ipc

*-------------------------------------------------------------------------------
* Drop servicio doméstico
preserve 
keep if bc_pe4==7
save "$rutainterm/servdom6",replace
restore
drop if bc_pe4==7
	
	
