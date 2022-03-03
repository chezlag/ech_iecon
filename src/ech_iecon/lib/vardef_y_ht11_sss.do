/* 
	vardef_y_ht11_sss.do
	Definimos agregados por rubros IECON, incluído el ht11 sin seguro de salud
*/

//  #1 -------------------------------------------------------------------------
//  fixes previos --------------------------------------------------------------

* fix: creo variables de ingresos agropecuarios que ya no se preguntan
gen bc_pa11 = 0
gen bc_pa12 = 0
gen bc_pa13 = 0
gen bc_pa21 = 0
gen bc_pa22 = 0
gen bc_pa31 = 0
gen bc_pa32 = 0
gen bc_pa33 = 0

gen bc_as_agropec  = 0
gen bc_cp_agropec  = 0
gen bc_pat_agropec = 0
gen bc_ot_agropec  = 0

* fix: pasamos ingresos de seguro de desempleo (encubierto) a su propia variable
* 	son personas que están en el seguro de paro y la ech los identifica como ocupados. 
* 	suponemos que los ingresos que declaran en su ocupación principal son en realidad 
*	ingresos por seguro de paro
* ---- esta variable no tiene sentido xq crean pf04==0 y después condicionan 
*	   en base pf04==7 / gsl 2022-02-21

cap g pf04=0
gen    bc_seguro=(bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p+bc_pg71p+bc_pg73p+bc_pg71o+bc_pg73o)/bc_deflactor if bc_pobp==2 & pf04==7 & (bc_pg101==0 | bc_pg101!=.) // & bc_anio<2001
recode bc_seguro (.=0)


//  #2 -------------------------------------------------------------------------
//  ingresos laborales ---------------------------------------------------------

// ingresos por categoría ocupacional --------------------------------

loc as_privados "bc_pg11p bc_pg12p bc_pg14p bc_pg15p bc_pg16p bc_pg17p"
loc as_publicos "bc_pg21p bc_pg22p bc_pg24p bc_pg25p bc_pg26p bc_pg27p"
loc as_otros    "bc_pg11t bc_pg12t bc_pg14t bc_pg15t bc_pg16t bc_pg17t" // <---- !!!! ERROR Esto es suma de anteriores
loc asalariados "`as_privados' `as_publicos' `as_otros'"
loc patrones    "bc_pg51p bc_pg52p bc_pg51o bc_pg52o"
loc cpropiasl   "bc_pg31p bc_pg33p bc_pg31o bc_pg33o"
loc cpropiacl   "bc_pg41p bc_pg43p bc_pg41o bc_pg43o"
loc cooperat    "bc_pg71p bc_pg73p bc_pg71o bc_pg73o"

loc varlist_list "as_privados as_publicos as_otros asalariados patrones cpropiasl cpropiacl cooperat"

foreach varn in `varlist_list' {
	egen    bc_`varn' = rowtotal(``varn'')
	replace bc_`varn' = bc_`varn' / bc_deflactor
}

* fix seguro de desempleo
replace bc_as_privados = bc_as_privados - bc_seguro if bc_as_privados>0 & bc_pf41==1
replace bc_cooperat    = bc_cooperat    - bc_seguro if bc_cooperat>0    & bc_pf41==3

* agregados de hogar
foreach varn in `varlist_list' otros_lab otros_lab2 {
	egen `varn'h = sum(bc_`varn'), by(bc_correlat)
}

// Total de ingresos laborales ---------------------------------------

* Total ingresos laborales ocupación principal
gen     bc_principal = bc_as_privados+bc_as_publicos
replace bc_principal = bc_patrones+bc_cpropiasl+bc_cpropiacl+bc_cooperat if bc_pf41>2 & bc_pf41<7 

* Total de ingresos laborales por todas las ocupaciones
gen bc_ing_lab = bc_as_privados+ bc_as_publicos+ bc_patrones+ bc_cpropiasl+ bc_cpropiacl ///
	+ bc_cooperat +bc_as_otros + (bc_otros_lab+bc_otros_lab2)/bc_deflactor

* total de ingresos laborales en el hogar
egen ing_labh = sum(bc_ing_lab), by(bc_correlat)


//  #3 -------------------------------------------------------------------------
//  ingresos no laborales ------------------------------------------------------

// Ingreso de capital

gen bc_utilidades=(bc_pg60p+bc_pg80p+bc_pg60o+bc_pg80o+bc_pg60p_cpsl+bc_pg60p_cpcl+bc_pg60o_cpsl+bc_pg60o_cpcl)/bc_deflactor
egen utilidadesh=sum(bc_utilidades) if bc_pe4!=7, by(bc_correlat)

gen bc_alq=(bc_pg121+bc_pg122)/bc_deflactor
gen alqh=bc_alq

gen bc_intereses=(bc_pg131+bc_pg132)/bc_deflactor
gen interesesh=bc_intereses

* Utilidades de agropecuarios 
gen bc_ut_agropec= 0
replace bc_ut_agropec=(bc_pa33)/bc_deflactor if bc_anio<1991 & bc_anio>1987 
replace bc_ut_agropec=((bc_pa33)/1000)/bc_deflactor if bc_anio<1988 
egen ut_agropech=sum(bc_ut_agropec)if bc_pe4!=7, by(bc_correlat)

