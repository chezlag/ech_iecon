*2_ compat ---------------------------------------------------------------------

/*------------------------------------------------------------------------------
Se arreglan las bases con las variables que generamos compatibles
	*- Si la variable es de los módulos 1 a 4 y no está disponible ese año 
	se genera igual a -13
	*- Si la variable es del módulo 5 y no está disponible ese año se genera
	igual a 0
*/
set more off
foreach num of numlist 81/89 {
u "$rutabasesorig/p`num'.dta", clear

*- 1 Características generales y de las personas
cap g  bc_correlat=correlat
cap g  bc_nper=nrorden
cap g  bc_nper=pe1
destring bc_nper, replace
recode filtloc (0=2),g(bc_filtloc)
cap g  bc_pesoan=pesoan
cap g  bc_mes=mes
	replace bc_mes=-15 if mes>12
cap g  bc_anio=anio
cap g  bc_dpto=dpto
cap g  bc_ccz=-13
cap g  bc_area=-13
cap g  bc_pe2=pe2
recode bc_pe2 (3/9 .=-15)
cap g  bc_pe3=pe3
cap g  bc_pe4=pe4
cap g  bc_pe5=pe5
	replace bc_pe5 =-9 if bc_pe3<14 & bc_pe3!=-15
recode bc_pe4 bc_pe5 (0 .=-15)

*- 2 Atención a la salud
cap g  bc_pe6a=pe6a
cap g  bc_pe6b=pe6b
recode bc_pe6a (0 9 .=-13)
recode bc_pe6b (0 9 .=-15)
cap g  bc_pe6a1=-13

*- 3 Educación
cap g  bc_pe11=pe11
recode bc_pe11 (0 3 6 4 7 9 .=-15)
replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.
cap g  bc_pe12=-13
cap g  bc_pe13=-13
cap g  bc_nivel=nivel2
cap g  bc_edu=edu
cap g  bc_edu_1=-13
cap g  bc_finalizo=-13
recode bc_nivel bc_edu (.=-15)

*- 4 Mercado de trabajo
cap g  bc_pobp=pobp
recode bc_pobp (0 .=-15)
cap g  bc_pf41=pf41
recode bc_pf41 (0 .=-9) (9 = -15) (8 = 7)
cap g  bc_cat2=cat2
recode bc_cat2 (4=3) (6=4) (9=5) (0 .=-15)
g bc_pf081=pf081
 replace bc_pf081=-15 if pf081==0
 replace bc_pf081=-9 if bc_pobp==1|bc_pobp>2
cap g  bc_pf082=pf082
 replace bc_pf082=3 if pf082>3&pf082<10
 replace bc_pf082=-9 if bc_pf081==2
recode pf40 (. 0=-15), g(bc_pf40)
cap g  bc_rama=rama
cap g  bc_pf39=pf39
g auxpf39=pf39
	replace auxpf39=0 if pf39>0&pf39<13 & bc_anio>1985 // militares 
	replace auxpf39=pf39*10 if pf39>12&pf39<1000 // ídem anterior 
g bc_tipo_ocup=trunc(auxpf39/1000)
	replace bc_tipo_ocup=-9 if bc_pobp!=2
	replace bc_tipo_ocup=-15 if bc_tipo_ocup==.&bc_pobp==2
drop auxpf39
cap g  bc_pf07=pf07
cap g  bc_pf051=pf051
cap g  bc_pf052=pf052
cap g  bc_pf053=pf053
cap g  bc_pf06=-13
cap g  bc_horas_sp=horas
cap g  bc_horas_sp_1=horas_1
cap g  bc_horas_hab=-13
cap g  bc_horas_hab_1=-13
recode pf04 (3=1) (5=3) (1 6=4) (.=-15), g(bc_pf04)
cap g  bc_pf21=pf21
cap g  bc_pf22=pf22
recode bc_pf22 (5=4) (.=-15)
cap g  bc_pf26=pf26
cap g  bc_pf34=-13
cap g  bc_reg_disse=-13
cap g  bc_register=-13
cap g  bc_register2=-13
cap g  bc_subocupado=-13
cap g  bc_subocupado1=-13

recode bc_rama bc_pf39 bc_pf07 bc_horas_sp bc_horas_sp_1 bc_horas_hab bc_horas_hab_1 bc_pf21 (0 .=-15)
recode bc_tipo_ocup bc_pf26 (.=-15)

*- Separamos servicio doméstico
preserve 
keep if bc_pe4==7
save "$rutainterm/servdom`num'",replace
restore
drop if bc_pe4==7

*- 5 Ingresos

cap g  bc_pg11p=pg11p
cap g  bc_pg12p=pg12p
cap g  bc_pg13p=pg13p
cap g  bc_pg14p=pg14p
cap g  bc_pg15p=pg15p
cap g  bc_pg16p=pg16p
cap g  bc_pg17p=pg17p
cap g  bc_pg11o=pg11o
cap g  bc_pg11o=0
cap g  bc_pg12o=pg12o
cap g  bc_pg12o=0
cap g  bc_pg13o=pg13o
cap g  bc_pg14o=pg14o
cap g  bc_pg14o=0
cap g  bc_pg15o=pg15o
cap g  bc_pg15o=0
cap g  bc_pg16o=pg16o
cap g  bc_pg16o=0
cap g  bc_pg17o=pg17o
cap g  bc_pg17o=0
cap g  bc_pg21p=pg21p
cap g  bc_pg22p=pg22p
cap g  bc_pg23p=pg23p
cap g  bc_pg24p=pg24p
cap g  bc_pg25p=pg25p
cap g  bc_pg26p=pg26p
cap g  bc_pg27p=pg27p
cap g  bc_pg21o=pg21o
cap g  bc_pg21o=0
cap g  bc_pg22o=pg22o
cap g  bc_pg22o=0
cap g  bc_pg23o=pg23o
cap g  bc_pg24o=pg24o
cap g  bc_pg24o=0
cap g  bc_pg25o=pg25o
cap g  bc_pg25o=0
cap g  bc_pg26o=pg26o
cap g  bc_pg26o=0
cap g  bc_pg27o=pg27o
cap g  bc_pg27o=0
cap g  bc_pg11t=pg11t
cap g  bc_pg12t=pg12t
cap g  bc_pg13t=pg13t
cap g  bc_pg14t=pg14t
cap g  bc_pg15t=pg15t
cap g  bc_pg16t=pg16t
cap g  bc_pg17t=pg17t
cap g  bc_pg31p=pg31p
cap g  bc_pg32p=pg32p
cap g  bc_pg33p=pg33p
cap g  bc_pg31o=pg31o
cap g  bc_pg32o=pg32o
cap g  bc_pg33o=pg33o
cap g  bc_pg41p=pg41p
cap g  bc_pg42p=pg42p
cap g  bc_pg43p=pg43p
cap g  bc_pg41o=pg41o
cap g  bc_pg42o=pg42o
cap g  bc_pg43o=pg43o
cap g  bc_pg51p=pg51p
cap g  bc_pg52p=pg52p
cap g  bc_pg51o=pg51o
cap g  bc_pg52o=pg52o
cap g  bc_pg71p=pg71p
cap g  bc_pg72p=pg72p
cap g  bc_pg73p=pg73p
cap g  bc_pg71o=pg71o
cap g  bc_pg72o=pg72o
cap g  bc_pg73o=pg73o
/*
cap g  bc_pg60p=pg60p
cap g  bc_pg60p_cpcl=0
cap g  bc_pg60p_cpsl=0
*/
cap g  bc_pg60p=pg60p if bc_pf41==4
cap g  bc_pg60p_cpsl= pg60p if pf41==5
cap g  bc_pg60p_cpcl= pg60p if pf41==6

cap g  bc_pg60o=pg60o
cap g  bc_pg60o_cpcl=0
cap g  bc_pg60o_cpsl=0

*cap g  bc_pg80p=pg80p
cap g  bc_pg80p=pg80p if bc_pf41==3
cap g  bc_pg80o=pg80o
cap g  bc_pg121=pg121
cap g  bc_pg122=pg122
cap g  bc_pg131=pg131
cap g  bc_pg132=pg132

recode pg60p (.=0)
recode pg80p (.=0)
cap g bc_otras_utilidades=pg60p+pg80p if bc_pf41!=3 | bc_pf41!=4 | bc_pf41!=5 | bc_pf41!=6 // Sumo pg60p con pg80p
*cap g  bc_otras_utilidades=otras_utilidades

cap g  bc_ot_utilidades=0
cap g  bc_otras_capital=otras_capital
cap g  bc_otros_lab=otros_lab
cap g  bc_otros_benef=otros_benef
cap g  bc_pag_at=0
cap g  bc_pg91=pg91
cap g  bc_pg92=pg92
cap g  bc_pg911=0
cap g  bc_pg912=0
cap g  bc_pg921=0
cap g  bc_pg922=0
cap g  bc_pg101=pg101
cap g  bc_pg102=pg102
cap g  bc_pg111=pg111
cap g  bc_pg112=pg112
cap g  bc_pa11=pa11
cap g  bc_pa12=pa12
cap g  bc_pa13=pa13
cap g  bc_pa21=pa21
cap g  bc_pa22=pa22
cap g  bc_pa31=pa31
cap g  bc_pa32=pa32
cap g  bc_pa33=pa33
cap g  bc_pg191=pg191
cap g  bc_pg192=pg192
cap g  bc_ing_ciud=ing_ciud
cap g  afam_pe=-13
cap g  afam_cont=-13
cap g  afam_pe_hog=-13
cap g  afam_cont_hog=-13
cap g  monto_afam_pe=0
cap g  monto_afam_cont=0
cap g  bc_afam=0
cap g  bc_yciudada=0
cap g  bc_yalimpan=0
cap g  bc_yhog=0
cap g  bc_pg14=pg14
cap g  bc_as_privados=as_privados
cap g  bc_as_publicos=as_publicos
cap g  bc_as_otros=as_otros
cap g  bc_asalariados=asalariados
cap g  bc_as_agropec=as_agropec
cap g  bc_patrones=patrones
cap g  bc_pat_agropec=pat_agropec
cap g  bc_cpropiasl=cpropiasl
cap g  bc_cpropiacl=cpropiacl
cap g  bc_cp_agropec=cp_agropec
cap g  bc_cooperat=cooperat
cap g  bc_ot_agropec=ot_agropec
cap g  bc_principal=principal
cap g  bc_ing_lab=ing_lab
cap g  bc_utilidades=utilidades
cap g  bc_alq=alq
cap g  bc_intereses=intereses
cap g  bc_ut_agropec=ut_agropec
cap g  bc_ing_cap=ing_cap
cap g  bc_jub_pen=jub_pen
cap g  bc_jub_pene=jub_pene
cap g  bc_tarjeta=tarjeta
cap g  bc_bs_sociales=bs_sociales
cap g  bc_transf_hog=transf_hog
cap g  bc_beneficios=beneficios
cap g  bc_ipc=ipc
cap g  bc_ipc_nuevo=-13
cap g  bc_ipc_tot=ipc
cap g  bc_cuotmilit=0
cap g  bc_cuotabps=0
cap g  bc_disse_p=0
cap g  bc_disse_o=0
cap g  bc_disse=0
cap g  bc_ht11_iecon=ht11
cap g  bc_ht11_sss=ht11_iecon*bc_ipc
cap g  bc_salud=0
cap g  bc_ht11_css=ht11_iecon*bc_ipc
cap g  bc_percap_iecon=percap_iecon

drop as_privadosh as_publicosh as_otrosh as_agropech patronesh pat_agropech cpropiaslh cpropiaclh cp_agropech cooperath ot_agropech otros_labh ing_labh utilidadesh alqh interesesh ut_agropech otras_utilidadesh otras_capitalh ing_caph jub_penh jub_peneh bs_socialesh ingre_ciudh transf_hogh beneficiosh val_loc val_loch otrh otrosh

mvencode bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p /// 
bc_pg11o bc_pg12o bc_pg13o bc_pg14o bc_pg15o bc_pg16o bc_pg17o ///
bc_pg21p bc_pg22p bc_pg23p bc_pg24p bc_pg25p bc_pg26p bc_pg27p ///
bc_pg21o bc_pg22o bc_pg23o bc_pg24o bc_pg25o bc_pg26o bc_pg27o ///
bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t ///
bc_pg31p bc_pg32p bc_pg33p bc_pg31o bc_pg32o bc_pg33o bc_pg41p ///
bc_pg42p bc_pg43p bc_pg41o bc_pg42o bc_pg43o bc_pg51p bc_pg52p ///
bc_pg51o bc_pg52o bc_pg71p bc_pg72p bc_pg73p bc_pg71o bc_pg72o ///
bc_pg73o bc_pg60p bc_pg60p_cpcl bc_pg60p_cpsl bc_pg60o bc_pg60o_cpcl ///
bc_pg60o_cpsl bc_pg80p bc_pg80o bc_pg121 bc_pg122 bc_pg131 bc_pg132 ///
bc_otras_utilidades bc_ot_utilidades bc_otras_capital bc_otros_lab ///
bc_otros_benef bc_pag_at bc_pg91 bc_pg92 bc_pg911 bc_pg912 ///
bc_pg921 bc_pg922 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pa11 bc_pa12 ///
bc_pa13 bc_pa21 bc_pa22 bc_pa31 bc_pa32 bc_pa33 bc_pg191 bc_pg192 bc_ing_ciud ///
bc_afam bc_yciudada bc_yalimpan bc_yhog bc_pg14 bc_as_privados ///
bc_as_publicos bc_as_otros bc_asalariados bc_as_agropec bc_patrones ///
bc_pat_agropec bc_cpropiasl bc_cpropiacl bc_cp_agropec bc_cooperat ///
bc_ot_agropec bc_principal bc_ing_lab bc_utilidades bc_alq bc_intereses ///
bc_ut_agropec bc_ing_cap bc_jub_pen bc_jub_pene bc_tarjeta bc_bs_sociales ///
bc_transf_hog bc_beneficios bc_ipc bc_ipc_nuevo bc_ipc_tot ///
bc_cuotmilit bc_cuotabps bc_disse_p bc_disse_o bc_disse ///
bc_ht11_sss bc_salud bc_ht11_css bc_percap_iecon , mv(0) override

*-------------------------------------------------------------------------------
* Order
order bc_correlat bc_nper bc_filtloc bc_pesoan bc_mes bc_anio bc_dpto bc_ccz 	///
bc_area bc_pe2 bc_pe3 bc_pe4 bc_pe5 bc_pe6a bc_pe6b bc_pe6a1 bc_pe11 bc_pe12 	///
bc_pe13 bc_edu bc_edu_1 bc_finalizo bc_pobp bc_pf41 bc_cat2 bc_pf081 bc_pf082 	///
bc_pf40 bc_rama bc_pf39 bc_tipo_ocup bc_pf07 bc_pf051 bc_pf052 bc_pf053 bc_pf06 ///
bc_horas_sp bc_horas_sp_1 bc_horas_hab_1 bc_horas_hab_1 bc_pf04 bc_pf21 bc_pf22 ///
bc_pf26 bc_pf34 bc_reg_disse bc_register bc_register2 bc_subocupado 			///
bc_subocupado1 bc_pg11p bc_pg12p bc_pg13p bc_pg14p  bc_pg15p bc_pg16p bc_pg17p 	///
bc_pg11o bc_pg12o bc_pg13o bc_pg14o bc_pg15o bc_pg16o bc_pg17o bc_pg21p 		///
bc_pg22p bc_pg23p bc_pg24p bc_pg25p bc_pg26p bc_pg27p bc_pg21o bc_pg22o 		///
bc_pg23o bc_pg24o bc_pg25o bc_pg26o bc_pg27o bc_pg11t bc_pg12t bc_pg13t 		///
bc_pg14t bc_pg15t bc_pg16t bc_pg17t bc_pg31p bc_pg32p bc_pg33p bc_pg31o 		///
bc_pg32o bc_pg33o bc_pg41p bc_pg42p bc_pg43p bc_pg41o bc_pg42o bc_pg43o 		///
bc_pg51p bc_pg52p bc_pg51o bc_pg52o bc_pg71p bc_pg72p bc_pg73p bc_pg71o 		///
bc_pg72o bc_pg73o bc_pg60p bc_pg60p_cpcl bc_pg60p_cpsl bc_pg60o bc_pg60o_cpcl 	///
bc_pg60o_cpsl bc_pg80p bc_pg80o bc_pg121 bc_pg122 bc_pg131 bc_pg132 			///
bc_otras_utilidades bc_ot_utilidades bc_otras_capital bc_otros_lab 				///
bc_otros_benef bc_pag_at bc_pg91 bc_pg92 bc_pg911 bc_pg912 bc_pg921 bc_pg922 	///
bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pa11 bc_pa12 bc_pa13 bc_pa21 bc_pa22 	///
bc_pa31 bc_pa32 bc_pa33 bc_pg191 bc_pg192 bc_afam afam_pe afam_cont afam_pe_hog ///
afam_cont_hog monto_afam_pe monto_afam_cont bc_yciudada bc_yalimpan bc_yhog 	///
bc_pg14 bc_as_privados bc_as_publicos bc_as_otros bc_asalariados bc_as_agropec 	///
bc_patrones bc_pat_agropec bc_cpropiasl bc_cpropiacl bc_cp_agropec bc_cooperat 	///
bc_ot_agropec bc_principal bc_ing_lab bc_utilidades bc_alq bc_intereses 		///
bc_ut_agropec bc_ing_cap bc_jub_pen bc_jub_pene bc_tarjeta bc_bs_sociales 		///
bc_transf_hog bc_beneficios bc_ipc bc_ipc_nuevo bc_ipc_tot bc_cuotmilit 		///
bc_cuotabps bc_disse_p bc_disse_o bc_disse bc_ht11_sss bc_salud bc_ht11_css 	///
bc_percap_iecon

*-------------------------------------------------------------------------------
* Append servicio doméstico

append using "$rutainterm/servdom`num'", nol

sort bc_correlat bc_nper

/*------------------------------------------------------------------------------
labels
	*- Etiquetas de valores de variables compatibles.
*/
run "$rutaprogramas/labels.do"

sa "$rutabases/p`num'.dta", replace
}
