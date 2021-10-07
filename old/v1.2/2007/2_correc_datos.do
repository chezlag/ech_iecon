*-------------------------------------------------------------------------------
* Arreglos de nombres de variables por .sav
cap rename e60_2__a e60_2_1_1
cap rename e60_2__b e60_2_1_2
cap rename e60_2__c e60_2_1_3
cap rename e60_2__d e60_2_1_4
cap rename e60_2__e e60_2_2_1
cap rename e60_2__f e60_2_2_2
cap rename e60_2__g e60_2_2_3
cap rename e60_2__h e60_2_2_4
cap rename e60_2__i e60_2_3_1
cap rename e60_2__j e60_2_3_2
cap rename e60_2__k e60_2_3_3
cap rename e60_2__l e60_2_3_4
cap rename e60_2__m e60_2_4_1
cap rename e60_2__n e60_2_4_2
cap rename e60_2__o e60_2_4_3
cap rename e60_2__p e60_2_4_4
cap rename e60_2__q e60_2_5_1
cap rename e60_2__r e60_2_5_2
cap rename e60_2__s e60_2_5_3
cap rename e60_2__t e60_2_5_4
cap rename e60_2__u e60_2_6_1
cap rename e60_2__v e60_2_6_2
cap rename e60_2__w e60_2_6_3
cap rename e60_2__x e60_2_6_4

*-------------------------------------------------------------------------------
* Renombro variables del ine
*cap rename ytdop ine_ytdop
*cap rename ytdos ine_ytdos
*cap rename ytinde ine_ytinde
*cap rename ytransf ine_ytransf
*cap rename pt1 ine_pt1
*cap rename pt2 ine_pt2
*cap rename pt4 ine_pt4
*cap rename yalimpan ine_yalimpan
*cap rename ht11 ine_ht11
*cap rename ht13 ine_ht13
*cap rename yhog ine_yhog
cap gen ine_ht13

recode mto_cuot (.=0)  
recode mto_emer (.=0)
recode mto_hogc (.=0)

*-------------------------------------------------------------------------------
* Recodificación de datos
*Este recode está hecho porque son demasiadas
recode g133_2 22=0 //cantidad de cuotas mutuales recibidas no declaradas en sueldo

*-------------------------------------------------------------------------------
*
destring region_4, replace
destring dpto, replace
destring mes, replace
destring anio, replace
destring numero, replace

rename anio bc_anio
rename mes bc_mes
rename dpto bc_dpto
