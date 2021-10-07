**************************************
**************************************
*****     Sintaxis2_cmilitar     *****
**************************************
**************************************


*-------------------------------------------------------------------------------
* CUOTA MILITAR GENERADA Por MIEMBRO DEL HOGAR


* Se calcula cuotas militares, adjudicadas a militar que las genera.
* Se toma a quienes tienen derecho en sanidad militar a través de un miembro de este hogar y a su vez no generan derecho por FONASA ya sea por miembro del hogar o por otro hogar.
gen at_milit=1 if e46_1==1
recode  at_milit .=0
egen cuotmilit= sum(at_milit) if e46_2>0, by(bc_correlat e46_2)
rename cuotmilit cuotmilit1
generate cuotmilit = cuotmilit1*mto_cuot if bc_nper==e46_2 // 29/10 se estaban sumando todas las cuotas militares
recode cuotmilit .=0

* Cuota BPS
gen cuotabps=mto_cuot if (e45_1==3 & (pobpcoac==9 | pobpcoac==10)) & at_milit!=1 // Le agrego at_milit!=1 20/11/18
recode cuotabps  .=0

*** Cuota emergencia
gen mto_emerg=.
replace mto_emerg=309 if bc_mes==1
replace mto_emerg=309 if bc_mes==2
replace mto_emerg=309 if bc_mes==3
replace mto_emerg=312.5 if bc_mes==4
replace mto_emerg=312.5 if bc_mes==5
replace mto_emerg=315.5 if bc_mes==6
replace mto_emerg=320 if bc_mes==7
replace mto_emerg=305.5 if bc_mes==8
replace mto_emerg=325.5 if bc_mes==9
replace mto_emerg=325.5 if bc_mes==10
replace mto_emerg=329.5 if bc_mes==11
replace mto_emerg=334.25 if bc_mes==12

egen EMER_EMP = sum(mto_emerg) if e48_1==2, by (bc_correlat)
replace EMER_EMP = 0 if bc_nper!=1

**** YTDOP - YTDOS - YTINDE - DISSE - SANIDAD MILITAR O POLICIAL
capture drop YTDOP YTDOS YTINDE 

generate YTDOP = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desa)+(g130_3*mto_alm)+g130_4+g131_2/*
*/ +g132_3+(g133_2*mto_cuot)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ovej)+(g136_4*mto_cab)+g137_2+(g137_3/12) + EMER_EMP 

gen YTDOS = g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_7+g138_8+(g139_2*mto_desa)+(g139_3*mto_alm)+g139_4+g140_2/*
*/ +g141_3+(g142_2*mto_cuot)+g143_2+g144_2+(g145_2*mto_vac)+(g145_3*mto_ovej)+(g145_4*mto_cab)+g146_2 +(g146_3/12)

gen YTINDE = g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12) + (g151/12) + (g152/12)  

gen menor18=0
replace menor18=1 if e28<18

* por el diseño del formulario quienes contestan e45_1==3 es porque tienen derechos de salud en mutualista o seguro privado)
generate fonasa = mto_cuot if e45_1==3 & (((pobpcoac==2 & (f85==1 |f99==1)) | pobpcoac==5))  & at_milit!=1 
recode fonasa  .=0

gen cuota_fonasa_msp=0
replace cuota_fonasa_msp=mto_cuot if (f85==1 | f99==1) & pobpcoac==2 & ((e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2) )

gen fonasa_menor1= mto_cuot if menor18==1 & e45_1==3 & (pobpcoac!=2 | (pobpcoac==2 & f85!=1 & f99!=1)) & at_milit!=1 // Agrego at_milit!=1 20/11/18
recode fonasa_menor1  .=0

gen msp_adult_fon=0
replace msp_adult_fon=1 if (f85==1 | f99==1) & pobpcoac==2 

egen msp_adult_fonh= sum (msp_adult_fon), by (bc_correlat)

gen msp_menor_fon=0
replace msp_menor_fon=1 if (msp_adult_fonh>0 & (e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2) & (pobpcoac!=2 | pobpcoac==2 & f85!=1 & f99!=1) & menor18==1)  
 

