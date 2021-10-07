
*-------------------------------------------------------------------------------
* CUOTA MILITAR GENERADA POR MIEMBRO DEL HOGAR
g cuotmilit=(e46_1==1)
*Cuota militar generada por integrante otro hogar, más abajo (e46_1==2)
preserve
collapse (sum) cuotmilit if e46_2>0, by (bc_correlat e46_2)
rename e46_2 nper
sort bc_correlat nper
save "$rutainterm/cuotmilit", replace
restore
sort bc_correlat nper
cap drop _merge
cap drop cuotmilit
merge 1:1 bc_correlat nper using  "$rutainterm/cuotmilit"
drop if _merge==2
cap drop _merge
rename cuotmilit cuotmilit1
g cuotmilit = cuotmilit1*mto_cuot
recode cuotmilit .=0

* ytransf_5 - cuota militar o policial no funcionario público
*aquí solo va cuota militar si la genera un miembro del hogar no func público
*luego reemplazo cero en cuotmilit porque sino se duplica el ingreso
*por eso hago acá esto y no junto a las otras transf
g ytransf_5=cuotmilit if (f75!=2&f95!=2)
	replace cuotmilit=0 if (f75!=2&f95!=2)

*-------------------------------------------------------------------------------
* CUOTA PAGADA POR BPS, DISSE O INSTITUCIÓN SIMILAR
g cuotabps=mto_cuot if (e45_1==3&(pobpcoac==9|pobpcoac==10)) 
recode cuotabps (.=0)

*-------------------------------------------------------------------------------
* Cuotas emergencia pagadas por empleador de miembro del hogar
g emer_emp_d=(e48_1==1)
egen emer_emp= sum(emer_emp_d), by(bc_correlat e48_2)
g emer_emp_tot=emer_emp*mto_emer if nper==e48_2
recode emer_emp_tot (.=0)

*-------------------------------------------------------------------------------
* INGRESOS DE OP OS Y TINDE, INCLUYE DISSE, SANIDAD MILI O POLI
* ytdop_iecon - ytdos_iecon - ytinde_iecon - disse - SANIDAD MILITAR O POLICIAL
cap drop ytdop_iecon 
cap drop ytdos_iecon 
cap drop ytinde_iecon 

capture drop ytdop_iecon ytdos_iecon ytinde_iecon 

g ytdop_iecon=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desa)+(g130_3*mto_alm)+g130_4+g131_2+g132_3+(g133_2*mto_cuot)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ovej)+(g136_4*mto_cab)+g137_2+(g137_3/12)+emer_emp_tot 
	replace ytdop_iecon=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desa)+(g130_3*mto_alm)+g130_4+g131_2+g132_3+cuotmilit+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ovej)+(g136_4*mto_cab)+g137_2+(g137_3/12)+emer_emp_tot if cuotmilit>0&bc_pf41==2
*La cuota por emergencia pagada por el empleador la sumo en ytdop_iecon (como el ine en 2014)
*El ine no suma en ytdop_iecon (g133_2*mto_cuot) (no correspondería cuotmilit del replace), tampoco suma en ytdos_iecon (g142_2*mto_cuot), está el siguiente comentario en la sintaxis 2007:
/*De la sintaxis INE 2007 - fecha modificación: 08/12/2011
***********El ytdos_iecon de arriba estaba considerando las cuotas mutuales pagadas por el empleador, lo cual estaba duplicando el ingreso por este rubro ya que había sido registrado en ytdop_4*********   
***********Se modifica el ytdos_iecon el 7/12/11************
*/

g ytdos_iecon=g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_7+g138_8+(g139_2*mto_desa)+(g139_3*mto_alm)+g139_4+g140_2+g141_3+(g142_2*mto_cuot)+g143_2+g144_2+(g145_2*mto_vaca)+(g145_3*mto_ovej)+(g145_4*mto_cab)+g146_2+(g146_3/12)
	replace ytdos_iecon=g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_7+g138_8+(g139_2*mto_desa)+(g139_3*mto_alm)+g139_4+g140_2+g141_3+cuotmilit+g143_2+g144_2+(g145_2*mto_vaca)+(g145_3*mto_ovej)+(g145_4*mto_cab)+g146_2+(g146_3/12) if cuotmilit>0&bc_pf41!=2&f95==2

