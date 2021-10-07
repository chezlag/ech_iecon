*4_ ----------------------------------------------------------------------------

g bc_disse_p=monto1 if bc_pe6a==3 & f10_2==1 // derechos de atención médica a través de disse y con derecho a la jubilación
recode bc_disse_p .=0
g bc_disse_o=monto1 if bc_pe6a==3 & f16_2==1 & bc_disse_p==0 // derecho a través de disse y con derecho a jubilación en ocupación secundaria
recode bc_disse_o .=0
g bc_disse=monto1 if bc_pe6a==3 & pobp==5 // disse de trabajadores en seguro de paro
recode bc_disse .=0
gen bc_disse_otros=monto1 if bc_pe6a==3 & bc_disse_p==0 & bc_disse_o==0 & bc_disse==0 	// 09/10 se incluye disse para trabajadores sin derechos
																						// jubilatorios solo para generar el vector de diferencias
recode bc_disse_otros .=0
capture gen e6=0
capture gen e6_1_1=3 if e6==1

g bc_afam=0
g bc_yciudada=0
g bc_yalimpan=0
g bc_yhog=0
g bc_cuotmilit=0
g bc_cuotabps=0
