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
generate cuotmilit = cuotmilit1*mto_cuot
recode cuotmilit .=0

generate cuotabps=mto_cuot if (e45_1==3 & (pobpcoac==9 | pobpcoac==10)) 
recode cuotabps  .=0

**** YTDOP - YTDOS - YTINDE - DISSE - SANIDAD MILITAR O POLICIAL
capture drop ytdop ytdos ytinde 

generate ytdop = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desa)+(g130_3*mto_alm)+g130_4+g131_2/*
*/ +g132_3+(g133_2*mto_cuot)+g134_2+g135_2+(g136_2*mto_vac)+(g136_3*mto_ovej)+(g136_4*mto_cab)+g137_2+(g137_3/12)

gen ytdos = g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_7+g138_8+(g139_2*mto_desa)+(g139_3*mto_alm)+g139_4+g140_2/*
*/ +g141_3+(g142_2*mto_cuot)+g143_2+g144_2+(g145_2*mto_vac)+(g145_3*mto_ovej)+(g145_4*mto_cab)+g146_2 +(g146_3/12)

gen ytinde = g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12) + (g151/12) + (g152/12)  

gen menor18=0
replace menor18=1 if e28<18

* por el diseño del formulario quienes contestan e45_1==3 es porque tienen derechos de salud en mutualista o seguro privado)
generate fonasa = mto_cuot if e45_1==3 & ((pobpcoac==2 & (f85==1 |f99==1)) | pobpcoac==5) 
recode fonasa  .=0

gen cuota_fonasa_msp=0
replace cuota_fonasa_msp=mto_cuot if (f85==1 | f99==1) & pobpcoac==2 & ((e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2) )

gen fonasa_menor= mto_cuot if menor18==1 & e45_1==3 & (pobpcoac!=2 | (pobpcoac==2 & f85!=1 & f99!=1))
recode fonasa_menor  .=0

gen msp_adult_fon=0
replace msp_adult_fon=1 if (f85==1 | f99==1) & pobpcoac==2 

egen msp_adult_fonh= sum (msp_adult_fon), by (correlat)

gen msp_menor_fon=0
replace msp_menor_fon=1 if (msp_adult_fonh>0 & (e43_1==1 & e43_2==2 & e43_3==2 & e43_4==2 & e43_5==2 & e43_6==2 & e43_7==2 & e43_8==2 & e43_9==2 & e43_10==2) & (pobpcoac!=2 | pobpcoac==2 & f85!=1 & f99!=1) & menor18==1)  
 

gen cuota_fon_msp_men=0
replace cuota_fon_msp_men=msp_menor_fon*mto_cuot if msp_menor_fon>0

**** YTRANSF
gen  YTRANSF_1 = g153_1 + g153_2 + g153_3 + g153_4 + g153_5 + g153_6 + g153_7 + g153_8 + g153_9 + g153_10 + g153_11/*
*/+ g153_12 + g153_13 + g153_14 + g153_15 + g153_16 + g153_17 + g153_18 + g153_19 + g153_20 + g153_21 + g153_22 + g153_23/*
*/+ g153_24 + g153_25 + g153_26

generate YTRANSF_2= g155_4 if (g155_1==1 & g155_3==2) // cobra asignaciones y no las declaró en el sueldo
recode YTRANSF_2 .=0

recode mto_hogc .=0
generate YTRANSF_3 = mto_hogc if g154_1==1 & g154_2==2
recode YTRANSF_3 .=0


generate YTRANSF_6 = g156_2+g156_3 
recode YTRANSF_6 .=0


*** YALIMENT *** 
gen DESAY = ( e59_2__a + e59_2__c + e59_2__e + e59_2__g+ e59_2__i+ e59_2__k + e59_2__m+ e59_2__o + e59_2__q+ e59_2__s+ e59_2__u+ e59_2__w)*4.3*mto_desa 