gen ytinde_iecon = g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12) + (g151/12) + (g152/12)  


*-------------------------------------------------------------------------------
* disse_p, disse_s y disse
* el ine genera la variable disse sin distinguir entre ocupación ppal y sec
*esto hacía el ine y da mal
*g disse=mto_cuot if e45_1==3&((pobpcoac==2&(f78==1|f91==1))|pobpcoac==5)
g disse  =mto_cuot if e45_1==3&pobpcoac==5 //seguro de paro
g disse_p=mto_cuot if e45_1==3&pobpcoac==2&f78==1
g disse_s=mto_cuot if e45_1==3&pobpcoac==2&f91==1&disse_p==0
recode disse disse_p disse_s (.=0)


*-------------------------------------------------------------------------------
* INGRESOS POR TRANSFERENCIAS
* ytransf_1
g ytransf_1=g153_1 + g153_2 + g153_3 + g153_4 + g153_5 + g153_6 + g153_7 + g153_8 + g153_9 + g153_10 + g153_11/*
*/+ g153_12 + g153_13 + g153_14 + g153_15 + g153_16 + g153_17 + g153_18 + g153_19 + g153_20 + g153_21 + g153_22 + g153_23/*
*/+ g153_24 + g153_25 + g153_26

generate filtas=0
replace filtas=1 if ((e32 == 1 & g155_1 == 1 & g155_3 == 2) | e32==2 )

generate suma=(g129_1+g129_2+g129_3+g138_1+g138_2+g138_3)*1.25
egen sumah=sum(suma) if filtas==1, by (bc_correlat)

* ytransf_2 - asignaciones
* bpc 2006 1482, 6bpc=8892// bpc 2005 (julio) 1397, 6bpc=8382

capture drop asig_jefe1
generate asig_jefe1=.
replace asig_jefe1 = 261.76 if (sumah <= 9816)& (e32 == 1 & g155_1 == 1 & g155_3 == 2)
replace asig_jefe1 = 130.88 if (sumah > 9816) & (e32 == 1 & g155_1 == 1 & g155_3 == 2)

*drop asig_jefe
generate asig_jefe = asig_jefe1*g155_2

generate filtas2=1 if ((e32 == 2 & g155_1 == 1 & g155_3 == 2) | e32==2 )


*drop asig_con1
generate asig_con1=.
replace asig_con1 = 261.76 if (sumah <= 9816)& (e32 == 2 & g155_1 == 1 & g155_3 == 2)
replace asig_con1 = 130.88 if (sumah > 9816) & (e32 == 2 & g155_1 == 1 & g155_3 == 2)
*capture drop asig_con
generate asig_con = asig_con1*g155_2

generate filtas3=1 if((e32 > 2 & e32<14) & g155_1 == 1 & g155_3 == 2)

*capture drop  asig_otro1
generate asig_otro1=.
replace asig_otro1 = 261.76 if (suma) <= 9816 & filtas3==1
replace asig_otro1 = 130.88 if (suma) > 9816 & filtas3==1
*capture drop  asig_otro
generate asig_otro = asig_otro1*g155_2

recode asig_jefe .=0 
recode  asig_con  .=0 
recode  asig_otro .=0 

generate ytransf_2  = asig_jefe + asig_con + asig_otro  if (g155_1==1 & g155_3==2)

gen bc_afam=0
replace bc_afam= asig_jefe + asig_con + asig_otro  if g155_1==1 // Se imputa asignación, esté o no incluida en el sueldo

* ytransf_3 - hogc
g ytransf_3=mto_hogc if g146_1==1&g146_2==2
recode ytransf_3 .=0

* ytransf_4 - yaliment
gen desay = ( e60_2_1_1 + e60_2_1_3+ e60_2_2_1 + e60_2_2_3 + e60_2_3_1 + e60_2_3_3 + e60_2_4_1 /*
*/+ e60_2_4_3 + e60_2_5_1 + e60_2_5_3 + e60_2_6_1 + e60_2_6_3)*4.3*mto_desa 

gen almuer = ( e60_2_1_2 + e60_2_1_4 + e60_2_2_2 + e60_2_2_4 + e60_2_3_2 + e60_2_3_4 + e60_2_4_2 /*
*/+ e60_2_4_4 + e60_2_5_2 + e60_2_5_4 + e60_2_6_2 + e60_2_6_4)*4.3*mto_alm 

