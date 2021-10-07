*6_ ----------------------------------------------------------------------------
*ingresos rurales
cap g bc_pa11=0 
cap g bc_pa12=0 
cap g bc_pa13=0 
cap g bc_pa21=0 
cap g bc_pa22=0 
cap g bc_pa31=0 
cap g bc_pa32=0 
cap g bc_pa33=0 
cap g bc_pf04=0

mvencode bc_ipc bc_pa11 bc_pa12 bc_pa13 bc_pa21 bc_pa22 bc_pa31 bc_pa32 bc_pa33, mv(0) override

* pasamos seguro de desempleo (encubierto)
* son gente que está en el seguro de paro y la ech los identifica como ocupados.
* suponemos ingresos declaran en ocupación principal son por seguro de paro
g seguro=0
	replace seguro=bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p+bc_pg71p+bc_pg73p+bc_pg71o+bc_pg73o if bc_pobp==2&bc_pf04==7&(bc_pg101==0|bc_pg101!=.) //& anio<2001
recode seguro .=0

*-------------------------------------------------------------------------------
* Ingresos laborales

* Asalariados privados ocupación principal
g bc_as_privados=(bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p)*bc_ipc
	replace bc_as_privados=((bc_as_privados/bc_ipc)-seguro)*bc_ipc if bc_as_privados>0&bc_pf41==1
egen as_privadosh=sum(bc_as_privados), by(bc_correlat)

* Asalariados públicos ocupación principal
g bc_as_publicos=(bc_pg21p+bc_pg22p+bc_pg24p+bc_pg25p+bc_pg26p+bc_pg27p)*bc_ipc
egen as_publicosh=sum(bc_as_publicos), by(bc_correlat)

* Asalariados otras ocupaciones
g bc_as_otros=(bc_pg11t+bc_pg12t+bc_pg14t+bc_pg15t+bc_pg16t+bc_pg17t)*bc_ipc
egen as_otrosh=sum(bc_as_otros), by(bc_correlat)

* Asalariados total ocupaciones
g bc_asalariados=(bc_pg11p+bc_pg12p+bc_pg14p+bc_pg15p+bc_pg16p+bc_pg17p+bc_pg21p+bc_pg22p+bc_pg24p+bc_pg25p+bc_pg26p+bc_pg27p+bc_pg11t+bc_pg12t+bc_pg14t+bc_pg15t+bc_pg16t+bc_pg17t)*bc_ipc

