*5_ ----------------------------------------------------------------------------
*- Valor locativo
foreach var in ht13 {
bys bc_correlat: egen max`var'=max(ht13)
replace `var' = max`var'
drop max`var'
}
cap drop bc_pg14
gen bc_pg14=0
	replace bc_pg14=d7_3 if (d7_1!=6 & (d7_1!=5 & loc!="900")) 	// Código compatible. La vble loc hace referencia a locagr o loc_agr, dependiendo del año.
	replace bc_pg14=0 if ht13==0 & d7_1!=6						// Excepción porque nosotros no podemos identificar zonas rurales en Mdeo, entonces tomamos valor de INE
	
gen sal_esp_net=0
	replace sal_esp_net=g124_3-bc_pg14 if d7_1==6 & g124_3!=0 // Salario en especie neto de valor locativo para ocupantes en rel. de dependencia
	
gen corr_sal_esp=0
	replace corr_sal_esp=-bc_pg14 if sal_esp_net>0  // Corrección para salario en especie, es el valor locativo (*-1) si esta diferencia es positiva
	replace corr_sal_esp=-g124_3 if sal_esp_net<=0	// Corrección para salario en especie, es todo el salario en especie si la dif entre valor loc y salario es negativa
	
* Missing
mvencode g121_1-g121_8 g122_2 g122_3 g123_2 g124_3 g125_2 g126_2 g127_2 g128_2-g128_4 g129_2 g129_3 g130_1-g130_8 g131_2 g131_3 g132_2 g133_3 g134_2 g135_2 g136_2 g137_2-g137_4 g138_2 g138_3 g145_1-g145_22 g145_24 ///
h157-h159 h164_2 h163_1 h163_2 bc_afam ytransf_2 ytransf_4 ytransf_5 bc_yciudada yaliment* mto_hogc mto_cuot bc_cuotmilit mto_emer, mv(0) override

*-------------------------------------------------------------------------------
* Trabajadores dependientes - ocup ppal
g bc_pg11p=g121_1 if bc_pf41==1
	replace bc_pg11p=g121_1-bc_afam if bc_pf41==1&g147_3==1&(g121_1>bc_afam)
	replace bc_afam=0 if bc_pf41==1&g147_3==1&(g121_1<=bc_afam)
g bc_pg21p=g121_1 if bc_pf41==2
	replace bc_pg21p=g121_1-bc_afam if bc_pf41==2&g147_3==1&(g121_1>bc_afam)
	replace bc_afam=0 if bc_pf41==2&g147_3==1&(g121_1<=bc_afam)
g bc_pg12p=g121_2+g121_3+g127_2 if bc_pf41==1
g bc_pg22p=g121_2+g121_3+g127_2 if bc_pf41==2
g bc_pg14p=g121_5 if bc_pf41==1
g bc_pg24p=g121_5 if bc_pf41==2
g bc_pg15p=g121_6 if bc_pf41==1
g bc_pg25p=g121_6 if bc_pf41==2
g bc_pg16p=g121_4 if bc_pf41==1
g bc_pg26p=g121_4 if bc_pf41==2

g bc_pg17p=g121_8+g122_4+g123_2+g126_2+cuota_p+(g122_2*mto_des)+(g122_3*mto_alm)+g124_3+(g128_2*mto_vac)+(g128_3*mto_ove)+(g128_4*mto_cab)+g129_2+g129_3/12+emer_emp_tot+corr_sal_esp if bc_pf41==1 
	replace bc_pg17p=g121_8+g122_4+g123_2+g126_2+(g122_2*mto_des)+(g122_3*mto_alm)+g124_3+(g128_2*mto_vac)+(g128_3*mto_ove)+(g128_4*mto_cab)+g129_2+g129_3/12+cuot_emp_tot+emer_emp_tot+corr_sal_esp if bc_pf41==1&cuota_p==0 

g bc_pg27p=g121_8+g122_4+g123_2+g126_2+cuota_p+(g122_2*mto_des)+(g122_3*mto_alm)+g124_3+(g128_2*mto_vac)+(g128_3*mto_ove)+(g128_4*mto_cab)+g129_2+g129_3/12+emer_emp_tot+corr_sal_esp if bc_pf41==2 
	replace bc_pg27p=g121_8+g122_4+g123_2+g126_2+cuota_p+(g122_2*mto_des)+(g122_3*mto_alm)+g124_3+(g128_2*mto_vac)+(g128_3*mto_ove)+(g128_4*mto_cab)+g129_2+g129_3/12+cuot_emp_tot+emer_emp_tot+corr_sal_esp if bc_pf41==2&cuota_p==0 

*-------------------------------------------------------------------------------
* Trabajadores dependientes - ocup ppal - benef sociales
g bc_pg13p=g145_24+bc_afam if bc_pf41==1
	replace bc_pg13p=g145_24+bc_afam+mto_hogc if bc_pf41==1&g146_1==1&g146_2==2
	
g bc_pg23p=g145_24+bc_afam if bc_pf41==2 
	replace bc_pg23p=g145_24+bc_afam+mto_hogc if bc_pf41==2&g146_1==1&g146_2==2

*-------------------------------------------------------------------------------
* Trabajadores dependientes - otras ocup
g bc_pg11o=g130_1 if f87==1
	replace bc_pg11o=g130_1-bc_afam if f87==1&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&g147_3==1&(g130_1>bc_afam)
	replace bc_afam=0 if f87==1&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&g147_3==1&(g130_1<=bc_afam)
g bc_pg21o=g130_1 if f87==2
	replace bc_pg21o=g130_1-bc_afam if f87==2&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&g147_3==1&(g130_1>bc_afam)
	replace bc_afam=0 if f87==2&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&g147_3==1&(g130_1<=bc_afam)
g bc_pg12o=g130_2+g130_3+g136_2 if f87==1
g bc_pg22o=g130_2+g130_3+g136_2 if f87==2
g bc_pg14o=g130_5 if f87==1
g bc_pg24o=g130_5 if f87==2
g bc_pg15o=g130_6 if f87==1
g bc_pg25o=g130_6 if f87==2
g bc_pg16o=g130_4 if f87==1
g bc_pg26o=g130_4 if f87==2

g bc_pg17o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+g138_2+(g138_3/12) /*
	*/ if f87==1
	replace bc_pg17o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+(g138_3/12) /*
	*/ +g138_2+emer_emp_tot if f87==1&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)
	replace bc_pg17o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+(g138_3/12) /*
	*/ +g138_2+cuot_emp_tot+emer_emp_tot if f87==1&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)&cuota_o==0

g bc_pg27o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+(g138_3/12) /*
	*/ +g138_2 if f87==2
	replace bc_pg27o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+(g138_3/12) /*
	*/ +g138_2+emer_emp_tot if f87==2&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)
	replace bc_pg27o=g130_8+g131_4+g132_2+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g133_3+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+(g138_3/12) /*
	*/ +g138_2+cuot_emp_tot+emer_emp_tot if f87==2&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)&cuota_o==0
	
*-------------------------------------------------------------------------------
* Trabajadores dependientes - otras ocup - benef sociales
g bc_pg13o=g145_24+bc_afam if f87==1&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)
	replace bc_pg13o=g145_24+mto_hogc+bc_afam if f87==1&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)&g146_1==1&g146_2==2

g bc_pg23o=g145_24+bc_afam if f87==2&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7) 
	replace bc_pg23o=g145_24+mto_hogc if f87==2&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)&g146_1==1&g146_2==2

*-------------------------------------------------------------------------------
* Trabajadores dependientes - total otras ocup
mvencode bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o, mv(0) override

g bc_pg11t=bc_pg11o+bc_pg21o
g bc_pg12t=bc_pg12o+bc_pg22o
g bc_pg13t=bc_pg13o+bc_pg23o
g bc_pg14t=bc_pg14o+bc_pg24o
g bc_pg15t=bc_pg15o+bc_pg25o
g bc_pg16t=bc_pg16o+bc_pg26o
g bc_pg17t=bc_pg17o+bc_pg27o

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - ocup ppal
g bc_pg31p=g139 if bc_pf41==5 //cp s/l
	replace bc_pg31p=g139-bc_afam if bc_pf41==5&g147_3==1&(g139>bc_afam)
	replace bc_afam=0 if bc_pf41==5&g147_3==1&(g139<=bc_afam)
g bc_pg33p=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+cuot_emp_tot+emer_emp_tot if bc_pf41==5 //cp s/l
g bc_pg41p=g139 if bc_pf41==6 //cp c/l
	replace bc_pg41p=g139-bc_afam if bc_pf41==6&g147_3==1&(g139>bc_afam)
	replace bc_afam=0 if bc_pf41==6&g147_3==1&(g139<=bc_afam)
g bc_pg43p=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+cuot_emp_tot+emer_emp_tot if bc_pf41==6 //cp c/l
g bc_pg51p=g139 if bc_pf41==4 //patrón
g bc_pg52p=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+cuot_emp_tot+emer_emp_tot if bc_pf41==4 //patrón
g bc_pg71p=g139 if bc_pf41==3 //coop
	replace bc_pg71p=g139-bc_afam if bc_pf41==3&g147_3==1&(g139>bc_afam)
	replace bc_afam=0 if bc_pf41==3&g147_3==1&(g139<=bc_afam)
g bc_pg73p=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+cuot_emp_tot+emer_emp_tot if bc_pf41==3 //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - ocup ppal - benef sociales 
g bc_pg32p=g145_24+bc_afam if bc_pf41==5 //cp s/l
	replace bc_pg32p=g145_24+bc_afam+mto_hogc if bc_pf41==5&g146_1==1&g146_2==2 //cp s/l

g bc_pg42p=g145_24+bc_afam if bc_pf41==6 //cp c/l
	replace bc_pg42p=g145_24+bc_afam+mto_hogc if bc_pf41==6&g146_1==1&g146_2==2 //cp c/l

g bc_pg72p=g145_24+bc_afam if bc_pf41==3 //coop
	replace bc_pg72p=g145_24+bc_afam+mto_hogc if bc_pf41==3&g146_1==1&g146_2==2 //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - otras ocup
g bc_pg31o=g139 if (bc_pg31p==0|bc_pg31p==.)&f87==5&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp s/l 
g bc_pg33o=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7 if (bc_pg33p==0|bc_pg33p==.)&f87==5&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp s/l

g bc_pg41o=g139 if (bc_pg41p==0|bc_pg41p==.)&f87==6&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp c/l
g bc_pg43o=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7 if (bc_pg43p==0|bc_pg43p==.)&f87==6&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp c/l

g bc_pg51o=g139 if (bc_pg51p==0|bc_pg51p==.)&f87==4&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //patrón
g bc_pg52o=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7 if (bc_pg52p==0|bc_pg52p==.)&f87==4&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //patrón

g bc_pg71o=g139 if (bc_pg71p==0|bc_pg71p==.)&f87==3&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //coop
g bc_pg73o=g141_2+g141_3+g141_4+g141_5+g141_6+g141_7 if (bc_pg73p==0|bc_pg73p==.)&f87==3&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - otras ocup - benef sociales
g bc_pg32o=g145_24+bc_afam if f87==5&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7) //cp s/l
	replace bc_pg32o=g145_24+bc_afam+mto_hogc if f87==5&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)&g146_1==1&g146_2==2 //cp s/l

g bc_pg42o=g145_24+bc_afam if f87==6&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7) //cp c/l
	replace bc_pg42o=g145_24+bc_afam+mto_hogc if f87==6&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)&g146_1==1&g146_2==2 //cp c/l

g bc_pg72o=g145_24+bc_afam if f87==3&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7) //coop
	replace bc_pg72o=g145_24+bc_afam+mto_hogc if f87==3&(bc_pf41==-9|bc_pf41==.|bc_pf41==4|bc_pf41==7)&g146_1==1&g146_2==2 //coop

*-------------------------------------------------------------------------------
* Ingresos del capital
g bc_pg60p=g140/12 if bc_pf41==4 //patrón
g bc_pg60p_cpsl=g140/12 if bc_pf41==5 //cp s/l
g bc_pg60p_cpcl=g140/12 if bc_pf41==6 //cp c/l

g bc_pg80p=g140/12 if bc_pf41==3 //coop

g bc_pg60o=g140/12 if (bc_pg60p==0|bc_pg60p==.)&f87==4&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //patrón 
g bc_pg60o_cpsl=g140/12 if (bc_pg60p_cpsl==0|bc_pg60p_cpsl==.)&f87==5&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp s/l
g bc_pg60o_cpcl=g140/12 if (bc_pg60p_cpcl==0|bc_pg60p_cpcl==.)&f87==6&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //cp c/l

g bc_pg80o=g140/12 if (bc_pg80p==0|bc_pg80p==.)&f87==3&(bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6) //coop

*-------------------------------------------------------------------------------
* Otros lab
g bc_otros_lab=0
	replace bc_otros_lab=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_8+g122_4+g123_2+g124_3+g126_2+cuota_p+(g122_2*mto_des)+(g122_3*mto_alm)+g127_2+(g128_2*mto_vac)+(g128_3*mto_ove)+(g128_4*mto_cab)+g129_2+g129_3/12 +corr_sal_esp if (bc_pf41!=1&bc_pf41!=2)|bc_pf41==-9
	replace bc_otros_lab=bc_otros_lab+g139+g141_2+g141_3+g141_4+g141_5+g141_6+g141_7 if (bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f87!=3&f87!=4&f87!=5&f87!=6)|(bc_pf41==-9&f87==0) 
	replace bc_otros_lab=bc_otros_lab+g130_1+g130_2+g130_3+g130_4+g130_5+g130_6+g130_8+g131_4+g132_2+g133_3+g135_2+cuota_o+(g131_2*mto_des)+(g131_3*mto_alm)+g136_2+(g137_2*mto_vac)+(g137_3*mto_ove)+(g137_4*mto_cab)+g138_2+corr_sal_esp if (f87!=1&f87!=2)|f87==0

*-------------------------------------------------------------------------------
* Otros benef //ACÁ NO ESTÁ bc_pf41!=4 (PATRONES)
g bc_otros_benef=0
	replace bc_otros_benef=ytransf_4+ytransf_5
	replace bc_otros_benef=ytransf_4+ytransf_5+g145_24+bc_afam if bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&f87!=1&f87!=2&f87!=3&f87!=5&f87!=6 
	replace bc_otros_benef=ytransf_4+ytransf_5+g145_24+bc_afam+mto_hogc if bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&f87!=1&f87!=2&f87!=3&f87!=5&f87!=6&g146_1==1&g146_2==2
	*al jefe se le agrega yaliment_men
	replace bc_otros_benef=yaliment_men+ytransf_4+ytransf_5 if bc_pe4==1
	replace bc_otros_benef=yaliment_men+ytransf_4+ytransf_5+g145_24+bc_afam if bc_pe4==1&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&f87!=1&f87!=2&f87!=3&f87!=5&f87!=6
	replace bc_otros_benef=yaliment_men+ytransf_4+ytransf_5+g145_24+bc_afam+mto_hogc if bc_pe4==1&bc_pf41!=1&bc_pf41!=2&bc_pf41!=3&bc_pf41!=5&bc_pf41!=6&f87!=1&f87!=2&f87!=3&f87!=5&f87!=6&g146_1==1&g146_2==2
	
*-------------------------------------------------------------------------------
* Pagos atrasados
g bc_pag_at=g121_7+g130_7

*-------------------------------------------------------------------------------
* Otros suma pagos atrasados a indemnización por despido
g bc_otros=bc_pag_at
	replace bc_otros=(h164_2)/12+bc_pag_at if bc_pe4==1
*h166_2

*-------------------------------------------------------------------------------
* Ingreso ciudadano
g bc_ing_ciud=0
	replace bc_ing_ciud=bc_yciudada+bc_yalimpan if bc_pe4==1

*-------------------------------------------------------------------------------
* Jubilaciones o pensiones
g bc_pg91=g145_1+g145_2+g145_3+g145_4+g145_5+g145_6+g145_7+g145_8+g145_9+g145_10+g145_12+g145_13+g145_14+g145_15+g145_16+g145_17+g145_18+g145_19+g145_20+g145_21
g bc_pg92=g145_11+g145_22

g bc_pg911=g145_1+g145_2+g145_3+g145_4+g145_5+g145_6+g145_7+g145_8+g145_9+g145_10
g bc_pg921=g145_11

g bc_pg912=g145_12+g145_13+g145_14+g145_15+g145_16+g145_17+g145_18+g145_19+g145_20+g145_21
g bc_pg922=g145_22

*-------------------------------------------------------------------------------
* Otras transferencias
g bc_pg101=g145_23+g145_25
g bc_pg102=g145_26
g bc_pg111=g148_2
	replace bc_pg111=g148_2+h149_2+h150_2+cuot_otrohog_tot+emer_otro_tot+cuotmilit_otro_tot if bc_pe4==1
g bc_pg112=g148_3
	replace bc_pg112=g148_3+h165_2/12 if bc_pe4==1

g bc_pg121=h153_2/12+h156_1/12 if bc_pe4==1
g bc_pg122=0
	replace bc_pg122=h156_2/12+h153_3/12 if bc_pe4==1
g bc_pg131=0
	replace bc_pg131=h161_1/12 if bc_pe4==1
g bc_pg132=0
	replace bc_pg132=h161_2/12 if bc_pe4==1

*-------------------------------------------------------------------------------
* Otras utilidades imputables al hogar
g bc_otras_utilidades=0
	replace bc_otras_utilidades=g140/12 if (bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f87!=3&f87!=4&f87!=5&f87!=6)|(bc_pf41==-9&f87==0)
	replace bc_otras_utilidades=h163_1/12+h163_2/12+g140/12 if ((bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f87!=3&f87!=4&f87!=5&f87!=6)|(bc_pf41==-9&f87==0))&bc_pe4==1

g bc_ot_utilidades=0
	replace bc_ot_utilidades=h163_1/12+h163_2/12 if (bc_pf41==3|bc_pf41==4|bc_pf41==5|bc_pf41==6|f87==3|f87==4|f87==5|f87==6)&bc_pe4==1 

g bc_otras_capital=0
	replace bc_otras_capital=(g142+g143+g144)/12 // medianería, pastoreo y ganado a capitalizar a nivel persona
	replace bc_otras_capital=(g142+g143+g144+h157+h158+h159)/12 if bc_pe4==1 // medianería, pastoreo y ganado a capitalizar a nivel hogar

*-------------------------------------------------------------------------------
*missing
mvencode bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p bc_pg17p bc_pg27p bc_pg13p bc_pg23p bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o bc_pg13o bc_pg23o bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t ///
bc_pg31p bc_pg33p bc_pg41p bc_pg43p bc_pg51p bc_pg52p bc_pg71p bc_pg73p bc_pg32p bc_pg42p bc_pg72p bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg51o bc_pg52o bc_pg71o bc_pg73o bc_pg32o bc_pg42o bc_pg72o bc_pg60p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg80p bc_pg60o bc_pg60o_cpsl bc_pg60o_cpcl bc_pg80o bc_otros_lab bc_otros_benef ///
bc_pag_at bc_otros bc_ing_ciud bc_pg91 bc_pg92 bc_pg911 bc_pg921 bc_pg912 bc_pg922 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132 bc_pg14 bc_otras_utilidades bc_ot_utilidades bc_otras_capital, mv(0) override