gen ALMUER = ( e59_2__b+ e59_2__d+ e59_2__f+ e59_2__h+ e59_2__j+ e59_2__l + e59_2__n+ e59_2__p+ e59_2__r+ e59_2__t+ e59_2__v + e59_2__x)*4.3*mto_alm 


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

recode DESAY  (.=0)  
recode ALMUER  (.=0)  
recode COMESCOL (.=0)  
recode COMEHOG  (.=0)  
recode CANASTA (.=0)  

generate YALIMENT=DESAY + ALMUER + COMESCOL + COMEHOG +CANASTA if (e28>13)
 
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

**** PT2 PRIV
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

capture drop PT1 PT2 PT4
generate PT2= PT2PRIV + PT2PUB + PT2NODEP 

*** PT4
capture drop PT4
generate PT4 = ytdop + ytdos + ytinde+ fonasa + cuota_fonasa_msp 
replace PT4 = ytdop + ytdos + ytinde + fonasa + cuota_fonasa_msp + cuotmilit if ((f75==2 & g133_2==0 & e46_2==nper ) | (f95==2 & g142_2==0 & e46_2==nper))


**** PT1
capture drop PT1 
gen PT1= ytdop + ytdos + ytinde + fonasa + cuota_fonasa_msp + YTRANSF  + g157_2 
replace PT1= ytdop + ytdos + ytinde + fonasa + cuota_fonasa_msp + YTRANSF + g157_2 + cuotmilit if ((f75==2 & g133_2==0 & e46_2==nper ) | (f95==2 & g142_2==0 & e46_2==nper))

recode PT2 .=0
recode PT1 .=0
recode PT4 .=0

save "S:\empleo\datos\encuestas\ech\personas\p08.dta", replace


collapse (sum)PT1 if e32<14, by (correlat)

save "pt08.dta", replace

************** HOGARES

use S:\empleo\datos\encuestas\ech\hogares\h08, clear
sort correlat
merge correlat using "pt08.dta"
save "h08c.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta", clear

generate filtro5=0
replace filtro5=1 if (e45_1 == 2)
drop if filtro5==0
collapse (sum) mto_cuot, by (correlat)
save "aggr_cuothog08.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta", clear

gen mto_emerg=.
destring mes, replace
replace mto_emerg=309 if mes==1
replace mto_emerg=309 if mes==2
replace mto_emerg=309 if mes==3
replace mto_emerg=312.5 if mes==4
replace mto_emerg=312.5 if mes==5
replace mto_emerg=315.5 if mes==6
replace mto_emerg=320 if mes==7
replace mto_emerg=305.5 if mes==8
replace mto_emerg=325.5 if mes==9
replace mto_emerg=325.5 if mes==10
replace mto_emerg=329.5 if mes==11
replace mto_emerg=334.25 if mes==12

generate filtro6=0
replace filtro6=1 if (e48_1 == 2)
drop if filtro6==0
collapse (sum) mto_emer, by (correlat)
save "aggr_EMERHOG08.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta", clear
generate filtro7=0
replace filtro7=1 if (e46_1==2)
drop if filtro7==0
collapse (sum) mto_cuot, by (correlat)
rename mto_cuot cuotmil
save "aggr_MILITHOG08.dta", replace

use "h08c.dta", replace
drop _merge
sort correlat
merge correlat using "aggr_cuothog08.dta"
save "h08c.dta", replace

use "h08c.dta", replace
sort correlat
drop _merge
merge correlat using "aggr_EMERHOG08.dta"
save "h08c.dta", replace

use "h08c.dta", replace
sort correlat
drop _merge
merge correlat using "aggr_MILITHOG08.dta"
drop _merge
save "h08c.dta", replace

recode mto_cuot  (.=0)  
recode  mto_emer    (.=0)
recode   cuotmil (.=0) 

save "h08c.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta", clear

generate YALIMENT_men=DESAY + ALMUER + COMESCOL + COMEHOG +CANASTA if (e28<14)

