*4_ ----------------------------------------------------------------------------
* ESTAS PREGUNTAS DE CUOTAS PAGADAS POR EMPLEADOR EN EMPLEO PPAL Y OTRAS OCUP EN 2006
egen cuotas_tot= sum(g125_2_ing+g134_2), by(bc_correlat)

*-------------------------------------------------------------------------------
* CUOTA MILITAR GENERADA POR MIEMBRO DEL HOGAR
g bc_cuotmilit=(e44_2_1==1)
*Cuota militar generada por integrante otro hogar, más abajo (e44_2_1==2)
preserve
collapse (sum) bc_cuotmilit if e44_2_2>0, by (bc_correlat e44_2_2)
rename e44_2_2 bc_nper
sort bc_correlat bc_nper
save "$rutainterm/cuotmilit", replace
restore
sort bc_correlat bc_nper
cap drop _merge
cap drop bc_cuotmilit
merge 1:1 bc_correlat bc_nper using  "$rutainterm/cuotmilit"
drop if _merge==2
cap drop _merge
rename bc_cuotmilit bc_cuotmilit1
g bc_cuotmilit = bc_cuotmilit1*mto_cuot
recode bc_cuotmilit .=0

*le damos a prioridad a las cuotas no militares
g aux_cuotmilit=(e44_2_1==1|e44_2_1==2) // & ACÁ HAY QUE PNER QUE NO TENGA DERECHO EN NADA MÁS.



* ytransf_5 - cuota militar o policial no funcionario público
*aquí solo va cuota militar si la genera un miembro del hogar no func público
*luego reemplazo cero en cuotmilit porque sino se duplica el ingreso
*por eso hago acá esto y no junto a las otras transf
g ytransf_5=bc_cuotmilit if (f69!=2&f87!=2)
	replace bc_cuotmilit=0 if (f69!=2&f87!=2)

*-------------------------------------------------------------------------------
* CUOTA PAGADA POR BPS, DISSE O INSTITUCIÓN SIMILAR
g bc_cuotabps=mto_cuot if (e44_1==3&(pobpcoac==9|pobpcoac==10)) 
recode bc_cuotabps (.=0)

*-------------------------------------------------------------------------------
* Cuotas mutuales pagadas por empleador de miembro del hogar
g cuot_emp_d=(e44_1==1)
egen cuot_emp= sum(cuot_emp_d), by(bc_correlat e44_2)
g cuot_emp_tot=cuot_emp*mto_cuot if bc_nper==e44_2
recode cuot_emp_tot (.=0)

*-------------------------------------------------------------------------------
* Cuotas emergencia pagadas por empleador de miembro del hogar
g emer_emp_d=(e46_1==1)
egen emer_emp= sum(emer_emp_d), by(bc_correlat e46_2)
g emer_emp_tot=emer_emp*mto_emer if bc_nper==e46_2
recode emer_emp_tot (.=0)

*-------------------------------------------------------------------------------
* CUOTAS SALUD PAGADAS/GENERADAS POR OTROS HOGARES
* cuotas mutuales pagadas por otros hogares
g cuot_otrohog_d=0
	replace cuot_otrohog_d=1 if (e44_1==2|e44_1==5)
egen cuot_otrohog= sum(cuot_otrohog_d), by(bc_correlat)
g cuot_otrohog_tot=cuot_otrohog*mto_cuot
	replace cuot_otrohog_tot=0 if cuotas_tot>=cuot_otrohog&cuotas_tot>0&cuotas_tot!=.
		
* cuotas emergencia pagadas por otros hogares
g emer_otro_d=0
	replace emer_otro_d=1 if (e46_1==2|e46_1==6)
egen emer_otro= sum(emer_otro_d), by(bc_correlat)
g emer_otro_tot=emer_otro*mto_emer

* cuotas mutual milit generada por otros hogares
g cuotmilit_otro_d=(e44_2_1==2|(e44_2_1==0&e43_1==4&e44_1==0))
egen cuotmilit_otro= sum(cuotmilit_otro_d), by(bc_correlat)
g cuotmilit_otro_tot=cuotmilit_otro*mto_cuot
	replace cuotmilit_otro_tot=0 if cuotas_tot>=cuotmilit_otro&cuotas_tot>0&cuotas_tot!=.
	
	
