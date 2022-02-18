*4_ ----------------------------------------------------------------------------

g bc_disse_p=monto1 if bc_pe6a==3 & f10_2==1
recode bc_disse_p .=0
g bc_disse_o=monto1 if bc_pe6a==3 & f16_2==1 & bc_disse_p==0
recode bc_disse_o .=0
g bc_disse=monto1 if bc_pe6a==3 & pobp==5 // disse de trabajadores en seguro de paro
recode bc_disse .=0
 
capture gen e6=0
capture gen e6_1_1=3 if e6==1

g bc_afam=0
g bc_yciudada=0
g bc_yalimpan=0
g bc_yhog=0
g bc_cuotmilit=0
g bc_cuotabps=0
