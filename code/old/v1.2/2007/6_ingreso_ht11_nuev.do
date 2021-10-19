
*ingresos rurales
cap g bc_pa11=0 
cap g bc_pa12=0 
cap g bc_pa13=0 
cap g bc_pa21=0 
cap g bc_pa22=0 
cap g bc_pa31=0 
cap g bc_pa32=0 
cap g bc_pa33=0 

mvencode bc_ipc bc_pa11 bc_pa12 bc_pa13 bc_pa21 bc_pa22 bc_pa31 bc_pa32 bc_pa33 bc_pg71o bc_pg73o bc_pg31o bc_pg33o , mv(0) override

* pasamos seguro de desempleo (encubierto)
* son gente que está en el seguro de paro y la ech los identifica como ocupados.
* suponemos ingresos declaran en ocupación bc_principal son por seguro de paro
g seguro=0
	replace seguro=bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p+bc_pg71p+bc_pg73p+bc_pg71o+bc_pg73o if bc_pobp==2&bc_pf04==7&(bc_pg101==0|bc_pg101!=.) //& bc_anio<2001
recode seguro .=0

*-------------------------------------------------------------------------------
* Ingresos laborales

* Asalariados privados ocupación bc_principal
g bc_as_privados=(bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p)*bc_ipc
	replace bc_as_privados=((bc_as_privados/bc_ipc)-seguro)*bc_ipc if bc_as_privados>0&bc_pf41==1
cap drop as_privadosh
egen as_privadosh=sum(bc_as_privados), by(bc_correlat)

* Asalariados públicos ocupación bc_principal
g bc_as_publicos=(bc_pg21p+bc_pg22p+bc_pg24p+bc_pg25p+bc_pg26p+bc_pg27p)*bc_ipc
cap drop as_publicosh
egen as_publicosh=sum(bc_as_publicos), by(bc_correlat)

* Asalariados otras ocupaciones
g bc_as_otros=(bc_pg11t+bc_pg12t+bc_pg14t+bc_pg15t+bc_pg16t+bc_pg17t)*bc_ipc
cap drop as_otrosh
egen as_otrosh=sum(bc_as_otros), by(bc_correlat)

* Asalariados total ocupaciones
g bc_asalariados=(bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p+bc_pg21p+bc_pg22p+bc_pg24p+bc_pg25p+bc_pg26p+bc_pg27p+bc_pg11t+bc_pg12t+bc_pg14t+bc_pg15t+bc_pg16t+bc_pg17t)*bc_ipc

