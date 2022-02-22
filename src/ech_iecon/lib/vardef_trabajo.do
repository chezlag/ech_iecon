/* 
	vardef_trabajo.do
	Genera variables de mercado laboral 2011–2019
*/

* trabajo dependiente
gen dependiente_op = `dependiente_op'
gen dependiente_os = `dependiente_os'

* trabajo independiente (coop, patrón, cprop)
gen independiente_op = `independiente_op'
gen independiente_os = `independiente_os'

* ciiu ocupacion principal y ocupacion secundaria
clonevar ciiu_op = `ciiu_op'
clonevar ciiu_os = `ciiu_os'

* aslariados en ocupación principal o secundaria
gen asal_op = `asal_op'
gen asal_os = `asal_os'

* dependiente público o privado en ocupación principal
gen deppri_op = `deppri_op'
gen deppri_os = `deppri_os'
gen deppub_op = `deppub_op'
gen deppub_os = `deppub_os'

* categoría de ocupación
recode f73 (8 = 7) (0 = .c) ///
	, gen(bc_pf41)

recode bc_pf41 (4 = 3) (5 6 = 4) (3 7 = 5) ///
	, gen(bc_cat2)
	
* Tamaño del establecimiento
recode f77 (1/3 = 1) (5/7 = 2) (0 = .c) ///
	, gen(bc_pf081)

recode f77 (0 4/7 = .c) ///
	, gen(bc_pf082)

* Rama del establecimiento
destring f72_2, replace
clonevar bc_pf40 = f72_2

g bc_rama=.c
	replace bc_rama=1 if inrange(bc_pf40, 0000, 999)
	replace bc_rama=2 if inrange(bc_pf40, 1000, 3499)
	replace bc_rama=3 if inrange(bc_pf40, 3500, 3699)
	replace bc_rama=4 if inrange(bc_pf40, 4000, 4499)
	replace bc_rama=5 if inrange(bc_pf40, 4500, 4899) | inrange(bc_pf40, 5500, 5699)
	replace bc_rama=6 if inrange(bc_pf40, 4900, 5499) | inrange(bc_pf40, 5800, 6399)
	replace bc_rama=7 if inrange(bc_pf40, 6400, 8299)
	replace bc_rama=8 if inrange(bc_pf40, 8300, 9909) | inrange(bc_pf40, 3700, 3900)

* Tipo de ocupación 
destring f71_2, replace
clonevar bc_pf39 = f71_2
recode   bc_pf39 (. = .c) if bc_pobp!=2
recode   bc_pf39 (. = .q) if bc_pobp==2
	
* tipo de ocupación, alt?
clonevar X1 = bc_pf39
replace  X1 = 0 if inrange(bc_pf39,1,129)
gen     bc_tipo_ocup = trunc(X1/1000)
replace bc_tipo_ocup = .c if bc_tipo_ocup==0&bc_pobp!=2
drop X1

* Cantidad de empleos
recode f70 (0 = .c), gen(bc_pf07)

* Horas trabajadas
g bc_horas_hab=f85+f98 // horas semanales trabajadas habitualmente en total
recode bc_horas_hab (0=-9)
g bc_horas_hab_1=f85   // horas semanales trabajadas habitualmente en trabajo principal
recode bc_horas_hab_1 (0=-9)

g bc_horas_sp=-13 // horas semanales trabajadas semana pasada en total
g bc_horas_sp_1=-13 // horas semanales trabajadas semana pasada en trabajo principal

* Motivo por el que no trabaja
recode f69 (3 5/6 = 4) (4 = 3) (0 = .c) ///
	, gen(bc_pf04)

// preguntas a desempleados

* buscó la semana pasada?
recode f107 (0 = .c), gen(bc_pf21)

* causa por la que no buscó trabajo
recode f108 (1=4) (2=1) (3=2) (4=3) (5/6=4) (0=.c) ///
	, gen(bc_pf22)

* Duración desempleo (semanas)
clonevar bc_pf26 = f113
replace  bc_pf26 = .c   if !inrange(bc_pobp, 3, 5)

* causas por las que dejó último trabajo
recode f122 (1=2) (2=1) (4/9=3) (0=.c) ///
	, gen(bc_pf34)

// calidad de empleo

* Trabajo registrado
* g bc_reg_disse=.c // esta variable estaba generada en el do 'calidad de empleo' (que iba hasta 2010)
* 	replace bc_reg_disse=2 if bc_pobp==2
* 	replace bc_reg_disse=1 if bc_pobp==2

gen    bc_reg_disse = (ss_fonasa_o_h==1 | deppub_op==1) if bc_pobp==2
recode bc_reg_disse (. = .c)

g bc_register=.c
	replace bc_register=2 if bc_pobp==2
	replace bc_register=1 if bc_pobp==2 & formal_op==1

g bc_register2=.c
	replace bc_register2=2 if bc_pobp==2
	replace bc_register2=1 if bc_pobp==2 & formal==1

* Subocupado
g bc_subocupado=.c
	replace bc_subocupado=2 if bc_pobp==2
	replace bc_subocupado=1 if f102==1 & f104==5 & inrange(bc_horas_hab,1,39) & bc_horas_hab<.

g bc_subocupado1=.c
	replace bc_subocupado1=2 if bc_pobp==2
	replace bc_subocupado1=1 if (f101==1|f102==1) & f103==1 & f104==5 & f105!=7 & inrange(bc_horas_hab,1,39) & bc_horas_hab<.
