

/*
Desde la p1990 que se genera en 3_compatibilización
se pega la vieja con otro nombre de variables para ver la consistencia de variables
*/
cd "//164.73.246.107/amarroig/alejandra/iecon/datos/encuestas/ech" //iesta

u "./personas/bases compatibilizadas/antes/p90.dta", clear
foreach var of varlist _all {
rename `var' `var'_v
} 
rename correlat_v correlat
rename pe1_v nper // no está nper en la p90
destring nper,replace
save "./personas/intermedias/p90_v",replace

*** CORRER project
*u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/p90",clear //es la base que se armo luego revisión

rename bc_correlat correlat
rename bc_nper nper

merge 1:1 correlat nper using "$rutainterm/p90_v", force gen(control)

*-------------------------------------------------------------------------------
tab filtloc_v bc_filtloc,m
tab filtloc_v bc_filtloc if control==3,m

tab  mes_v bc_mes,m
tab  mes_v bc_mes if control==3,m

tab  pe2_v bc_pe2,m
tab  pe2_v bc_pe2 if control==3,m
tab  pe5_v bc_pe5,m
tab  pe5_v bc_pe5 if control==3,m
tab  pe6a_v bc_pe6a,m
*en la base vieja esta pe6a, vale todo cero 
tab  pe6a_v bc_pe6a if control==3,m
*en la base vieja está pe6b, tiene valores del 0 al 4
tab  pe6b_v bc_pe6b,m
tab  pe6b_v bc_pe6b if control==3,m

/*pe12 no está en la base vieja
tab  pe12_v bc_pe12,m
tab  pe12_v bc_pe12 if control==3,m
*/
*pe13 está hecha con 3 valores
tab  pe13_v bc_pe13,m
tab  pe13_v bc_pe13 if control==3,m

tab  nivel2_v bc_nivel,m
tab  nivel2_v bc_nivel if control==3,m //hay 367 con nivel missing ahora que antes eran nivel==5

tab  edu_v bc_edu if control==3,m 

tab  pobp_v bc_pobp,m
tab  pobp_v bc_pobp if control==3,m
tab  pf41a_v bc_pf41,m
tab  pf41a_v bc_pf41 if control==3,m

tab  cat2_v bc_cat2,m
tab  cat2_v cat2 if control==3,m

/*HAY DIFERENCIAS EN CAT2 
	*- solamente para los casos de control!=3 (solo using o solo master data)
*/

tab  pf081_v bc_pf081,m
tab  pf081_v bc_pf081 if control==3,m //acá hay diferencias en pf081 para casos con missing y en la vieja con 1 o 2

tab  pf082a_v bc_pf082,m
tab  pf082a_v bc_pf082 if control==3,m

/*HAY DIFERENCIAS EN PF082A 
	*- solamente unos missing que valen cero y otros que valen 1
*/

tab pf40_v bc_pf40,m
tab pf40_v bc_pf40 if control==3,m
tab rama_v bc_rama,m
tab rama_v bc_rama if control==3,m

compare pf39_v bc_pf39 
compare pf39_v bc_pf39 if control==3 //acá hay algunos casos con diferencias

tab tipo_ocup_v bc_tipo_ocup,m
tab tipo_ocup_v bc_tipo_ocup if control==3,m //hay algunas diferencias






