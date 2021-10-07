*- Valor locativo
foreach var in ht13 {
bys bc_correlat: egen max`var'=max(ht13)
replace `var' = max`var'
drop max`var'
}

cap drop bc_pg14
gen bc_pg14=0
	replace bc_pg14=d8_3 if (d8_1!=6 & (d8_1!=5 & loc!="900"))	// Código compatible
	replace bc_pg14=0 if ht13==0 & d8_1!=6					// Excepción porque nosotros no podemos identificar zonas rurales en Mdeo, entonces tomamos valor de INE

gen sal_esp_net=0
	replace sal_esp_net=g132_3-bc_pg14 if d8_1==6 & g132_3!=0 // Salario en especie neto de valor locativo para ocupantes en rel. de dependencia
	
gen corr_sal_esp=0
	replace corr_sal_esp=-bc_pg14 if sal_esp_net>0  // Corrección para salario en especie, es el valor locativo (*-1) si esta diferencia es positiva
	replace corr_sal_esp=-g132_3 if sal_esp_net<=0	// Corrección para salario en especie, es todo el salario en especie si la dif entre valor loc y salario es negativa

	
mvencode g129_2 g129_3 g135_2 g129_8  cuotmilit1 cuotmilit mto_emer, mv(0) override
capture drop bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p bc_pg21p bc_pg22p bc_pg23p bc_pg24p bc_pg25p bc_pg26p bc_pg27p 
gen bc_pg11p=g129_1 if bc_pf41==1 // sueldos o jornales líquidos trabajadores dependientes privados
gen bc_pg21p=g129_1 if bc_pf41==2 // sueldos o jornales líquidos trabajadores dependientes públicos
gen bc_pg12p=g129_2+g129_3+g135_2  if bc_pf41==1 // complementos salariales privados
gen bc_pg22p=g129_2+g129_3+g135_2  if bc_pf41==2 // complementos salariales públicos
gen bc_pg14p=g129_5 if bc_pf41==1
gen bc_pg24p=g129_5 if bc_pf41==2
gen bc_pg15p=g129_6 if bc_pf41==1
gen bc_pg25p=g129_6 if bc_pf41==2
gen bc_pg16p=g129_4 if bc_pf41==1 // propinas
gen bc_pg26p=g129_4 if bc_pf41==2 // propinas

cap drop mto_emerg
g mto_emerg=.
replace mto_emerg=278 if bc_mes==1
replace mto_emerg=278 if bc_mes==2
replace mto_emerg=281.25 if bc_mes==3
replace mto_emerg=309 if bc_mes==4
replace mto_emerg=285.25 if bc_mes==5
replace mto_emerg=285.25 if bc_mes==6
replace mto_emerg=277 if bc_mes==7
replace mto_emerg=290.75 if bc_mes==8
replace mto_emerg=297.75 if bc_mes==9
replace mto_emerg=298.25 if bc_mes==10
replace mto_emerg=298.25 if bc_mes==11

cap drop EMER_EMP
cap drop emer_emp_d
cap drop emer_emp
g emer_emp_d=(e48_1==1)
egen emer_emp= sum(emer_emp_d), by(bc_correlat e48_2)
g EMER_EMP=emer_emp*mto_emerg if bc_nper==e48_2
recode EMER_EMP (.=0)


mvencode g129_8 g130_4 g131_2 g134_2 mto_cuot , mv(0) override
cap drop cuota_p
gen cuota_p=g133_2*mto_cuot if g133_1==1 	// cuotas mututales no declaradas en el sueldo
recode cuota_p (. =0)						// para ocupación principal
/*
gen bc_pg17p=g129_8+g130_4+g131_2+g134_2+cuota_p+(g130_2*mto_des)+(g130_3*mto_alm)+g132_3+(g136_2*mto_vac)+ /*
*/ (g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+(g137_3/12) + corr_sal_esp if bc_pf41==1
 
gen bc_pg27p=g129_8+g130_4+g131_2+g134_2+cuota_p+(g130_2*mto_des)+(g130_3*mto_alm)+g132_3+(g136_2*mto_vac)+/*
*/ (g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+(g137_3/12) + corr_sal_esp if bc_pf41==2
*/

g bc_pg17p=g129_8+g130_4+g131_2+g132_3+g134_2+(g130_2*mto_des)+(g130_3*mto_alm)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+ /*
	*/(g137_3/12) +cuota_p+EMER_EMP + corr_sal_esp if bc_pf41==1
	replace bc_pg17p=g129_8+g130_4+g131_2+g132_3+g134_2+(g130_2*mto_des)+(g130_3*mto_alm)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+ /*
	*/ (g137_3/12) +cuotemp+EMER_EMP + corr_sal_esp if bc_pf41==1&cuota_p==0
 
g bc_pg27p=g129_8+g130_4+g131_2+g134_2+(g130_2*mto_des)+(g130_3*mto_alm)+g132_3+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+ /*
	*/(g137_3/12)+cuota_p +EMER_EMP+corr_sal_esp if bc_pf41==2
	replace bc_pg27p=g129_8+g130_4+g131_2+g134_2+(g130_2*mto_des)+(g130_3*mto_alm)+g132_3+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+ /*
	*/(g137_3/12)+cuotemp +EMER_EMP+corr_sal_esp if bc_pf41==2&cuota_p==0
	
	
mvencode ytransf_2 g153_24 mto_hogc bc_yciudada bc_yalimpan ytransf_4 ytransf_5  , mv(0) override
gen bc_pg13p=g153_24+mto_hogc if bc_pf41==1 
replace bc_pg13p=ytransf_2 +g153_24+mto_hogc   if bc_pf41==1 & g155_3==2

gen bc_pg23p=g153_24+mto_hogc if bc_pf41==2 
replace bc_pg23p=ytransf_2+g153_24+mto_hogc if bc_pf41==2 & g155_3==2

capture drop bc_pg11o bc_pg12o bc_pg14o bc_pg15o bc_pg16o bc_pg17o bc_pg21o bc_pg22o bc_pg24o bc_pg25o bc_pg26o bc_pg27o bc_pg13o bc_pg23o
gen bc_pg11o=g138_1 if f95==1
gen bc_pg21o=g138_1 if f95==2
gen bc_pg12o=g138_2+g138_3+g144_2 if f95==1
gen bc_pg22o=g138_2+g138_3+g144_2  if f95==2
gen bc_pg14o=g138_5 if f95==1
gen bc_pg24o=g138_5 if f95==2
gen bc_pg15o=g138_6 if f95==1
gen bc_pg25o=g138_6 if f95==2
gen bc_pg16o=g138_4 if f95==1
gen bc_pg26o=g138_4 if f95==2

cap drop cuota_o
gen cuota_o=g142_2*mto_cuot if g142_1==1	// cuotas mututales no declaradas en el sueldo
recode cuota_o (. =0)						// para ocupación secundaria
/*
gen bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12)   if f95==1
gen bc_pg27o=g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) if f95==2
*/

g bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ if f95==1
	replace bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ + EMER_EMP+cuota_o if f95==1&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)
	replace bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ + EMER_EMP+cuotemp+cuota_o if f95==1&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)&cuota_o==0
	
g bc_pg27o=g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ if f95==2
	replace bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ + EMER_EMP+cuota_o if f95==2&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)
	replace bc_pg17o=g138_8+g139_4+g140_2+g141_3+g143_2+(g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
	*/ + EMER_EMP+cuotemp+cuota_o if f95==2&(bc_pf41==7|bc_pf41==-9|bc_pf41==.)&cuota_o==0
	
	
gen bc_pg13o=g153_24+mto_hogc if f95==1 & (bc_pf41!=1 & bc_pf41!=2)
replace bc_pg13o=ytransf_2+g153_24+mto_hogc if f95==1 & (bc_pf41!=1 & bc_pf41!=2) & g155_3==2


gen bc_pg23o=g153_24+mto_hogc if f95==2 & (bc_pf41!=1 & bc_pf41!=2)
replace bc_pg23o=ytransf_2+g153_24+mto_hogc  if f95==2 & (bc_pf41!=1 & bc_pf41!=2) & g155_3==2

capture drop bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t
mvencode bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p bc_pg11o bc_pg12o bc_pg13o bc_pg14o bc_pg15o bc_pg16o bc_pg17o bc_pg21o bc_pg22o bc_pg23o bc_pg24o bc_pg25o bc_pg26o bc_pg27o, mv(0) override
gen bc_pg11t=bc_pg11o+bc_pg21o
gen bc_pg12t=bc_pg12o+bc_pg22o
gen bc_pg13t=bc_pg13o+bc_pg23o
gen bc_pg14t=bc_pg14o+bc_pg24o
gen bc_pg15t=bc_pg15o+bc_pg25o
gen bc_pg16t=bc_pg16o+bc_pg26o
gen bc_pg17t=bc_pg17o+bc_pg27o
		
capture drop  bc_pg32p
capture drop  bc_pg42p
capture drop  bc_pg72p
gen bc_pg32p=g153_24+mto_hogc if bc_pf41==5 
replace bc_pg32p=ytransf_2+g153_24+mto_hogc if bc_pf41==5 & g155_3==2
gen bc_pg42p=g153_24+mto_hogc if bc_pf41==6 
replace bc_pg42p=ytransf_2+g153_24+mto_hogc  if bc_pf41==6 & g155_3==2
gen bc_pg72p=g153_24+mto_hogc if bc_pf41==3 
replace bc_pg72p=ytransf_2+g153_24+mto_hogc if bc_pf41==3 & g155_3==2


capture drop  bc_pg32o
capture drop  bc_pg42o
capture drop  bc_pg72o
gen bc_pg32o=g153_24+mto_hogc if f95==5 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg32o=ytransf_2+g153_24+mto_hogc if f95==5 & g155_3==2 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
gen bc_pg42o=g153_24+mto_hogc if f95==6  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg42o=ytransf_2+g153_24+mto_hogc  if f95==6 & g155_3==2  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
gen bc_pg72o=g153_24+mto_hogc if f95==3  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg72o=ytransf_2+g153_24+mto_hogc if f95==3 & g155_3==2  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)


capture drop bc_pg31p bc_pg33p bc_pg41p bc_pg43p bc_pg51p bc_pg52p bc_pg71p bc_pg73p bc_pg60p bc_pg80p
/*
gen bc_pg31p=g147 if bc_pf41==5
gen bc_pg33p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if bc_pf41==5
gen bc_pg41p=g147 if bc_pf41==6
gen bc_pg43p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if bc_pf41==6
gen bc_pg51p=g147 if bc_pf41==4
gen bc_pg52p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if bc_pf41==4
gen bc_pg71p=g147 if bc_pf41==3
gen bc_pg73p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if bc_pf41==3
*/

gen bc_pg31p=g147 +(g150+g151+g152)/12 if bc_pf41==5
gen bc_pg33p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 +cuotemp+EMER_EMP if bc_pf41==5
gen bc_pg41p=g147 +(g150+g151+g152)/12 if bc_pf41==6
gen bc_pg43p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 +cuotemp+EMER_EMP if bc_pf41==6
gen bc_pg51p=g147 +(g150+g151+g152)/12 if bc_pf41==4
gen bc_pg52p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 +cuotemp+EMER_EMP if bc_pf41==4
gen bc_pg71p=g147 +(g150+g151+g152)/12 if bc_pf41==3
gen bc_pg73p=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 +cuotemp+EMER_EMP if bc_pf41==3

capture drop bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg51o bc_pg52o bc_pg71o bc_pg73o bc_pg60o bc_pg80o
gen bc_pg31o=g147 if (bc_pg31p==0|bc_pg31p==.) & f95==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) 
gen bc_pg33o=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if (bc_pg33p==0|bc_pg33p==.) & f95==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg41o=g147 if (bc_pg41p==0|bc_pg41p==.) & f95==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg43o=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if (bc_pg43p==0|bc_pg43p==.) & f95==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg51o=g147 if (bc_pg51p==0|bc_pg51p==.) & f95==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg52o=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if (bc_pg52p==0|bc_pg52p==.) & f95==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg71o=g147 if (bc_pg71p==0|bc_pg71p==.) & f95==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg73o=g149_2+g149_3+g149_4+g149_5+g149_6+g149_7 if (bc_pg73p==0|bc_pg73p==.) & f95==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
/*
capture drop bc_otros_lab
gen bc_otros_lab=0
replace bc_otros_lab=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_8+g130_4+g131_2+g132_3+g134_2+cuota_p+/*
*/ g153_24+(g130_2*mto_des)+(g130_3*mto_alm)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab) /*
*/ + g137_2+(g137_3/12) + corr_sal_esp if (bc_pf41!=1 & bc_pf41!=2) | bc_pf41==-9
*-Modifico siguiente línea 30/8/2018
*replace bc_otros_lab= g147+g149_2 if (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6 & f95!=3 & f95!=3 & f95!=4 & f95!=5 & f95!=6) | (bc_pf41==-9 & f95==0) 
replace bc_otros_lab=bc_otros_lab+g147+g149_2 if (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6 & f95!=3 & f95!=3 & f95!=4 & f95!=5 & f95!=6) | (bc_pf41==-9 & f95==0) 
*/

cap drop bc_otros_lab
gen bc_otros_lab=0
replace bc_otros_lab=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_8+g130_4+g131_2+g132_3+g134_2+ /*
*/ (g130_1*mto_desa)+(g130_3*mto_almu)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab) /*
*/ +g137_2+(g137_3/12)+g135_2 + corr_sal_esp + cuota_p if (bc_pf41!=1 & bc_pf41!=2)
replace bc_otros_lab=g147+g149_2 +(g150+g151+g152)/12 if (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6 & f92!=3 & f92!=4 & f92!=5 & f92!=6) 
replace bc_otros_lab=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_8+g130_4+g131_2+g132_3+g134_2+ /*
*/ (g130_1*mto_desa)+(g130_3*mto_almu)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab) /*
*/ +g137_2+(g137_3/12) + g147+g149_2 +(g150+g151+g152)/12 + corr_sal_esp + cuota_p if (bc_pf41!=1 & bc_pf41!=2) & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3 & f92!=3 & f92!=4 & f92!=5 & f92!=6) 
replace bc_otros_lab=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_8+g130_4+g131_2+g132_3+g134_2+ /*
*/ (g130_1*mto_desa)+(g130_3*mto_almu)+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab) /*
*/ +g137_2+(g137_3/12) + g147+g149_2 + (g150+g151+g152)/12 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + g135_2 + corr_sal_esp + cuota_p if bc_pf41==-9

/*
capture drop bc_otros_lab2
gen bc_otros_lab2=0
replace bc_otros_lab2=g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+ /*
*/ (g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) /*
*/ if (f95!=1 & f95!=2) | f95==0
*/

capture drop bc_otros_lab2
gen bc_otros_lab2=0
replace bc_otros_lab2=g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_8+g139_4+g140_2+g141_3+g143_2+cuota_o+ /*
*/ (g139_2*mto_des)+(g139_3*mto_alm)+(g145_2*mto_vac)+(g145_3*mto_ove)+(g145_4*mto_cab)+g146_2+(g146_3/12) if (f95!=1 & f95!=2) 

capture drop bc_otros_benef
gen bc_otros_benef=0
replace bc_otros_benef=ytransf_5+ytransf_4
replace bc_otros_benef=ytransf_5+g153_24+mto_hogc+ytransf_4 if bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6 & f95!=1 & f95!=2 & f95!=3 & f95!=5 & f95!=6 
replace bc_otros_benef=ytransf_5+ytransf_2+g153_24+mto_hogc+ytransf_4 if bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6  & g155_3==2 & f95!=1 & f95!=2 & f95!=3 & f95!=5 & f95!=6 
replace bc_otros_benef=ytransf_5+yaliment_men+ytransf_4 if e32==1
replace bc_otros_benef=ytransf_5+yaliment_men+g153_24+mto_hogc+ytransf_4 if e32==1 & bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6 & f95!=1 & f95!=2 & f95!=3 & f95!=5 & f95!=6 
replace bc_otros_benef=ytransf_5+yaliment_men+ytransf_2+g153_24+mto_hogc+ytransf_4 if e32==1 & bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6  & g155_3==2 & f95!=1 & f95!=2 & f95!=3 & f95!=5 & f95!=6 

cap drop bc_pag_at 
gen bc_pag_at=g129_7+g138_7
*******************


mvencode bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p bc_pg21p  bc_pg22p  bc_pg23p  bc_pg24p  bc_pg25p bc_pg26p bc_pg27p , mv(0) override

cap drop bc_ing_ciud
gen bc_ing_ciud=0
replace bc_ing_ciud=bc_yciudada+bc_yalimpan if e32==1

mvencode bc_pg32p bc_pg42p bc_pg72p, mv(0) override


mvencode bc_pg31p bc_pg41p bc_pg71p bc_pg33p bc_pg43p bc_pg73p, mv(0) override


mvencode g153_1 g153_2 g153_3 g153_4 g153_5 g153_6 g153_7 g153_8 g153_9 g153_10 g153_11 g153_12 g153_13 g153_14 g153_15 g153_16 g153_17 g153_18 g153_19 g153_20 g153_21 g153_22 , mv(0) override
cap drop bc_pg91 bc_pg92 bc_pg911 bc_pg921 bc_pg912 bc_pg922
gen bc_pg91=g153_1+ g153_2+g153_3+g153_4+g153_5+g153_6+g153_7+g153_8+g153_9+g153_10+g153_12+g153_13+g153_14+g153_15+g153_16+g153_17+g153_18+g153_19+g153_20+g153_21
gen bc_pg92=g153_11+g153_22
gen bc_pg911=g153_1+ g153_2+g153_3+g153_4+g153_5+g153_6+g153_7+g153_8+g153_9+g153_10
gen bc_pg921=g153_11
gen bc_pg912=g153_12+g153_13+g153_14+g153_15+g153_16+g153_17+g153_18+g153_19+g153_20+g153_21
gen bc_pg922=g153_22
mvencode bc_pg91 bc_pg92 bc_pg921 bc_pg911 bc_pg912 bc_pg922, mv(0) override

cap drop bc_pg101 bc_pg102
gen bc_pg101=0
replace bc_pg101=g153_23+g153_25
gen bc_pg102=g153_26 

cap drop bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132
gen bc_pg111=g156_2
replace bc_pg111=g156_2+h158_2+h159_2 if e32==1
gen bc_pg112=g156_3
replace bc_pg112=g156_3+h174_2/12 if e32==1

gen bc_pg121=0
replace bc_pg121=h162_2/12+h165_1/12 if e32==1
gen bc_pg122=0
replace bc_pg122=h165_2/12+h162_3/12 if e32==1
gen bc_pg131=0
replace bc_pg131=h170_1/12 if e32==1
gen bc_pg132=0
replace bc_pg132=h170_2/12 if e32==1

mvencode bc_pg14 bc_pg132 bc_pg131 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg122 bc_pg121, mv(0) override
*-------------------------------------------------------------------------------
*- Ingresos de capital

*capture drop bc_otras_utilidades
*gen bc_otras_utilidades=0
*replace bc_otras_utilidades=g148/12 if (bc_pf41!=3 & bc_pf41!=4 & f95!=3 & f95!=4 )| (bc_pf41==-9 & f95==0)
*replace bc_otras_utilidades=h172_1/12+h172_2/12+g148/12 if ((bc_pf41!=3 & bc_pf41!=4 & f95!=3 & f95!=4)| (bc_pf41==-9 & f95==0)) & e32==1 

*capture drop bc_ot_utilidades
*gen bc_ot_utilidades=0
*replace bc_ot_utilidades=h172_1/12+h172_2/12 if bc_pf41==3 | bc_pf41==4 | f95==3 | f95==4 & e32==1 

gen bc_pg60p=g148/12 if bc_pf41==4
gen bc_pg80p=g148/12 if bc_pf41==3
gen bc_pg60p_cpsl=g148/12 if bc_pf41==5
gen bc_pg60p_cpcl=g148/12 if bc_pf41==6

gen bc_pg60o=g148/12 if (bc_pg60p==0|bc_pg60p==.) & f95==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg80o=g148/12 if (bc_pg80p==0|bc_pg80p==.) & f95==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg60o_cpsl=g148/12 if (bc_pg60p_cpsl==0|bc_pg60p_cpsl==.) & f95==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg60o_cpcl=g148/12 if (bc_pg60p_cpcl==0|bc_pg60p_cpcl==.) & f95==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)

capture drop bc_otras_utilidades // Utilidades para quienes no son patrón, cooperativista o cuenta propia c/s local
gen bc_otras_utilidades=0
replace bc_otras_utilidades=g148/12 if (bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f95!=3&f95!=4&f95!=5&f95!=6)|(bc_pf41==-9&f95==0)
replace bc_otras_utilidades=h172_1/12+h172_2/12+g148/12 if ((bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f95!=3&f95!=4&f95!=5&f95!=6)| (bc_pf41==-9 &f95==0)) & bc_pe4==1

capture drop bc_ot_utilidades // Utilidades a nivel de hogar de patrón, cooperativista o cuenta propia c/s local
gen bc_ot_utilidades=0
replace bc_ot_utilidades=h172_1/12+h172_2/12 if (bc_pf41==3|bc_pf41==4|bc_pf41==5|bc_pf41==6|f95==3|f95==4|f95==5|f95==6) & bc_pe4==1

capture drop bc_otras_capital // Medianería, pastoreo y ganado a capitalizar a nivel de hogar
gen bc_otras_capital=0
replace bc_otras_capital=(h166+h167+h168)/12 if bc_pe4==1

capture drop bc_otros
gen bc_otros=0
replace bc_otros=(h173_2)/12+bc_pag_at+g157_2 if e32==1
replace bc_otros=bc_pag_at+g157_2 
