/* 
	vardef_trabajo.do
	Genera variables de mercado laboral 2011–2019
*/

// Categoría ocupacional

* categoría de ocupación principal
recode `catocup_op', gen(bc_pf41)
* categoría de ocupación secundaria
recode `catocup_os', gen(bc_pf41o)

* versión corta
recode bc_pf41 (4 = 3) (5 6 = 4) (3 7 = 5) , gen(bc_cat2)

* dummies de categorías

* trabajo independiente (coop, patrón, cprop)
loc independiente_op "inrange(f73, 3, 6)"
loc independiente_os "inrange(f92, 3, 6)"


* trabajo dependiente
gen dependiente_op = inlist(bc_pf41,  1,2,7,8)
gen dependiente_os = inlist(bc_pf41o, 1,2,7)
* asalariados
gen asal_op = inlist(bc_pf41,  1,2,8)
gen asal_os = inlist(bc_pf41o, 1,2)
* dependiente público o privado en ocupación principal
gen deppri_op = bc_pf41  == 1
gen deppri_os = bc_pf41o == 1
gen deppub_op = inlist(bc_pf41, 2, 8)
gen deppub_os = bc_pf41o == 2

* trabajo independiente (coop, patrón, cprop)
gen independiente_op = inlist(bc_pf41,  3,4,5,6)
gen independiente_os = inlist(bc_pf41o, 3,4,5,6)

// características del establecimiento
	
* Tamaño del establecimiento
recode `pf081', gen(bc_pf081)
recode `pf082', gen(bc_pf082)

* ciiu ocupacion principal y ocupacion secundaria
clonevar ciiu_op = `ciiu_op'
clonevar ciiu_os = `ciiu_os'

* Rama del establecimiento
destring `ciiu_op', replace
clonevar bc_pf40 = `ciiu_op'

* locals con códigos ciiu correspondientes a cada rama,
*	en distintas versiones del ciiu
include "$SRC_LIB/local_ciiu_rama8.do"

* Rama a 8 niveles
g bc_rama=.c
	replace bc_rama=1 if `ciiu`ciiurev'_1'
	replace bc_rama=2 if `ciiu`ciiurev'_2'
	replace bc_rama=3 if `ciiu`ciiurev'_3'
	replace bc_rama=4 if `ciiu`ciiurev'_4'
	replace bc_rama=5 if `ciiu`ciiurev'_5'
	replace bc_rama=6 if `ciiu`ciiurev'_6'
	replace bc_rama=7 if `ciiu`ciiurev'_7'
	replace bc_rama=8 if `ciiu`ciiurev'_8'

// características de la ocupación

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

// empleo

* Cantidad de empleos
recode `pf07', gen(bc_pf07)

* Horas trabajadas habitualmente/semana pasada –– total/op
egen bc_horas_hab    = rowtotal(`bc_horas_hab')
egen bc_horas_hab_op = rowtotal(`bc_horas_hab_op')
egen bc_horas_sp     = rowtotal(`bc_horas_sp')
egen bc_horas_sp_op  = rowtotal(`bc_horas_sp_op')
* fix: 0 = no corresponde, -13 = no disponible este año
recode bc_horas_hab*     (0 = .c) (-13 = .y)

// preguntas a desempleados

* Motivo por el que no trabaja
recode `pf04', gen(bc_pf04)

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