gen cuota_fon_msp_men1=0
replace cuota_fon_msp_men1=msp_menor_fon*mto_cuot if msp_menor_fon>0
replace cuota_fon_msp_men1=0 // AGREGO ESTO PARA PROBAR

*-------------------------------------------------------------------------------
*- 26/10 Código para captar seguro de salud pago por empleador

gen aux_emp=0
replace aux_emp=1 if e45_1==1

egen cuotemp= sum(aux_emp) if e45_2>0, by(bc_correlat e45_2)
rename cuotemp cuotemp1
g cuotemp=cuotemp1*mto_cuot if bc_nper==e45_2
recode cuotemp .=0
* INGRESOS POR TRANSFERENCIAS


**** YTRANSF
gen  YTRANSF_1 = g153_1 + g153_2 + g153_3 + g153_4 + g153_5 + g153_6 + g153_7 + g153_8 + g153_9 + g153_10 + g153_11/*
*/+ g153_12 + g153_13 + g153_14 + g153_15 + g153_16 + g153_17 + g153_18 + g153_19 + g153_20 + g153_21 + g153_22 + g153_23/*
*/+ g153_24 + g153_25 + g153_26

generate filtas=0
replace filtas=1 if ((e32 == 1 & g155_1 == 1 & g155_3 == 2) | e32==2 )

generate suma=(g129_1+g129_2+g129_3+g138_1+g138_2+g138_3)*1.25
egen sumah=sum(suma) if filtas==1, by (bc_correlat)

* ytransf_2 - asignaciones

capture drop asig_jefe1
generate asig_jefe1=.
replace asig_jefe1 = 0.16*bpc if (sumah <= 6*bpc)& (e32 == 1 & g155_1 == 1 & g155_3 == 2)
replace asig_jefe1 = 0.08*bpc if (sumah > 6*bpc) & (e32 == 1 & g155_1 == 1 & g155_3 == 2)

*drop asig_jefe
generate asig_jefe = asig_jefe1*g155_2

generate filtas2=1 if ((e32 == 2 & g155_1 == 1 & g155_3 == 2) | e32==2 )


*drop asig_con1
generate asig_con1=.
replace asig_con1 = 0.16*bpc if (sumah <= 9816)& (e32 == 2 & g155_1 == 1 & g155_3 == 2)
replace asig_con1 = 0.08*bpc if (sumah > 9816) & (e32 == 2 & g155_1 == 1 & g155_3 == 2)
*capture drop asig_con
generate asig_con = asig_con1*g155_2

generate filtas3=1 if((e32 > 2 & e32<14) & g155_1 == 1 & g155_3 == 2)

*capture drop  asig_otro1
generate asig_otro1=.
replace asig_otro1 = 0.16*bpc if (suma) <= 9816 & filtas3==1
replace asig_otro1 = 0.08*bpc if (suma) > 9816 & filtas3==1
*capture drop  asig_otro
generate asig_otro = asig_otro1*g155_2

recode asig_jefe .=0 
recode  asig_con  .=0 
recode  asig_otro .=0 

generate YTRANSF_2  = asig_jefe + asig_con + asig_otro  if (g155_1==1 & g155_3==2)

gen bc_afam= 0
replace bc_afam= asig_jefe + asig_con + asig_otro  if g155_1==1 // Se imputa asignación, esté o no incluida en el sueldo


recode mto_hogc .=0
generate YTRANSF_3 = mto_hogc if g154_1==1 & g154_2==2
recode YTRANSF_3 .=0


generate YTRANSF_6 = g156_2+g156_3 
recode YTRANSF_6 .=0


*** YALIMENT *** 
gen DESAYMER = ( e59_2__a + e59_2__c + e59_2__e + e59_2__g+ e59_2__i+ e59_2__k + e59_2__m+ e59_2__o + e59_2__q+ e59_2__s+ e59_2__u+ e59_2__w)*4.3*mto_desa 

gen ALMYCEN = ( e59_2__b+ e59_2__d+ e59_2__f+ e59_2__h+ e59_2__j+ e59_2__l + e59_2__n+ e59_2__p+ e59_2__r+ e59_2__t+ e59_2__v + e59_2__x)*4.3*mto_alm 