*-------------------------------------------------------------------------------
* INGRESOS DE OP OS Y TINDE, INCLUYE DISSE, SANIDAD MILI O POLI
* ytdop - ytdos - ytinde - disse - SANIDAD MILITAR O POLICIAL
cap drop bc_ytdop 
cap drop bc_ytdos 
cap drop bc_ytinde 

g cuota_p=g125_2_ing*mto_cuot if g125_1==1 & bc_cuotmilit==0 //no saco cond de cuotmilit
	replace cuota_p=0 if cuotas_tot<cuotmilit_otro&cuotas_tot>0&cuotas_tot!=.
recode cuota_p .=0

g bc_ytdop=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_desa)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+cuota_p+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12+emer_emp_tot
	replace bc_ytdop=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_desa)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12+emer_emp_tot+cuot_emp_tot if cuot_emp_tot>0
	replace bc_ytdop=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_desa)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+bc_cuotmilit+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12+emer_emp_tot if bc_cuotmilit>0&bc_pf41==2
*la cuota por emergencia pagada por el empleador la sumo en ytdop (como ine en 2014)

g cuota_o=g134_2*mto_cuot if g134_1==1 &bc_cuotmilit==0 //no saco cond de cuotmilit
	replace cuota_o=0 if cuotas_tot<cuotmilit_otro&cuotas_tot>0&cuotas_tot!=.
recode cuota_o .=0

g bc_ytdos=g130_1+g130_2+g130_3+g130_4+g130_5+g130_6+g130_7+g130_8+(g131_2*mto_desa)+(g131_3*mto_alm)+g131_4+g132_2+g133_3+cuota_o+g135_2+g136_2+(g137_2*mto_vac)+(g137_3*mto_ovej)+(g137_4*mto_cab)+g138_2
	replace bc_ytdos=g130_1+g130_2+g130_3+g130_4+g130_5+g130_6+g130_7+g130_8+(g131_2*mto_desa)+(g131_3*mto_alm)+g131_4+g132_2+g133_3+bc_cuotmilit+g135_2+g136_2+(g137_2*mto_vac)+(g137_3*mto_ovej)+(g137_4*mto_cab)+g138_2 if bc_cuotmilit>0&bc_pf41!=2&f87==2

g bc_ytinde=g139+(g140/12)+g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+(g142/12)+(g143/12)+(g144/12)  

*-------------------------------------------------------------------------------
* disse_p, disse_o y disse
* el ine genera la variable disse sin distinguir entre ocupación ppal y sec
*esto hacía el ine y da mal
*g disse=mto_cuot if e44_1==3&((pobpcoac==2&(f78==1|f91==1))|pobpcoac==5)

g bc_disse  =mto_cuot if e44_1==3&pobpcoac==5 & aux_cuotmilit!=1 //seguro de paro
g bc_disse_p=mto_cuot if e44_1==3&pobpcoac==2&f78==1&aux_cuotmilit!=1
g bc_disse_o=mto_cuot if e44_1==3&pobpcoac==2&f91==1&bc_disse_p==0&aux_cuotmilit!=1
recode bc_disse bc_disse_p bc_disse_o (.=0)

*-------------------------------------------------------------------------------
* INGRESOS POR TRANSFERENCIAS
* ytransf_1
g ytransf_1=g145_1+g145_2+g145_3+g145_4+g145_5+g145_6+g145_7+g145_8+g145_9+g145_10+g145_11+g145_12+g145_13+g145_14+g145_15+g145_16+g145_17+g145_18+g145_19+g145_20+g145_21+g145_22+g145_23+g145_24+g145_25+g145_26 

* ytransf_2 - asignaciones
* bpc 2006 1482, 6bpc=8892// bpc 2005 (julio) 1397, 6bpc=8382
cap drop bpc
g bpc=0
	replace bpc=1397 if bc_mes==1 
	replace bpc=1482 if bc_mes!=1 

g suma=(g121_1+g121_2+g121_3+g130_1+g130_2+g130_3)*1.22 

g filtas1=((e31==1&g147_1==1)|e31==2)
egen sumah1=sum(suma) if filtas1==1, by (bc_correlat)
g asig_jefe1=.
	replace asig_jefe1=0.16*bpc if (sumah1<=6*bpc)&(e31==1&g147_1==1)
	replace asig_jefe1=0.08*bpc if (sumah1> 6*bpc)&(e31==1&g147_1==1)