recode YALIMENT_men (.=0)

collapse (sum) YALIMENT_men , by (correlat)

sort correlat
save "aggr_yaliment_men08.dta", replace

use "h08c.dta", clear
capture drop _merge
sort correlat
merge correlat using "aggr_yaliment_men08.dta"
save "h08c.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta", clear
collapse (sum) fonasa_menor cuota_fon_msp_men , by (correlat)
sort correlat
save "aggr_cuotashogar08.dta", replace
use "h08c.dta", clear
capture drop _merge
sort correlat
merge correlat using "aggr_cuotashogar08.dta"

gen YHOG= h158_2+h159_2+(h162_2/12)+(h162_3/12)+(h165_1/12)+(h165_2/12)+(h166/12)+(h167/12)+(h168/12)/*
*/+(h170_1/12)+(h170_2/12)+(h172_1/12)+(h172_2/12)+(h173_2/12)+(h174_2/12)+mto_cuot/*
*/+cuotmil+mto_emer+YALIMENT_men + fonasa_menor + cuota_fon_msp_men

capture drop ht11
generate ht11 = PT1 + ht13 + YHOG

save "basehog08.dta", replace

keep ht11 ht13 region correlat

sort correlat
save "keep.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta",  clear
sort correlat
merge correlat using "keep.dta"
tab _merge
save "S:\empleo\datos\encuestas\ech\personas\p08.dta",  replace

use "basehog08.dta", clear
keep correlat ht19 YHOG
sort correlat
save "keep_hog.dta", replace

use "S:\empleo\datos\encuestas\ech\personas\p08.dta",  clear
sort correlat
drop _merge
merge correlat using "keep_hog.dta"
tab _merge
save "S:\empleo\datos\encuestas\ech\personas\p08.dta",  replace