gen COMESCOL = mto_alm*5*4.3 if e59_2_7==7
replace COMESCOL = mto_des*5*4.3 if e59_2_7==8
replace COMESCOL = (mto_alm+mto_des)*5*4.3 if e59_2_7==9
replace COMESCOL = (mto_alm+mto_des)*5*4.3 if e59_2_7==10
replace COMESCOL = (mto_alm+mto_des+mto_des)*5*4.3 if e59_2_7==11

/*Se considera más verdadera la información semanal, por lo que se considera la información mensual si responde solo mensual y semanal si responde solo semanal
o los dos*/
g COMEHOG = e60_3*mto_alm if (e60_1==1 & e60_3!=0)
replace COMEHOG = e60_2*mto_alm*4.3 if (e60_1==1 & e60_2!=0) 
recode COMEHOG .=0

generate CANASTA =(e61_1_2*indacomu)+(e61_2_2*indabajo)+(e61_3_2*indaplom)+(e61_4_2*indapens)+(e61_5_2*indadiab)/*
*/+(e61_6_2*indarena)+(e61_7_2*indarend)+(e61_8_2*indacel)+(e61_9_2*indatub)+(e61_10_2*indaonco)+(e61_11_2*indasi)/*
*/+(e61_12_2*otrcanas)

recode DESAYMER  (.=0)  
recode ALMYCEN  (.=0)  
recode COMESCOL (.=0)  
recode COMEHOG  (.=0)  
recode CANASTA (.=0)  

generate YALIMENT=DESAYMER + ALMYCEN + COMESCOL + COMEHOG +CANASTA if (e28>13)
 
recode YALIMENT (.=0)  

generate YTRANSF_4 = YALIMENT 

*cambio aquí solo va cuota militar si la genera una persona dentro del hogar que no es funcionaria publica

generate YTRANSF_5= cuotmilit if (f75!=2 & f95!=2)

recode YTRANSF_2  (.=0)  
recode  YTRANSF_3 (.=0)  
recode YTRANSF_4  (.=0)  
recode YTRANSF_1  (.=0)  
recode YTRANSF_5  (.=0)  
recode YTRANSF_6 (.=0)  


generate YTRANSF = YTRANSF_1 + YTRANSF_2 + YTRANSF_3 + YTRANSF_4 + YTRANSF_5 + YTRANSF_6 +cuotabps

**** pt2_iecon PRIV
gen PT2PRIV_1 = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_des)+(g130_3*mto_alm)+g130_4+g131_2/*
*/ +g132_3+(g133_2*mto_cuo)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ove)+(g136_4*mto_cab)+g137_2+(g137_3/12) if f75==1
recode PT2PRIV_1 .=0

gen PT2PRIV_2= mto_cuot if (f75==1 & f85==1 & e45_1==3) 
recode  PT2PRIV_2 (.=0)  
gen PT2PRIV_3= mto_cuot if (f75==1 & PT2PRIV_2==0 & f85==1 & (e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2))
recode PT2PRIV_3 .=0

generate PT2PRIV = PT2PRIV_1 + PT2PRIV_2 + PT2PRIV_3

**** PT2 PUB

gen PT2PUB_1=g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_des)+(g130_3*mto_alm)+g130_4+g131_2+g132_3/*
*/+(g133_2*mto_cuot)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ov)+(g136_4*mto_cab)+g137_2+(g137_3/12) if f75==2|f75==8 
recode PT2PUB_1 .=0 

gen PT2PUB_2=cuotmilit if (f75==2 & g133_2 ==0) 
recode PT2PUB_2 .=0

gen PT2PUB_3= mto_cuot if (f75==2 & f76!=4 & PT2PUB_2==0 & f85==1 & e45_1 == 3) 
recode PT2PUB_3 .=0
gen PT2PUB_4= mto_cuot if (f75==2 & f76!=4 & PT2PUB_3==0 & PT2PUB_2==0 & f85==1 & (e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2)) 
recode PT2PUB_4 .=0

gen PT2PUB = PT2PUB_1+ PT2PUB_2 + PT2PUB_3 + PT2PUB_4


generate PT2NODEP_1= g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12)/*
*/+ (g151/12) + (g152/12) if (f75>2 & f75<7) 
generate PT2NODEP_2 = fonasa if ((f75>2 & f75<7) & (f85==1) & e45_1==3)