gen comescol = mto_alm*5*4.3 if e60_2_7==7
	replace comescol = mto_des*5*4.3 if e60_2_7==8
	replace comescol = (mto_alm+mto_des)*5*4.3 if e60_2_7==9
	replace comescol = (mto_alm+mto_des)*5*4.3 if e60_2_7==10
	replace comescol = (mto_alm+mto_des+mto_des)*5*4.3 if e60_2_7==11

generate comehog = e61_2*mto_alm*4.3 if (e61_1==1 & e61_3==0) 
replace comehog = e61_3*mto_alm if (e61_1==1 & e61_2==0)
recode comehog .=0
generate canasta =(e62_1_2*indacomu)+(e62_2_2*indabajo)+(e62_3_2*indaplom)+(e62_4_2*indapens)+(e62_5_2*indadiab)/*
*/+(e62_6_2*indarena)+(e62_7_2*indarend)+(e62_8_2*indacel)+(e62_9_2*indatub)+(e62_10_2*indaonco)+(e62_11_2*indasi)/*
*/+(e62_12_2*otrcanas)

recode desay    (.=0)  
recode almuer   (.=0)  
recode comescol (.=0)  
recode comehog  (.=0)  
recode canasta  (.=0)  

g yaliment=desay+almuer+comescol+comehog+canasta if (e27>13)
recode yaliment (.=0)  

g ytransf_4=yaliment

* ytransf_6 - pensión alimenticia, separación, etc
g ytransf_6=g156_2+g156_3 
recode ytransf_6 .=0

recode ytransf_2 (.=0)  
recode ytransf_3 (.=0)  
recode ytransf_4 (.=0)  
recode ytransf_1 (.=0)  
recode ytransf_5 (.=0)  
recode ytransf_6 (.=0)  

g ytransf_iecon=ytransf_1+ytransf_2+ytransf_3+ytransf_4+ytransf_5+ytransf_6+cuotabps

*-------------------------------------------------------------------------------
* INGRESOS TRABAJO
* pt2_iecon
gen pt2priv_1 = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_des)+(g130_3*mto_alm)+g130_4+g131_2/*
*/ +g132_3+(g133_2*mto_cuo)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+(g137_3/12) if f75==1
recode pt2priv_1 .=0

*cambio y por o
gen pt2priv_2= disse if (f75==1 & f85==1) 
recode  pt2priv_2 (.=0)  

generate pt2priv = pt2priv_1 + pt2priv_2

**** PT2 PUB

gen pt2pub_1=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_des)+(g130_3*mto_alm)+g130_4+g131_2+g132_3/*
*/+(g133_2*mto_cuo)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ov)+(g136_4*mto_cab)+g137_2+(g137_3/12) if f75==2|f75==8 
recode pt2pub_1 .=0 

gen pt2pub_2=cuotmilit if (f75==2 & g133_2 ==0) 
recode pt2pub_2 .=0

gen pt2pub_3= mto_cuot if (f75==2 & f76==1 & pt2pub_2==0 & e45_1 == 3) 
recode pt2pub_3 .=0

gen pt2pub = pt2pub_1+ pt2pub_2 
replace pt2pub= pt2pub_1+pt2pub_2 + pt2pub_3 if bc_mes>8

generate pt2nodep_1= g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12)/*
*/+ (g151/12) + (g152/12) if (75>2 & f75<7) 
generate pt2nodep_2 = disse if ((f75>2 & f75<7) & (f85==1))

recode pt2nodep_1  (.=0)  
recode pt2nodep_2  (.=0)  

generate pt2nodep=pt2nodep_1 + pt2nodep_2 

capture drop pt1_iecon pt2_iecon pt4_iecon
generate pt2_iecon= pt2priv + pt2pub + pt2nodep 

*** PT4
capture drop pt4_iecon
generate pt4_iecon = ytdop_iecon + ytdos_iecon + ytinde_iecon+ disse  
replace pt4_iecon = ytdop_iecon + ytdos_iecon + ytinde_iecon+ disse + cuotmilit if (f75==2 & g133_2 ==0) |(f95==2 & g142_2 ==0) 


