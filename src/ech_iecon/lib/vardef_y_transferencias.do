// vardef_y_transferencias.do
// Ingreso por transferencias monetarias y en especie

//  #1 -------------------------------------------------------------------------
//  Transferencias jubilaciones y pensiones ------------------------------------

egen YTRANSF_1 = rowtotal(`ytransf_jyp')

//  #2 -------------------------------------------------------------------------
//  Políticas sociales: transferencias monetarias ------------------------------

// Asignaciones Familiares (no incluídas en el sueldo)

gen    YTRANSF_2 = g257 if g256!=1
recode YTRANSF_2 (. = 0)

// Hogar Constituido

gen    YTRANSF_3 = mto_hogc if (g149==1 & g149_1==2)
recode YTRANSF_3 (. = 0)

//  #3 -------------------------------------------------------------------------
//  Políticas sociales: ingresos por alimentación ------------------------------

// Transferencias en especie: Alimentos

* recodifico 99s a missing
recode `desaymer' `almycen' (99 = .q)

* numero de desayunos/meriendas y número de almuerzos/cenas
foreach varl in desaymer almycen {
	egen n_`varl' = rowtotal(``varl'')
}

gen DESAYMER = n_desaymer * 4.3 * mto_desa

gen ALMYCEN  = n_almycen  * 4.3 * mto_almu

gen         CANASTA1 = 0
cap replace CANASTA1 = e247*indabajo if e246 == 1
cap replace CANASTA1 = e247*indaplom if e246 == 2
cap replace CANASTA1 = e247*indadiab if e246 == 4
cap replace CANASTA1 = e247*indarena if e246 == 5
cap replace CANASTA1 = e247*indarend if e246 == 6
cap replace CANASTA1 = e247*indaceli if e246 == 7
cap replace CANASTA1 = e247*indatube if e246 == 8
cap replace CANASTA1 = e247*indaonco if e246 == 9
cap replace CANASTA1 = e247*indasida if e246 == 10
cap replace CANASTA1 = e247*indaemer if e246 == 14
	
gen         CANASTA2 = 0
cap replace CANASTA2 = e249*indabajo if e248 == 1
cap replace CANASTA2 = e249*indaplom if e248 == 2
cap replace CANASTA2 = e249*indadiab if e248 == 4
cap replace CANASTA2 = e249*indarena if e248 == 5
cap replace CANASTA2 = e249*indarend if e248 == 6
cap replace CANASTA2 = e249*indaceli if e248 == 7
cap replace CANASTA2 = e249*indatube if e248 == 8
cap replace CANASTA2 = e249*indaonco if e248 == 9
cap replace CANASTA2 = e249*indasida if e248 == 10
cap replace CANASTA2 = e247*indaemer if e248 == 14

gen    CANASTA = CANASTA1 + CANASTA2
recode CANASTA (. = 0)

drop CANASTA1 CANASTA2

// Otras transferencias de alimientación

* tarjetas tus-mides y tus-inda
gen tusmides = `y_tusmides'
gen tusinda  = `y_tusinda'
egen tus       = rowtotal(tusmides tusinda)

* tickets de alimentación del inda
gen ticketsinda = `y_ticketsinda'

* leche en polvo
gen     leche  = `y_lecheenpolvo'
*replace leche  = 0 if inlist(e246, 1, 7) & e560==2 // Ver sintaxis 2018 (por qué hacemos replace?)

//  Se genera una variable de alimentos separando entre mayores y menores de 14

egen yalim_tot     = rowtotal(DESAYMER ALMYCEN CANASTA tus ticketsinda leche)
gen  YALIMENT      = yalim_tot if bc_pe3>=14
gen  YALIMENT_MEN1 = yalim_tot if bc_pe3< 14
recode YALIMENT YALIMENT_MEN1 (. = 0)

gen YTRANSF_4 = YALIMENT

egen    YALIMENT_MEN = sum(YALIMENT_MEN1), by(bc_correlat)
replace YALIMENT_MEN = 0 if !esjefe


//  #4 -------------------------------------------------------------------------
//  total de transferencias ----------------------------------------------------
* 	–– asumo que para mayores de 14 dado el tratamiento de YTRANSF_4 / gsl 2021-08-31

egen YTRANSF = rowtotal(YTRANSF_1 YTRANSF_2 YTRANSF_3 YTRANSF_4)