g asig_jefe=asig_jefe1*g147_2

g filtas2=((e31==2&g147_1==1)|e31==1)
egen sumah2=sum(suma) if filtas2==1, by (bc_correlat)
g asig_con1=.
	replace asig_con1=0.16*bpc if (sumah2<=6*bpc)&(e31==2&g147_1==1)
	replace asig_con1=0.08*bpc if (sumah2> 6*bpc)&(e31==2&g147_1==1)
g asig_con=asig_con1*g147_2

g filtas3=1 if((e31>2&e31<14)&g147_1==1)
g asig_otro1=.
	replace asig_otro1=0.16*bpc if suma<=6*bpc&filtas3==1
	replace asig_otro1=0.08*bpc if suma> 6*bpc&filtas3==1
g asig_otro=asig_otro1*g147_2

recode asig_jefe .=0 
recode asig_con  .=0 
recode asig_otro .=0 

g bc_afam=asig_jefe+asig_con+asig_otro 

g ytransf_2=bc_afam if g147_3!=1 
recode ytransf_2 .=0

* ytransf_3 - hogc
g ytransf_3=mto_hogc if g146_1==1&g146_2==2
recode ytransf_3 .=0

* ytransf_4 - yaliment
g desay=(e58_2_1_1+e58_2_1_3+e58_2_2_1+e58_2_2_3+e58_2_3_1+e58_2_3_3+e58_2_4_1+e58_2_4_3+e58_2_5_1+e58_2_5_3+e58_2_6_1+e58_2_6_3)*4.3*mto_des

g almuer=(e58_2_1_2+e58_2_1_4+e58_2_2_2+e58_2_2_4+e58_2_3_2+e58_2_3_4+e58_2_4_2+e58_2_4_4+e58_2_5_2+e58_2_5_4+e58_2_6_2+e58_2_6_4)*4.3*mto_alm 

g comescol=.
	replace comescol=mto_alm*5*4.3 if (e58_2_7==7)
	replace comescol=mto_des*5*4.3 if (e58_2_7==8)
	replace comescol=(mto_alm+mto_des)*5*4.3 if (e58_2_7==9)
	replace comescol=(mto_alm+mto_des)*5*4.3 if (e58_2_7==10)
	replace comescol=(mto_alm+mto_des+mto_des)*5*4.3 if (e58_2_7==11)

g comehog=e59_2*mto_alm*4.3 if (e59_3==0 & e59_1==1) 
	replace comehog=e59_3*mto_alm if (e59_3>0 & e59_1==1)

g canasta=(e60_1_2*indacomu)+(e60_2_2*indabajo)+(e60_3_2*indaplom)+(e60_4_2*indapens)+(e60_5_2*indadiab)+(e60_6_2*indarena)+(e60_7_2*indarend)+(e60_8_2*indacel)+(e60_9_2*indatub)+(e60_10_2*indaonco)+(e60_11_2*indasida)

recode desay almuer comescol comehog canasta (.=0)  

g yaliment=desay+almuer+comescol+comehog+canasta if (e27>13)
recode yaliment (.=0)  

g ytransf_4=yaliment

* ytransf_6 - pensión alimenticia, separación, etc
g ytransf_6=g148_2+g148_3 
recode ytransf_6 (.=0)

recode ytransf_1 ytransf_2 ytransf_3 ytransf_4 ytransf_5 ytransf_6 (.=0)  

g bc_ytransf=ytransf_1+ytransf_2+ytransf_3+ytransf_4+ytransf_5+ytransf_6+bc_cuotabps

*-------------------------------------------------------------------------------
* INGRESOS TRABAJO
* pt2
* pt2priv
g pt2priv_1=.
	replace pt2priv_1=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_des)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+(g125_2_ing*mto_cuot)+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12 if f69==1
g pt2priv_2=.
	replace pt2priv_2=bc_disse_p if (f69==1&f78==1)

recode pt2priv_1 pt2priv_2 (.=0)  

g pt2priv=pt2priv_1+pt2priv_2