gen PT2NODEP_3 = mto_cuot if ((f75>2 & f75<7) & (f85==1) & PT2NODEP_2==0 & (e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2)) 

recode PT2NODEP_1  (.=0)  
recode PT2NODEP_2  (.=0)  
recode PT2NODEP_3  (.=0)  

generate PT2NODEP=PT2NODEP_1 + PT2NODEP_2 + PT2NODEP_3 

capture drop pt1_iecon pt2_iecon pt4_iecon
generate pt2_iecon= PT2PRIV + PT2PUB + PT2NODEP 

*** pt4_iecon
capture drop pt4_iecon
generate pt4_iecon = YTDOP + YTDOS + YTINDE + fonasa + cuota_fonasa_msp 
replace pt4_iecon = YTDOP + YTDOS + YTINDE + fonasa + cuota_fonasa_msp + cuotmilit if ((f75==2 & g133_2==0 & e46_2==bc_nper ) | (f95==2 & g142_2==0 & e46_2==bc_nper))


**** pt1_iecon
capture drop pt1_iecon 
gen pt1_iecon= YTDOP + YTDOS + YTINDE + fonasa + cuota_fonasa_msp + YTRANSF  + g157_2 
replace pt1_iecon= YTDOP + YTDOS + YTINDE + fonasa + cuota_fonasa_msp + YTRANSF + g157_2 + cuotmilit if ((f75==2 & g133_2==0 & e46_2==bc_nper ) | (f95==2 & g142_2==0 & e46_2==bc_nper))

recode pt2_iecon .=0
recode pt1_iecon .=0
recode pt4_iecon .=0

*Cuota para otro hogar
gen aux=.
replace aux= 1 if e45_1 == 2
egen auxh=sum(aux), by (bc_correlat)

gen CUOT_OTROHOG = auxh*mto_cuot
replace CUOT_OTROHOG =0 if bc_nper!=1
drop aux auxh

*Cuota militar otro hogar
gen aux=.
replace aux= 1 if e46_1==2
egen auxh=sum(aux), by (bc_correlat)


gen cuotmilit_hogar = auxh*mto_cuot
drop aux auxh
gen YALIMENT_MEN1=DESAYMER + ALMYCEN + COMESCOL + COMEHOG +CANASTA if (e28<14)
egen YALIMENT_MEN=sum(YALIMENT_MEN1), by (bc_correlat)
replace YALIMENT_MEN = 0 if bc_nper!=1


egen cuota_fon_msp_men=sum(cuota_fon_msp_men1), by(bc_correlat)
replace cuota_fon_msp_men = 0 if bc_nper!=1

egen totfonasa_hogar2 =sum(fonasa_menor1), by(bc_correlat)
replace totfonasa_hogar2  = 0 if bc_nper!=1

gen yhog_iecon= h158_2+h159_2+(h162_2/12)+(h162_3/12)+(h165_1/12)+(h165_2/12)+(h166/12)+(h167/12)+(h168/12)/*
*/+(h170_1/12)+(h170_2/12)+(h172_1/12)+(h172_2/12)+(h173_2/12)+(h174_2/12)+mto_cuot/*
*/+cuotmilit_hogar+YALIMENT_MEN + totfonasa_hogar2 + cuota_fon_msp_men

egen HPT1=sum(pt1_iecon), by(bc_correlat)

g ht11_iecon= HPT1+ine_ht13+yhog_iecon

*-------------------------------------------------------------------------------
* Vector salud. Código Iecon

gen salud = fonasa + cuota_fonasa_msp+ cuotmilit+cuotabps+cuota_fon_msp_men1 // A fonasa, se le suman cuotas mutuales militares y bps ($)

bys bc_correlat: egen saludh= sum(salud)

bys bc_correlat: egen CUOT_OTROHOG_h=sum(CUOT_OTROHOG)
bys bc_correlat: egen totfonasa_hogar2_h=sum(totfonasa_hogar2)
replace saludh=saludh + totfonasa_hogar2_h+cuotmilit_hogar // Dejo afuera CUOT_OTROHOG_h 26/11/2018
