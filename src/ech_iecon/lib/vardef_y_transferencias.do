// vardef_y_transferencias.do
// Ingreso por transferencias monetarias y en especie

//  #1 -------------------------------------------------------------------------
//  Transferencias jubilaciones y pensiones ------------------------------------

#del ;
local ytransf_jyp "g148_1_1 g148_1_2  g148_1_3  g148_1_4  g148_1_5  g148_1_6
	g148_1_7      g148_1_8  g148_1_9  g148_1_12 g148_1_10 g148_1_11 g148_2_1
	g148_2_2      g148_2_3  g148_2_4  g148_2_5  g148_2_6  g148_2_7  g148_2_8
	g148_2_9      g148_2_12 g148_2_10 g148_2_11 g148_3    g148_4    g148_5_1
	g148_5_2      g153_1    g153_2";
#del cr

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
local desaymer "e559_1 e196_1 e196_3 e200_1 e200_3 e211_1 e211_3"
local almycen  "e559_2 e196_2 e200_2 e211_2"
recode `desaymer' `almycen' (99 = .q)

* numero de desayunos/meriendas y número de almuerzos/cenas
foreach varl in desaymer almycen {
	egen n_`varl' = rowtotal(``varl'')
}

gen DESAYMER = n_desaymer * 4.3 * mto_desa

gen ALMYCEN  = n_almycen  * 4.3 * mto_almu

gen     CANASTA = e247*indaceli if e246==7
replace CANASTA = e247*indaemer if e246==14
recode  CANASTA (. = 0)

// Tarjetas TUS-MIDES y TUS-INDA

gen  tusmides  = e560_1_1
gen  tusinda   = e560_2_1
egen tus       = rowtotal(tusmides tusinda)
gen     leche  = e561_1 * lecheenpol 
replace leche  = 0 if inlist(e246, 1, 7) & e560==2 // Ver sintaxis 2018 (por qué hacemos replace?)

//  Se genera una variable de alimentos separando entre mayores y menores de 14

egen yalim_tot     = rowtotal(DESAYMER ALMYCEN tus CANASTA leche)
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

