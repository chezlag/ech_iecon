

/*
Desde la p6 que se genera al final
se pega la vieja con otro nombre de variables para ver la consistencia de variables
*/

u "/home/amarroig/iecon/datos/ech/personas/intermedias/p6.dta", clear
foreach var of varlist _all {
rename `var' bc_`var'_v
} 
rename bc_correlat_v bc_correlat
rename bc_nper_v bc_nper
destring bc_nper,replace
save "/home/amarroig/iecon/datos/ech/personas/intermedias/p6_v",replace

*** CORRER 
u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/p6.dta", clear
merge 1:1 bc_correlat bc_nper using "$rutainterm/p6_v"

/*
compare bc_filtloc_v bc_filtloc
compare bc_mes_v bc_mes
compare bc_pe2_v bc_pe2
compare bc_pe5_v bc_pe5 
compare bc_pe6a_v bc_pe6a 
compare bc_pe6b_v bc_pe6b
compare bc_pe12_v bc_pe12
compare bc_pe13_v bc_pe13
compare bc_nivel_v bc_nivel
compare bc_edu_v bc_edu
compare bc_pobp_v bc_pobp
compare bc_pf41_v bc_pf41

*/

compare cat2_v cat2
compare cat2_v cat2 if _merge==3

/*HAY DIFERENCIAS EN CAT2 
	*- los missing de la variable _v están con cero
	*- hay algunos que valen cero y que tienen pf41a con valor
*/

compare pf082a_v pf082a
compare pf082a_v pf082a if _merge==3

/*HAY DIFERENCIAS EN PF082A 
	*- los missing de la variable _v están con cero
	*- algunos que valen cero y que tienen valor en pf082 pero pueden tener 
	missing en pf081 (parece que fueron recodificados a cero los valores de 
	pf082 con missing en pf081)
*/







