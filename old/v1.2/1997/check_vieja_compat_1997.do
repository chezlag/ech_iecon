
u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/antes/p97.dta", clear
foreach var of varlist _all {
rename `var' `var'_v
} 
rename correlat_v correlat
destring correlat,replace
rename nper_v nper
destring nper,replace
save "/home/amarroig/iecon/datos/ech/personas/intermedias/p97_v",replace

*** CORRER project
*u "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas/p97",clear //es la base que se armo luego revisión

rename bc_correlat correlat
rename bc_nper nper

merge 1:1 correlat nper using "$rutainterm/p97_v", force gen(control)

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

tab  nivel2_v bc_nivel,m
tab  nivel2_v bc_nivel if control==3,m

tab  edu_v bc_edu,m
tab  edu_v bc_edu if control==3,m 

tab  pobp_v bc_pobp,m
tab  pobp_v bc_pobp if control==3,m

tab  pf41a_v bc_pf41,m
tab  pf41a_v bc_pf41 if control==3,m

tab  cat2_v bc_cat2,m
tab  cat2_v bc_cat2 if control==3,m

tab  pf081_v bc_pf081,m
tab  pf081_v bc_pf081 if control==3,m

tab  pf082a_v bc_pf082,m
tab  pf082a_v bc_pf082 if control==3,m

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






