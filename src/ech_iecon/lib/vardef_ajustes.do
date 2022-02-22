/* 
	vardef_ajustes.do
	Ajustes generales de las bases 2001–2019
*/

// arreglos de nombres de variables por .sav

cap rename e45_1__a e45_1_1_1
cap rename e45_1__b e45_1_2_1
cap rename e45_2__a e45_2_1_1
cap rename e45_2__b e45_2_2_1
cap rename e45_3__a e45_3_1_1
cap rename e45_3__b e45_3_2_1
cap rename e45_4__a e45_4_3_1
cap rename e45_5__a e45_5_1_1

cap rename g148_1_a g148_1_10
cap rename g148_1_b g148_1_11
cap rename g148_1_c g148_1_12
cap rename g148_2_a g148_2_10
cap rename g148_2_b g148_2_11
cap rename g148_2_c g148_2_12

// Renombro variables del ine 
* (para variables de ingreso se deshace el rename en paso 8.)

* variables de identificación
rename numero   bc_correlat
rename nper     bc_nper
rename mes      bc_mes
rename anio     bc_anio
rename dpto     bc_dpto
rename ccz      bc_ccz
* ponderadores
cap rename pesoano bc_pesoan
* variables de ingreso
cap rename ytdop    ine_ytdop
cap rename ytdos    ine_ytdos
cap rename ytinde   ine_ytinde
cap rename ytransf  ine_ytransf
cap rename pt1      ine_pt1
cap rename pt2      ine_pt2
cap rename pt4      ine_pt4
cap rename ht13     ine_ht13
cap rename yhog     ine_yhog
cap rename ysvl     ine_ysvl


// Recodificación de datos -----------------------------------------------------

recode mto_cuot (. = 0)  
recode mto_emer (. = 0)
recode mto_hogc (. = 0)
recode bc_ccz   (0 = -9)

// Cambios de variables

destring region_4, replace
destring bc_dpto,  replace
destring bc_mes,   replace
destring bc_anio,  replace
destring bc_ccz,   replace
destring f72_2,    replace
destring f91_2,    replace

// extiendo ht11 para todos los integrantes del hogar
*	- en algunos años ya está, pero en otros no

egen ht11_max = max(ht11), by(bc_correlat)
replace ht11 = ht11_max if !`pe4_servdom'
drop ht11_max
