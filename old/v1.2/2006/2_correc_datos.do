*2_ ----------------------------------------------------------------------------
* Base original
/*
u "$rutaoriginales/P_2006_TERCEROS_1.dta", clear
cap drop _merge
merge 1:1 numero nper using "$rutaoriginales/P_2006_TERCEROS_2.dta"
drop _merge
merge 1:1 numero nper using "$rutaoriginales/P_2006_TERCEROS_3.dta"
drop _merge

merge m:1 numero using "$rutaoriginales/H_2006_TERCEROS.dta"
drop _merge
*/

u "$rutaoriginales/fusionado_2006_terceros.dta"
cap rename *, lower

*-------------------------------------------------------------------------------
* Arreglos de nombres de variables 
cap rename e58_2__a e58_2_1_1
cap rename e58_2__b e58_2_1_2
cap rename e58_2__c e58_2_1_3
cap rename e58_2__d e58_2_1_4
cap rename e58_2__e e58_2_2_1
cap rename e58_2__f e58_2_2_2
cap rename e58_2__g e58_2_2_3
cap rename e58_2__h e58_2_2_4
cap rename e58_2__i e58_2_3_1
cap rename e58_2__j e58_2_3_2
cap rename e58_2__k e58_2_3_3
cap rename e58_2__l e58_2_3_4
cap rename e58_2__m e58_2_4_1
cap rename e58_2__n e58_2_4_2
cap rename e58_2__o e58_2_4_3
cap rename e58_2__p e58_2_4_4
cap rename e58_2__q e58_2_5_1
cap rename e58_2__r e58_2_5_2
cap rename e58_2__s e58_2_5_3
cap rename e58_2__t e58_2_5_4
cap rename e58_2__u e58_2_6_1
cap rename e58_2__v e58_2_6_2
cap rename e58_2__w e58_2_6_3
cap rename e58_2__x e58_2_6_4

*-------------------------------------------------------------------------------
* Recodificación de datos
*Esta persona parece tener mal este ingreso 
*ver el valor locativo hogar y coincidencia de monto con lo declarado en g121_1
	replace g124_3=-3 if numero==23043&nper==2

*Este recode está hecho porque son demasiadas
recode g125_2 (22 50=-3) //cantidad de cuotas mutuales recibidas no declaradas en sueldo
recode g125_2 (-3=0), g(g125_2_ing)

recode mto_cuot mto_emer mto_hogc (.=0)  

*-------------------------------------------------------------------------------
* Cambios de variables
destring region_4, replace
destring dpto, replace
destring mes, replace
destring anio, replace