* Otros ingresos de capital
replace bc_otras_utilidades	=bc_otras_utilidades/bc_deflactor
replace bc_ot_utilidades	=bc_ot_utilidades/bc_deflactor
replace bc_otras_capital	=bc_otras_capital/bc_deflactor

capture gen bc_pg91=0
capture gen bc_pg91=bc_pg91

mvencode bc_utilidades bc_alq bc_intereses bc_otras_utilidades bc_otras_capital bc_ut_agropec bc_pg91 bc_pg92, mv(0) override

gen bc_ing_cap=0
replace bc_ing_cap=(bc_utilidades+bc_alq+bc_intereses+bc_ut_agropec+bc_otras_utilidades+bc_otras_capital+bc_ot_utilidades)
by bc_correlat: egen ing_caph=sum(bc_utilidades+bc_ut_agropec+bc_otras_utilidades+bc_otras_capital+bc_ot_utilidades)
replace ing_caph=ing_caph+bc_alq+bc_intereses

//  #4 -------------------------------------------------------------------------
//  Transferencias

// Jubilaciones y pensiones

gen bc_jub_pen=(bc_pg91)
egen jub_penh=sum(bc_jub_pen) if bc_pe4!=7, by(bc_correlat)
gen bc_jub_pene=(bc_pg92) // exterior
egen jub_peneh=sum(bc_jub_pene) if bc_pe4!=7, by(bc_correlat)

// beneficios sociales

capture gen bc_pg32p=0
capture gen bc_pg42p=0
capture gen bc_pg72p=0
capture gen bc_otros_benef=0
cap g bc_tarjeta=monto_tus_iecon

cap g bc_pg13o=0

cap g bc_pg23o=0
g benef_ocup_secund=0
replace benef_ocup_secund=bc_pg13t if bc_anio<1991
replace benef_ocup_secund=bc_pg13o+bc_pg23o+bc_pg32o+bc_pg42o+bc_pg72o if bc_anio>1990


mvencode bc_pg32p bc_pg42p bc_pg72p bc_pg13p bc_pg23p bc_pg101 bc_pg102 bc_jub_pen bc_jub_pene bc_otros_benef bc_pg111 bc_pg112 bc_pg14, mv(0) override
* le agregamos los beneficios de la ocupación secundaria
gen bc_bs_sociales=(bc_pg13p+bc_pg23p+bc_pg32p+bc_pg42p+bc_pg72p+bc_otros_benef+ bc_pg101+ bc_pg102+benef_ocup_secund+bc_seguro+bc_tarjeta)
egen bs_socialesh=sum(bc_bs_sociales) if bc_pe4!=7, by(bc_correlat)

*variables de beneficios sociales que no figuran todos los años
capture gen bc_ing_ciud=0
gen ingre_ciud=(bc_ing_ciud)
egen ingre_ciudh=sum(ingre_ciud) if bc_pe4!=7, by(bc_correlat)

* antes se llamaba otr_ben, le cambiamos el nombre para no confundir
gen bc_transf_hog=0
replace bc_transf_hog=(bc_pg111+bc_pg112) // transferencias entre hogares
egen transf_hogh=sum(bc_transf_hog) if bc_pe4!=7, by(bc_correlat)

gen bc_beneficios=ingre_ciud+bc_bs_sociales
gen beneficiosh=ingre_ciudh+bs_socialesh 

// valor locativo

gen val_loc=0
replace val_loc=(bc_pg14) if esjefe
egen val_loch=sum(val_loc) if bc_pe4!=7, by(bc_correlat)

// otros ingresos

capture gen bc_pg191=0
capture gen bc_pg192=0

mvencode bc_pg191 bc_pg192, mv(0) override
capture gen otros=0
cap gen otros_ing=0
replace otros=(bc_pg191+bc_pg192)/1000 if bc_anio<1988
replace otros=(bc_pg191+bc_pg192) if bc_anio>1987 & bc_anio<1991
g otros_ing=otros
egen otrh=sum(otros_ing) if bc_pe4!=7, by(bc_correlat)
gen otrosh=otrh

//  #5 -------------------------------------------------------------------------
//  ingreso total del hogar sin seguro de salud

local varl "ing_labh ing_caph bs_socialesh jub_penh jub_peneh beneficiosh ht11  val_loch  otrosh bc_transf_hog transf_hogh"
recode `varl' (. = 0)

* Ingreso total del hogar sin seguro de salud –– imputo al jefe
gen bc_ht11_sss_corr = (ing_labh+ing_caph+cuota_otrohog_h)*bc_deflactor /// Estas 3 variables están en terminos reales
					 + beneficiosh + jub_penh + jub_peneh + val_loch + otrosh + transf_hogh ///
					 if esjefe
recode bc_ht11_sss_corr (. = 0)

* reordeno las variables en la base
order ht11, before(bc_ht11_sss_corr)
order saludh, before(bc_ht11_sss_corr)
