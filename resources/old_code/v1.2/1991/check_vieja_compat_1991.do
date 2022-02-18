

/*
Desde la p1991 que se genera en 3_compatibilización
se pega la vieja con otro nombre de variables para ver la consistencia de variables
*/

u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/antes/p91.dta", clear
foreach var of varlist _all {
rename `var' `var'_v
} 
rename correlat_v correlat
rename nper_v nper
destring nper,replace
save "/home/amarroig/iecon/datos/ech/personas/intermedias/p91_v",replace

*** CORRER project
u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/p91",clear //es la base que se armo luego revisión

rename bc_correlat correlat
rename bc_nper nper

merge 1:1 correlat nper using "$rutainterm/p91_v", force gen(control)

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
tab  pe6a_v bc_pe6a if control==3,m
tab  pe6b_v bc_pe6b,m
tab  pe6b_v bc_pe6b if control==3,m
tab  pe12_v bc_pe12,m
tab  pe12_v bc_pe12 if control==3,m
tab  pe13_v bc_pe13,m
tab  pe13_v bc_pe13 if control==3,m

tab  nivel_v bc_nivel,m
tab  nivel_v bc_nivel if control==3,m

tab  edu_v bc_edu,m
tab  edu_v bc_edu if control==3,m //1669

/*HAY DIFERENCIAS EN EDUCACIÓN 
br pe3 pe11 pe12 nivel nivel2 pe142 anios edu edu_v if (edu_v>edu)&edu_v!=.

	*- si tienen 6 5 4 o 3 años de diferencias en edu_v puede haber error porque 
	son de nivel2==2 con 17 16 15 y 14 años de educación y máximo debería ser 12
	*- si tienen 2 años de diferencias hay distintos casos. Algunos pocos superan
	los 12 años en el nivel2==2 lo que no debería ocurrir y se trunca. 
	Luego, algunos tienen muchos años en pe142 (5 pej) entonces creo que edu es 
	correcta.
*/

tab  pobp_v bc_pobp,m
tab  pobp_v bc_pobp if control==3,m
tab  pf41a_v bc_pf41,m
tab  pf41a_v bc_pf41 if control==3,m

tab  cat2_v bc_cat2,m
tab  cat2_v cat2 if control==3,m

/*HAY DIFERENCIAS EN CAT2 
	*- los missing de la variable _v están con cero
	*- hay algunos que valen cero y que tienen pf41a con valor
*/

tab  pf081_v bc_pf081,m
tab  pf081_v bc_pf081 if control==3,m

tab  pf082a_v bc_pf082,m
tab  pf082a_v bc_pf082 if control==3,m

/*HAY DIFERENCIAS EN PF082A 
	*- los missing de la variable _v están con cero
	*- algunos que valen cero y que tienen valor en pf082 pero pueden tener 
	missing en pf081 (parece que fueron recodificados a cero los valores de 
	pf082 con missing en pf081)
*/

tab pf40_v bc_pf40,m
tab pf40_v bc_pf40 if control==3,m
tab rama_v bc_rama,m
tab rama_v bc_rama if control==3,m

compare pf39_v bc_pf39
compare pf39_v bc_pf39 if control==3

tab tipo_ocup_v bc_tipo_ocup,m

/* FALTAN chequear
bc_pf07
bc_pf051
bc_pf052
bc_pf053
bc_pf06
bc_horas
bc_horas_1
bc_pf04
bc_pf21
bc_pf22
bc_pf26
bc_pf34
bc_reg_disse
bc_register
bc_register2
bc_subocupado