**** PT1
capture drop pt1_iecon 
gen pt1_iecon= ytdop_iecon + ytdos_iecon + ytinde_iecon + disse + ytransf_iecon  + g157_2
replace pt2_iecon= ytdop_iecon + ytdos_iecon + ytinde_iecon + disse + ytransf_iecon + g157_2 + cuotmilit if (f75==2 & g133_2 ==0) | (f95==2 & g142_2 ==0)

recode pt1_iecon .=0
recode pt2_iecon .=0
recode pt4_iecon .=0

*-------------------------------------------------------------------------------
* bc_yalimpan
cap drop men18
g men18=0
	replace men18=1 if e27<18
cap drop menor18
egen menor18=sum(men18), by(bc_correlat)
cap drop men18s
g men18s=menor18
	replace men18s=4 if menor18>4 & menor18!=.
/*
gen bc_yalimpan=e67_2 if  (e67_1==1)
recode bc_yalimpan .=0
*/
/*
bc_yalimpan estaba generada de forma qeu el primer tramo lo cobraran aquellos 
hogares con h170==1 & men18s==1. Sin embargo, los que no tienen menores a cargo
igualemente cobraban el beneficio como si hubiera un menor. Por tanto, cambio 
la condición. Ahora la variable del ine es idéntica a esta.
*/
*-------------------------------------------------------------------------------
*- Se re-define bc_yalimpan 14/11/2018

cap drop bc_yalimpan
gen bc_yalimpan=0
replace bc_yalimpan= 300 if menor18==1 & e67_2!=0
replace bc_yalimpan= 450 if menor18==2 & e67_2!=0
replace bc_yalimpan= 600 if menor18==3 & e67_2!=0
replace bc_yalimpan= 800 if menor18>3  & e67_2!=0
*-------------------------------------------------------------------------------
* CUOTAS SALUD PAGADAS/GENERADAS POR OTROS HOGARES
* cuotas mutuales pagadas por otros hogares
g cuot_otrohog_d=0
	replace cuot_otrohog_d=1 if (e45_1==2|e45_1==5)
egen cuot_otrohog= sum(cuot_otrohog_d), by(bc_correlat)
g cuot_otrohog_tot=cuot_otrohog*mto_cuot

* cuotas emergencia pagadas por otros hogares
g emer_otro_d=0
	replace emer_otro_d=1 if (e48_1==2|e48_1==6)
egen emer_otro= sum(emer_otro_d), by(bc_correlat)
g emer_otro_tot=emer_otro*mto_emer

* cuotas mutual milit pagadas por otros hogares
g cuotmilit_otro_d=(e48_1==2)
egen cuotmilit_otro= sum(cuotmilit_otro_d), by(bc_correlat)
g cuotmilit_otro_tot=cuotmilit_otro*mto_cuot

*-------------------------------------------------------------------------------
*- Cuota paga por empleador
gen aux_emp=0
replace aux_emp=1 if e45_1==1

egen cuotemp= sum(aux_emp) if e45_2>0, by(bc_correlat e45_2)
rename cuotemp cuotemp1
g cuotemp=cuotemp1*mto_cuot if bc_nper==e45_2
recode cuotemp .=0
*-------------------------------------------------------------------------------
* yaliment - menores del hogar
g yaliment_men1=0
	replace yaliment_men1=desay+almuer+comescol+comehog+canasta if (e27<=13)
egen yaliment_men=sum(yaliment_men1), by(bc_correlat)
*-------------------------------------------------------------------------------
recode yciudada (.=0), gen(bc_yciudada)
	replace bc_yciudada=0 if bc_nper!=1
*-------------------------------------------------------------------------------
* bc_yhog - borro mto_cuot, mto_emer etc y pongo las nuevas que generé
gen bc_yhog= h158_2+h159_2+(h162_2/12)+(h162_3/12)+(h165_1/12)+(h165_2/12)+(h166/12)+(h167/12)+(h168/12)/*
*/+(h170_1/12)+(h170_2/12)+(h172_1/12)+(h172_2/12)+(h173_2/12)+(h174_2/12)+bc_yciudada+bc_yalimpan+mto_cuot/*
*/+cuotmilit+mto_emer+yaliment_men

*-------------------------------------------------------------------------------
* ht11_ine_iecon
g ht11_iecon_1=pt1_iecon+ht13+bc_yhog if bc_pe4==1 
egen ht11_iecon=max(ht11_iecon_1), by(bc_correlat)