*Asalariados agropec
cap g bc_as_agropec= 0
cap g bc_cat2=0
	replace bc_as_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&(bc_cat2==1|bc_cat2==2)
	replace bc_as_agropec=((bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc)/1000 if bc_anio<1988&(bc_cat2==1|bc_cat2==2)
cap drop as_agropech
egen as_agropech=sum(bc_as_agropec), by(bc_correlat)

* Trabajadores independientes
*mvencode bc_pg51p bc_pg52p bc_pg51o bc_pg52o, mv(0) override
mvencode bc_pg13p bc_pg23p bc_pg32p bc_pg42p bc_pg72p , mv(0) override
mvencode bc_pg51p bc_pg52p bc_pg31p bc_pg33p bc_pg41p bc_pg43p bc_pg71p bc_pg73p bc_pg60p bc_pg80p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg121 bc_pg122 bc_pg131 bc_pg132, mv(0) override
mvencode bc_pg51o bc_pg52o bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg71o bc_pg73o bc_pg60o bc_pg80o bc_pg60o_cpsl bc_pg60o_cpcl, mv(0) override
* bc_patrones
g bc_patrones=0
	replace bc_patrones=(bc_pg51p+bc_pg52p+bc_pg51o+bc_pg52o)*bc_ipc
cap drop patronesh
egen patronesh=sum(bc_patrones), by(bc_correlat)

* bc_patrones agropec
cap g bc_pat_agropec=0
	replace bc_pat_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==4
	replace bc_pat_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+ bc_pa22+ bc_pa31+ bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==4
cap drop pat_agropech
egen pat_agropech=sum(bc_pat_agropec), by(bc_correlat)

* Cuenta propa sin local
g bc_cpropiasl=0
	replace bc_cpropiasl=(bc_pg31p+bc_pg33p+bc_pg31o+bc_pg33o)*bc_ipc
cap drop cpropiaslh
egen cpropiaslh=sum(bc_cpropiasl), by(bc_correlat)

* Cuenta propia con local
mvencode bc_pg41o bc_pg43o, mv(0) override
g bc_cpropiacl=0
	replace bc_cpropiacl=(bc_pg41p+bc_pg43p+bc_pg41o+bc_pg43o)*bc_ipc
cap drop cpropiaclh
egen cpropiaclh=sum(bc_cpropiacl), by(bc_correlat)

* Cuenta propia agropec
cap g bc_cp_agropec= 0
	replace bc_cp_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==6
	replace bc_cp_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==6
cap drop cp_agropech
egen cp_agropech=sum(bc_cp_agropec), by(bc_correlat)

* Cooperativas
g bc_cooperat=0
	replace bc_cooperat=(bc_pg71p+bc_pg73p+bc_pg71o+bc_pg73o)*bc_ipc
	replace bc_cooperat=bc_cooperat-seguro*bc_ipc if bc_cooperat>0&bc_pf41==3
cap drop cooperath
egen cooperath=sum(bc_cooperat), by(bc_correlat)

* bc_otros ingresos laborales agropecuarios 
cap g bc_ot_agropec= 0
	replace bc_ot_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==9
	replace bc_ot_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==9
cap drop ot_agropech
egen ot_agropech=sum(bc_ot_agropec), by(bc_correlat)

* bc_otros ingresos laborales ya generados
egen otros_labh=sum(bc_otros_lab), by(bc_correlat)

mvencode bc_as_privados bc_as_publicos bc_cpropiasl bc_cpropiacl bc_patrones bc_cooperat bc_otros_lab bc_as_otros bc_ot_agropec bc_as_agropec bc_cp_agropec bc_pat_agropec, mv(0) override

* Total ingresos laborales ocupación bc_principal
g bc_principal=bc_as_privados+bc_as_publicos
	replace bc_principal=bc_patrones+bc_cpropiasl+bc_cpropiacl+bc_cooperat if bc_pf41>2&bc_pf41<7 

g bc_ing_lab=0
	replace bc_ing_lab=bc_as_privados+bc_as_publicos+bc_patrones+bc_cpropiasl+bc_cpropiacl+bc_cooperat+bc_as_otros/*
	*/+bc_as_agropec+bc_cp_agropec+bc_pat_agropec+bc_ot_agropec+(bc_otros_lab+bc_otros_lab2)*bc_ipc 
egen ing_labh=sum(bc_ing_lab), by(bc_correlat)

*-------------------------------------------------------------------------------
* Ingresos no laborales
mvencode bc_pg60p bc_pg80p bc_pg60o bc_pg80o, mv(0) override
* Ingreso de capital
cap drop bc_utilidades
gen bc_utilidades=(bc_pg60p+bc_pg80p+bc_pg60o+bc_pg80o+bc_pg60p_cpsl+bc_pg60p_cpcl+bc_pg60o_cpsl+bc_pg60o_cpcl)*bc_ipc
cap drop utilidadesh
egen utilidadesh=sum(bc_utilidades) if bc_pe4!=7, by(bc_correlat)


g bc_alq=(bc_pg121+bc_pg122)*bc_ipc
egen alqh=sum(bc_alq), by(bc_correlat)

g bc_intereses=(bc_pg131+bc_pg132)*bc_ipc
egen interesesh=sum(bc_intereses), by(bc_correlat)

* bc_utilidades de agropecuarios 
g bc_ut_agropec= 0
	replace bc_ut_agropec=(bc_pa33)*bc_ipc if bc_anio<1991 & bc_anio>1987 
	replace bc_ut_agropec=(bc_pa33)*bc_ipc/1000 if bc_anio<1988 
cap drop ut_agropech
egen ut_agropech=sum(bc_ut_agropec), by(bc_correlat)

* bc_otros ingresos de capital
egen otras_utilidadesh=sum(bc_otras_utilidades), by(bc_correlat) 
egen ot_utilidadesh=sum(bc_ot_utilidades), by(bc_correlat) 
egen otras_capitalh=sum(bc_otras_capital), by(bc_correlat) 

mvencode bc_utilidades bc_alq bc_intereses bc_otras_utilidades bc_ot_utilidades bc_otras_capital bc_ut_agropec, mv(0) override

* Otros ingresos de capital

replace bc_otras_utilidades	=bc_otras_utilidades*bc_ipc
replace bc_ot_utilidades	=bc_ot_utilidades*bc_ipc
replace bc_otras_capital	=bc_otras_capital*bc_ipc

capture gen bc_pg91=0
capture gen bc_pg91=bc_pg91

mvencode bc_utilidades bc_alq bc_intereses bc_otras_utilidades bc_otras_capital bc_ut_agropec bc_pg91 bc_pg92, mv(0) override

cap drop bc_ing_cap
gen bc_ing_cap=0
replace bc_ing_cap=(bc_utilidades+bc_alq+bc_intereses+bc_ut_agropec+bc_otras_utilidades+bc_otras_capital+bc_ot_utilidades)
cap drop ing_caph
bys bc_correlat: egen ing_caph=sum(bc_utilidades+bc_ut_agropec+bc_otras_utilidades+bc_otras_capital+bc_ot_utilidades)
replace ing_caph=ing_caph+bc_alq+bc_intereses

*-------------------------------------------------------------------------------
* Transferencias

* Jubilaciones y pensiones
g bc_jub_pen=(bc_pg91*bc_ipc)
egen jub_penh=sum(bc_jub_pen), by(bc_correlat)
g bc_jub_pene=((bc_pg92)*bc_ipc) // exterior
cap drop jub_peneh
egen jub_peneh=sum(bc_jub_pene), by(bc_correlat)

* bc_beneficios sociales
cap g bc_pg32p=0
cap g bc_pg42p=0
cap g bc_pg72p=0
cap g bc_otros_benef=bc_otros_benef
cap g bc_tarjeta=0

mvencode bc_pg13o bc_pg23o bc_pg32o bc_pg42o bc_pg72o, mv(0) override
g bc_benef_ocup_secund=0
	replace bc_benef_ocup_secund=bc_pg13t if bc_anio<1991
	replace bc_benef_ocup_secund=bc_pg13o+bc_pg23o+bc_pg32o+bc_pg42o+bc_pg72o if bc_anio>1990

mvencode bc_jub_pen bc_jub_pene bc_otros_benef bc_pg111 bc_pg112 bc_pg14 bc_benef_ocup_secund, mv(0) override
* le agregamos los bc_beneficios de la ocupación secundaria
g bc_bs_sociales=(bc_pg13p+bc_pg23p+bc_pg32p+bc_pg42p+bc_pg72p+bc_otros_benef+bc_pg101+bc_pg102+bc_benef_ocup_secund+seguro+bc_tarjeta)*bc_ipc
egen bs_socialesh=sum(bc_bs_sociales), by(bc_correlat)

* variables de bc_beneficios sosciales que no figuran todos los años
cap g bc_ing_ciud=0
g ingre_ciud=bc_ing_ciud*bc_ipc
egen ingre_ciudh=sum(ingre_ciud), by(bc_correlat)

* antes se llamaba otr_ben, le cambiamos el nombre para no confundir
g bc_transf_hog=0
	replace bc_transf_hog=(bc_pg111+bc_pg112)*bc_ipc // transferencias entre hogares
egen transf_hogh=sum(bc_transf_hog), by(bc_correlat)

* acá hicismos cambios
g bc_beneficios=ingre_ciud+bc_bs_sociales
g beneficiosh=ingre_ciudh+bs_socialesh

*-------------------------------------------------------------------------------
* Valor locativo
g val_loc=0
	replace val_loc=bc_pg14*bc_ipc if bc_pe4==1
egen val_loch=sum(val_loc), by(bc_correlat)

*-------------------------------------------------------------------------------
* bc_otros ingresos
cap g bc_pg191=0
cap g bc_pg192=0

cap g bc_otros=0
	replace bc_otros=(bc_pg191+bc_pg192)/1000 if bc_anio<1988
	replace bc_otros=(bc_pg191+bc_pg192) if bc_anio>1987 & bc_anio<1991
cap g otros_ing=0
	replace otros_ing=bc_otros
egen otrh=sum(otros_ing), by(bc_correlat)
g otrosh=otrh*bc_ipc

*-------------------------------------------------------------------------------
* Ingreso del hogar sin fonasa
mvencode ing_labh ing_caph bs_socialesh jub_penh jub_peneh beneficiosh ht11* val_loch otrosh bc_transf_hog transf_hogh, mv(0) override
g ht11_nuev=0
	replace ht11_nuev=ing_labh+ing_caph+beneficiosh+jub_penh+jub_peneh+val_loch+otrosh+transf_hogh // compatibilizada
	
gen bc_ht11_sss_corr=0

replace bc_ht11_sss_corr=(ing_labh+ing_caph+beneficiosh+jub_penh+jub_peneh+ val_loch+otrosh+transf_hogh)/bc_ipc if bc_pe4==1

g bc_ht11_sss=bc_ht11_sss_corr*bc_ipc

*-------------------------------------------------------------------------------
* Seguro de salud del hogar
*auxiliar para salud
	replace cuotmilit=0 if ytransf_5>0 
g salud_aux=disse+disse_p+disse_s
	replace salud_aux=salud_aux+cuotmilit
egen bc_salud=sum(salud_aux) if bc_pe4!=7,by(bc_correlat)
recode bc_salud .=0

g ht11_nuev_cf=ht11_nuev+bc_salud*bc_ipc


g bc_ht11_css= bc_ht11_sss+bc_salud*bc_ipc