* pt2pub
g pt2pub=.
	replace pt2pub=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_des)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+(g125_2_ing*mto_cuot)+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12 if f69==2&bc_cuotmilit==0|f69==8
	replace pt2pub=g121_1+g121_2+g121_3+g121_4+g121_5+g121_6+g121_7+g121_8+(g122_2*mto_des)+(g122_3*mto_alm)+g122_4+g123_2+g124_3+bc_cuotmilit+g126_2+g127_2+(g128_2*mto_vac)+(g128_3*mto_ovej)+(g128_4*mto_cab)+g129_2+g129_3/12 if f69==2&bc_cuotmilit>0
*Para los públicos que tienen cuota militar se los sumo aquí
recode pt2pub (.=0) 

* pt2nodep
g pt2nodep_1=g139+(g140/12)+g141_2+g141_3+g141_4+g141_5+g141_6+g141_7+(g142/12)+(g143/12)+(g144/12) if (f69>2 & f69<7) 
g pt2nodep_2=bc_disse_p if ((f69>2&f69<7)&(f78==1))
recode pt2nodep_1 pt2nodep_2 (.=0)  

g pt2nodep=pt2nodep_1+pt2nodep_2 

*pt1 - pt2 - pt4

* pt2
g bc_pt2=pt2priv+pt2pub+pt2nodep 

* pt4
g bc_pt4=bc_ytdop+bc_ytdos+bc_ytinde+bc_disse_p+bc_disse_o+bc_disse 
 
* pt1
g pt1_1=bc_ytdop+bc_ytdos+bc_ytinde+bc_disse_p+bc_disse_o+bc_disse+bc_ytransf  
egen bc_pt1=sum(pt1_1), by(bc_correlat)
	replace bc_pt1=0 if bc_pe4!=1

*-------------------------------------------------------------------------------
* yciudada
rename yciudada bc_yciudada
recode bc_yciudada (.=0)
	replace bc_yciudada=0 if bc_nper!=1
*-------------------------------------------------------------------------------
* yalimpanes
cap drop men18
g men18=0
	replace men18=1 if e27<18
cap drop menor18
egen menor18=sum(men18), by(bc_correlat)
cap drop men18s
g men18s=menor18
	replace men18s=4 if menor18>4 & menor18!=.

g bc_yalimpan=0 
	replace bc_yalimpan=300 if h170==1 
	replace bc_yalimpan=450 if h170==1 & men18s==2
	replace bc_yalimpan=600 if h170==1 & men18s==3
	replace bc_yalimpan=800 if h170==1 & men18s==4
recode  bc_yalimpan (.=0)  
	replace bc_yalimpan=0 if bc_nper!=1
/*
yalimpanes estaba generada de forma qeu el primer tramo lo cobraran aquellos 
hogares con h170==1 & men18s==1. Sin embargo, los que no tienen menores a cargo
igualemente cobraban el beneficio como si hubiera un menor. Por tanto, cambio 
la condición. Ahora la variable del ine es idéntica a esta.
*/


*-------------------------------------------------------------------------------
* yaliment - menores del hogar
g yaliment_men1=0
	replace yaliment_men1=desay+almuer+comescol+comehog+canasta if (e27<=13)
egen yaliment_men=sum(yaliment_men1), by(bc_correlat)

*-------------------------------------------------------------------------------
* yhog - borro mto_cuot, mto_emer etc y pongo las nuevas que generé
g bc_yhog= h149_2+h150_2+(h153_2/12)+(h153_3/12)+(h156_1/12)+(h156_2/12)+(h157/12)+(h158/12)+(h159/12)+(h161_1/12)+(h161_2/12)+(h163_1/12)+(h163_2/12)+(h164_2/12)+(h165_2/12)+cuot_otrohog_tot+emer_otro_tot+cuotmilit_otro_tot+yaliment_men+bc_yciudada+bc_yalimpan

*-------------------------------------------------------------------------------
* ht13 -> hay diferencias con ine_ht13
*g bc_ht13=d7_3 if d7_1!=6&loc!="900"&d7_1!=5
*recode bc_ht13 (.=0)

/*
es un tema de loc, pero la variable locagr que está en la fusionada 
después de la revisión de casos no es la misma loc a la que se refieren los de ine, 
o eso parece. Porque tiene los 900 para interior pero no para montevideo
*/
 
*-------------------------------------------------------------------------------
* ht11_ine_iecon
g ht11_iecon_1=bc_pt1+ht13+bc_yhog if bc_pe4==1 
egen bc_ht11_iecon=max(ht11_iecon_1), by(bc_correlat)