/*
********************************************************VER SI CONTEXTO CRITICO LO ESTA TOMANDO DE LA BASE****************************************

gen filter=1 if e45_1==1
egen cuotempl=sum(e45_2) if  , by(bc_correlat)


Compute Contcrit=120.
Execute.

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.


USE ALL.
COMPUTE filter_$=(e45_1 = 1).
VARIABLE LABEL filter_$ 'e45_1 = 1 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_empleador.sav'
  /BREAK=correlativ
  /e45_2 = SUM(e45_2)
  /cuotempl=N.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_empleador.sav'.

COMPUTE nper = e45_2 .
EXECUTE .

SORT CASES BY
  correlativ (A) nper (A) .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_empleador.sav'
 /COMPRESSED.


GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'.

SORT CASES BY
  correlativ (A) nper (A) .

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_empleador.sav'
 /RENAME (e45_2 = d0)
 /BY correlativ nper
 /DROP= d0.
EXECUTE.

RECODE
  cuotempl   (MISSING=0)  .
EXECUTE .

COMPUTE cuotempl = cuotempl*mto_cuota .
EXECUTE .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.


USE ALL.
COMPUTE filter_$=(e48_1 = 1).
VARIABLE LABEL filter_$ 'e48_1 = 1 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_emerempl.sav'
  /BREAK=correlativ
  /e48_2 = SUM(e48_2)
  /emerempl=N.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_emerempl.sav'.

COMPUTE nper = e48_2 .
EXECUTE .

SORT CASES BY
  correlativ (A) nper (A) .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_emerempl.sav'
 /COMPRESSED.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'.

SORT CASES BY
  correlativ (A) nper (A) .

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_emerempl.sav'
 /RENAME (e48_2 = d0)
 /BY correlativ nper
 /DROP= d0.
EXECUTE.

RECODE
  emerempl    (MISSING=0)  .
EXECUTE .

**************************************************AQUI SE DEBE CAMBIAR EL MES Y CAMBIAR EL MONTO DE LA EMERGENCIA*********************************

If (mes='01') mto_emerg= 298.
execute .

COMPUTE emerempl = emerempl*mto_emerg .
EXECUTE .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.


if (e45_1=3 & (pobpcoac=9 or pobpcoac=10)) cuotabps=mto_cuota.

RECODE
   cuotabps  (MISSING=0)  .

if (e45_1=3 & (pobpcoac=9 or pobpcoac=10)) emerbps=mto_emerg.

RECODE
  emerbps  (MISSING=0)  .
EXECUTE .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.


**** YTDOP - YTDOS - YTINDE - DISSE - SANIDAD MILITAR O POLICIAL

COMPUTE ytdop_1 = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desay)+(g130_3*mto_almue)+g130_4+g131_2
 +g132_3+(g133_2*mto_cuota)+g134_2+g135_2+(g136_2*mto_vacas)+(g136_3*mto_oveja)+(g136_4*mto_caball)+g137_2+(g137_3/12).

IF (f75=2) ytdop_2 = cuotmilit.

IF (((f75 < 3 & ytdop_2=0) & f85=1) & e45_1 = 3) ytdop_3 = mto_cuota.

RECODE
   ytdop_2  ytdop_3 (MISSING=0)  .
EXECUTE .

COMPUTE ytdop=ytdop_1 + ytdop_2 + ytdop_3.
execute.

COMPUTE ytdos_1 = g138_1+g138_2+g138_3+g138_4+g138_5+g138_6+g138_7+g138_8+(g139_2*mto_desay)+(g139_3*mto_almue)+g139_4+g140_2
 +g141_3+(g142_2*mto_cuota)+g143_2+g144_2+(g145_2*mto_vacas)+(g145_3*mto_oveja)+(g145_4*mto_caball)+g146_2+(g146_3/12) .

IF (f95=2 & ytdop_2=0) ytdos_2 = cuotmilit.

IF ((f95~=2 & f95~=0) & e45_1 = 3 & ytdop_3=0) ytdos_3 = mto_cuota.

RECODE
   ytdos_2  ytdos_3 (MISSING=0)  .
EXECUTE .

COMPUTE ytdos=ytdos_1 + ytdos_2 + ytdos_3.
execute.

compute YTINDE_1 = g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12) + (g151/12) + (g152/12) . 

IF ((F75>2 & F75<7) & (F85=1) & (e45_1 = 3) & ytdop_3=0 & ytdos_3=0) ytinde_2 = mto_cuota .
execute. 

RECODE
   ytinde_1  ytinde_2 (MISSING=0)  .
EXECUTE .

compute ytinde=ytinde_1 + ytinde_2.
execute.


**** YTRANSF

compute YTRANSF_1 = g153_1 + g153_2 + g153_3 + g153_4 + g153_5 + g153_6 + g153_7 + g153_8 + g153_9 + g153_10 + g153_11
+ g153_12 + g153_13 + g153_14 + g153_15 + g153_16 + g153_17 + g153_18 + g153_19 + g153_20 + g153_21 + g153_22 + g153_23
+ g153_24 + g153_25 + g153_26 .
EXECUTE .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.

If (g155_1=1 & g155_3=2) YTRANSF_2  = g155_4.  
Execute.

RECODE
   YTRANSF_2  (MISSING=0)  .

compute YTRANSF_3 = mto_hogcon .

compute YTRANSF_6 = g156_2+g156_3 .
execute.

*** YALIMENT

COMPUTE DESAY = (e59_2_1_1+e59_2_1_3+e59_2_2_1+e59_2_2_3+e59_2_3_1+e59_2_3_3+e59_2_4_1
+e59_2_4_3+e59_2_5_1+e59_2_5_3+e59_2_6_1+e59_2_6_3)*4.3*mto_desay .

COMPUTE ALMUER = (e59_2_1_2 + e59_2_1_4 + e59_2_2_2 + e59_2_2_4 + e59_2_3_2 + e59_2_3_4 + e59_2_4_2
+ e59_2_4_4 + e59_2_5_2 + e59_2_5_4 + e59_2_6_2 + e59_2_6_4) * 4.3 * MTO_ALMUE .

IF (e59_2_7=7) COMESCOL = MTO_ALMUE*5*4.3 .
IF (e59_2_7=8) COMESCOL = MTO_DESAY*5*4.3 .
IF (e59_2_7=9) COMESCOL = (MTO_ALMUE+MTO_DESAY)*5*4.3 .
IF (e59_2_7=10) COMESCOL = (MTO_ALMUE+MTO_DESAY)*5*4.3 .
IF (e59_2_7=11) COMESCOL = (MTO_ALMUE+MTO_DESAY+MTO_DESAY)*5*4.3 .

IF (E60_3=0) COMEHOG = E60_2*MTO_ALMUE*4.3 .
IF (E60_3>0) COMEHOG = E60_3*MTO_ALMUE .

COMPUTE CANASTA = (e61_1_2*INDACOMUN)+(e61_2_2*INDABAJO)+(e61_3_2*INDAPLOMO)+(e61_4_2*INDAPENSI)
+(e61_5_2*INDADIABET)+(e61_6_2*INDARENAL)+(e61_7_2*INDARENDIA)+(e61_8_2*INDACELIAC)+(e61_9_2*INDATUBERC)
+(e61_10_2*INDAONCOLO)+(e61_11_2*INDASIDA)+(e61_12_2*CONTCRIT).
execute.

RECODE
  DESAY ALMUER COMESCOL COMEHOG CANASTA (MISSING=0)  .

if (e28>13) YALIMENT=DESAY + ALMUER + COMESCOL + COMEHOG + CANASTA .
EXECUTE . 

RECODE
  YALIMENT (MISSING=0)  .

compute YTRANSF_4 = yaliment .
if (f75~=2 & ytdos_2 = 0 & ytdop_2 = 0) YTRANSF_5= cuotmilit .
EXECUTE . 

RECODE
  YTRANSF_2 YTRANSF_3 YTRANSF_4 YTRANSF_1 YTRANSF_5 YTRANSF_6 (MISSING=0)  .

compute YTRANSF = YTRANSF_1 + YTRANSF_2 + YTRANSF_3 + YTRANSF_4 + YTRANSF_5 + YTRANSF_6 + cuotabps.
EXECUTE .


**** PT2

IF (F75=1) PT2PRIV_1 = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desay)+(g130_3*mto_almue)+g130_4+g131_2
 +g132_3+(g133_2*mto_cuota)+g134_2+g135_2+(g136_2*mto_vacas)+(g136_3*mto_oveja)+(g136_4*mto_caball)+g137_2+(g137_3/12)  .
IF (F75=1 & F85=1) PT2PRIV_2= Mto_cuota .


RECODE
  PT2PRIV_1 PT2PRIV_2 (MISSING=0)  .

COMPUTE PT2PRIV = PT2PRIV_1 + PT2PRIV_2.

**** PT2 PUB

IF (F75=2 OR F75=8) PT2PUB_1 = g129_1+g129_2+g129_3+g129_4+g129_5+g129_6+g129_7+g129_8+(g130_2*mto_desay)+(g130_3*mto_almue)+g130_4+g131_2
 +g132_3+(g133_2*mto_cuota)+g134_2+g135_2+(g136_2*mto_vacas)+(g136_3*mto_oveja)+(g136_4*mto_caball)+g137_2  . 

IF (f75=2) PT2PUB_2= cuotmilit.
IF (F75=2 & pt2pub_2=0 & e45_1 = 3) pt2pub_3=mto_cuota.

RECODE
  PT2PUB_1 PT2PUB_2 PT2PUB_3 (MISSING=0)  .

COMPUTE PT2PUB = PT2PUB_1 + PT2PUB_2 + PT2PUB_3.
 

IF (F75>2 & F75<7) PT2NODEP_1= g147 + (g148/12) + g149_2 + g149_3 + g149_4 + g149_5 + g149_6 + g149_7 + (g150/12) + (g151/12) + (g152/12) . 

IF ((F75>2 & F75<7) & (F85=1) & (e45_1 = 3)) pt2nodep_2 = mto_cuota.

RECODE
  PT2NODEP_1  PT2NODEP_2   (MISSING=0)  .

COMPUTE PT2NODEP=PT2NODEP_1 + PT2NODEP_2 .

COMPUTE PT2= PT2PRIV + PT2PUB + PT2NODEP .

Execute. 

*** PT4

COMPUTE PT4 = YTDOP + YTDOS + YTINDE .

***OTROS INGRESOS CORRIENTES

COMPUTE OTROSY= G157_2 .
execute.

**** PT1

COMPUTE PT1= YTDOP + YTDOS + YTINDE + YTRANSF + OTROSY.
execute.

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.

USE ALL.
COMPUTE filter_$=(E32~=14).
VARIABLE LABEL filter_$ 'E32~=14 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_pt1_hogar.sav'
  /BREAK=correlativ
  /pt1 = SUM(pt1).

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.

************** HOGARES

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'.

SORT CASES BY
  correlativ (A) .

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_pt1_hogar.sav'
 /BY correlativ.
EXECUTE.

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'
 /COMPRESSED.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'.

USE ALL.
COMPUTE filter_$=(e45_1 = 2).
VARIABLE LABEL filter_$ 'e45_1 = 2 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_CUOTHOG.sav'
  /BREAK=correlativ
  /CuotHOG = SUM(mto_cuota).

USE ALL.
COMPUTE filter_$=(e48_1 = 2).
VARIABLE LABEL filter_$ 'e48_1 = 2 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .


AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_EMERHOG.sav'
  /BREAK=correlativ
  /EMERHOG = SUM(mto_EMERG).

USE ALL.
COMPUTE filter_$=(e46_1=2).
VARIABLE LABEL filter_$ ' e46_1=2 (FILTER)'.
VALUE LABELS filter_$  0 'No seleccionado' 1 'Seleccionado'.
FORMAT filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_MILITHOG.sav'
  /BREAK=correlativ
  /MILITHOG = SUM(mto_cuota).

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'.

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_CUOTHOG.sav'
 /BY correlativ.
EXECUTE.

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_EMERHOG.sav'
 /BY correlativ.
EXECUTE.

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_MILITHOG.sav'
 /BY correlativ.
EXECUTE.

RECODE
 CuotHOG EMERHOG MILITHOG   (MISSING=0)  .
EXECUTE .

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'
 /COMPRESSED.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'.

if (e28<=13) YALIMENT_men=DESAY + ALMUER + COMESCOL + COMEHOG + CANASTA .
EXECUTE .

RECODE
 yaliment_men   (MISSING=0)  .
EXECUTE .

AGGREGATE
  /OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_yaliment_men.sav'
  /BREAK=correlativ
  /YALIMENT_men = SUM(YALIMENT_men).

SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\p01_2008.sav'
 /COMPRESSED.

GET
  FILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'.

MATCH FILES /FILE=*
 /TABLE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\aggr_yaliment_men.sav'
 /BY correlativ.
EXECUTE.

COMPUTE YHOG= H158_2+H159_2+(H162_2/12)+(H162_3/12)+(H165_1/12)+(H165_2/12)+(H166/12)+(H167/12)+(H168/12)
+(H170_1/12)+(H170_2/12)+(H172_1/12)+(H172_2/12)+(H173_2/12)+(H174_2/12)+CUOTHOG
+EMERHOG+MILITHOG+yaliment_men.
EXECUTE.

COMPUTE HT11 = PT1 + HT13 + YHOG.
EXECUTE.


SAVE OUTFILE='F:\SocDemo\EHA\INDSO\2008\Bases Enero\h01_2008.sav'
 /COMPRESSED.