*Asalariados agropec
cap g bc_as_agropec= 0
cap g bc_cat2=0
	replace bc_as_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&(bc_cat2==1|bc_cat2==2)
	replace bc_as_agropec=((bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc)/1000 if bc_anio<1988&(bc_cat2==1|bc_cat2==2)
egen as_agropech=sum(bc_as_agropec), by(bc_correlat)

* Trabajadores independientes

* Patrones
g bc_patrones=0
	replace bc_patrones=(bc_pg51p+bc_pg52p+bc_pg51o+bc_pg52o)*bc_ipc
egen patronesh=sum(bc_patrones), by(bc_correlat)

* Patrones agropec
cap g bc_pat_agropec=0
	replace bc_pat_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==4
	replace bc_pat_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==4
egen pat_agropech=sum(bc_pat_agropec), by(bc_correlat)

* Cuenta propa sin local
g bc_cpropiasl=0
	replace bc_cpropiasl=(bc_pg31p+bc_pg33p+bc_pg31o+bc_pg33o)*bc_ipc
egen cpropiaslh=sum(bc_cpropiasl), by(bc_correlat)

* Cuenta propia con local
g bc_cpropiacl=0
	replace bc_cpropiacl=(bc_pg41p+bc_pg43p+bc_pg41o+bc_pg43o)*bc_ipc
egen cpropiaclh=sum(bc_cpropiacl), by(bc_correlat)

* Cuenta propia agropec
cap g bc_cp_agropec= 0
	replace bc_cp_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==6
	replace bc_cp_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==6
egen cp_agropech=sum(bc_cp_agropec), by(bc_correlat)

* Cooperativas
g bc_cooperat=0
	replace bc_cooperat=(bc_pg71p+bc_pg73p+bc_pg71o+bc_pg73o)*bc_ipc
	replace bc_cooperat=bc_cooperat-seguro*bc_ipc if bc_cooperat>0&bc_pf41==3
egen cooperath=sum(bc_cooperat), by(bc_correlat)

* Otros ingresos laborales agropecuarios 
cap g bc_ot_agropec= 0
	replace bc_ot_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc if bc_anio<1991&bc_anio>1987&bc_cat2==9
	replace bc_ot_agropec=(bc_pa11+bc_pa12+bc_pa13+bc_pa21+bc_pa22+bc_pa31+bc_pa32)*bc_ipc/1000 if bc_anio<1988&bc_cat2==9
egen ot_agropech=sum(bc_ot_agropec), by(bc_correlat)

* Otros ingresos laborales ya generados
egen otros_labh=sum(bc_otros_lab), by(bc_correlat)

mvencode bc_as_privados bc_as_publicos bc_cpropiasl bc_cpropiacl bc_patrones bc_cooperat bc_otros_lab bc_as_otros bc_ot_agropec bc_as_agropec bc_cp_agropec bc_pat_agropec, mv(0) override

* Total ingresos laborales ocupación principal
g bc_principal=bc_as_privados+bc_as_publicos
	replace bc_principal=bc_patrones+bc_cpropiasl+bc_cpropiacl+bc_cooperat if bc_pf41>2&bc_pf41<7 

g bc_ing_lab=0
	replace bc_ing_lab=bc_as_privados+bc_as_publicos+bc_patrones+bc_cpropiasl+bc_cpropiacl+bc_cooperat+bc_as_otros+bc_as_agropec+bc_cp_agropec+bc_pat_agropec+bc_ot_agropec+(bc_otros_lab+bc_otros_lab2)*bc_ipc // 08/10 se agrega bc_otros_lab2
egen ing_labh=sum(bc_ing_lab), by(bc_correlat)

*-------------------------------------------------------------------------------
* Ingresos no laborales

* Ingreso de capital
g bc_utilidades=(bc_pg60p+bc_pg60p_cpsl+bc_pg60p_cpcl+bc_pg80p+bc_pg60o+bc_pg60o_cpsl+bc_pg60o_cpcl+bc_pg80o)*bc_ipc
egen utilidadesh=sum(bc_utilidades), by(bc_correlat)

g bc_alq=(bc_pg121+bc_pg122)*bc_ipc
egen alqh=sum(bc_alq), by(bc_correlat)

g bc_intereses=(bc_pg131+bc_pg132)*bc_ipc
egen interesesh=sum(bc_intereses), by(bc_correlat)

* Utilidades de agropecuarios 
g bc_ut_agropec= 0
	replace bc_ut_agropec=(bc_pa33)*bc_ipc if bc_anio<1991 & bc_anio>1987 
	replace bc_ut_agropec=(bc_pa33)*bc_ipc/1000 if bc_anio<1988 
egen ut_agropech=sum(bc_ut_agropec), by(bc_correlat)

* Otros ingresos de capital
egen otras_utilidadesh=sum(bc_otras_utilidades) , by(bc_correlat) 
egen ot_utilidadesh=sum(bc_ot_utilidades), by(bc_correlat) 
egen otras_capitalh=sum(bc_otras_capital), by(bc_correlat) 

mvencode bc_utilidades bc_alq bc_intereses bc_otras_utilidades bc_ot_utilidades bc_otras_capital bc_ut_agropec, mv(0) override

g bc_ing_cap=0
	replace bc_ing_cap=(bc_utilidades+bc_alq+bc_intereses+bc_ut_agropec+((bc_otras_utilidades+bc_ot_utilidades+bc_otras_capital)*bc_ipc))
egen ing_caph=sum(bc_ing_cap), by(bc_correlat)

*-------------------------------------------------------------------------------
* Transferencias

* Jubilaciones y pensiones
g bc_jub_pen=(bc_pg91*bc_ipc)
egen jub_penh=sum(bc_jub_pen), by(bc_correlat)
g bc_jub_pene=((bc_pg92)*bc_ipc) // exterior
egen jub_peneh=sum(bc_jub_pene), by(bc_correlat)

* Beneficios sociales
cap g bc_pg32p=0
cap g bc_pg42p=0
cap g bc_pg72p=0
cap g bc_otros_benef=bc_otros_benef
cap g bc_tarjeta=0

g bc_benef_ocup_secund=0
	replace bc_benef_ocup_secund=bc_pg13t if bc_anio<1991
	replace bc_benef_ocup_secund=bc_pg13o+bc_pg23o+bc_pg32o+bc_pg42o+bc_pg72o if bc_anio>1990

mvencode bc_jub_pen bc_jub_pene bc_otros_benef bc_pg111 bc_pg112 bc_pg14, mv(0) override
* le agregamos los beneficios de la ocupación secundaria
g bc_bs_sociales=(bc_pg13p+bc_pg23p+bc_pg32p+bc_pg42p+bc_pg72p+bc_otros_benef+bc_pg101+bc_pg102+bc_benef_ocup_secund+seguro+bc_tarjeta)*bc_ipc
egen bs_socialesh=sum(bc_bs_sociales), by(bc_correlat)

* variables de beneficios sosciales que no figuran todos los años
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
* Otros ingresos
cap g bc_pg191=0
cap g bc_pg192=0

cap g bc_otros=0
	replace bc_otros=(bc_pg191+bc_pg192)/1000 if bc_anio<1988
	replace bc_otros=(bc_pg191+bc_pg192) if bc_anio>1987 & bc_anio<1991
cap g bc_otros_ing=0
	replace bc_otros_ing=bc_otros
egen otrh=sum(bc_otros_ing), by(bc_correlat)
g otrosh=otrh*bc_ipc

*-------------------------------------------------------------------------------
* Ingreso del hogar sin fonasa
mvencode ing_labh ing_caph bs_socialesh jub_penh jub_peneh beneficiosh ht11* val_loch otrosh transf_hog transf_hogh, mv(0) override
g bc_ht11_sss=0
	replace bc_ht11_sss=ing_labh+ing_caph+beneficiosh+jub_penh+jub_peneh+val_loch+otrosh+transf_hogh // compatibilizada

*-------------------------------------------------------------------------------
* Seguro de salud del hogar
*auxiliar para salud //REVISAR
g salud_aux=bc_disse_p+bc_disse_o+bc_disse
*	replace salud_aux=salud_aux+bc_cuotmilit if cuot_emp_tot==0
g cuotas_generadas=g1_1_9 + g1_2_9 // Ver estos valores cuando son muy altos!
g tot_cuotas=cuotas_generadas*monto1
replace salud_aux=salud_aux+tot_cuotas
egen bc_salud=sum(salud_aux) ,by(bc_correlat)

g bc_ht11_css=bc_ht11_sss+bc_salud*bc_ipc

*-------------------------------------------------------------------------------
* Ingreso per cápita del hogar sin seguro 
g bc_percap_iecon=bc_ht11_sss/ht19
