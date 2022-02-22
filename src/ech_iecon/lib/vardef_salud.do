/* 
	vardef_salud.do
	Defino variables principales de salud 2011–2019
*/

g bc_pe6a=.q
	replace bc_pe6a=4 if (ss_asse==1 & ss_fonasa==0) | ss_mili==1 | ss_bps==1 | ss_muni==1
	replace bc_pe6a=2 if ss_iamc==1 & ss_fonasa==0
	replace bc_pe6a=3 if ss_fonasa==1 // (ss_asse & ss_fonasa) | (ss_iamc & ss_fonasa) | (ss_priv & ss_fonasa) <- equivalentes, en tanto se cumpla el chequeo
	replace bc_pe6a=5 if (ss_priv==1 | ss_emer==1) & ss_fonasa==0
	replace bc_pe6a=1 if ss_asse==0 & ss_iamc==0 & ss_priv==0 & ss_mili==0 & ss_bps==0 & ss_muni==0 & ss_emer==0

g bc_pe6a1=.q
	replace bc_pe6a1=1  if bc_pe6a==3 & ((bc_pobp==2 & formal==1) | bc_pobp==5)
	replace bc_pe6a1=2  if bc_pe6a==3 & bc_pe6a1!=1
	replace bc_pe6a1=.c if bc_pe6a!=3

recode bc_pe6a (2=2) (3=.c) (4=3) (5=4), gen(bc_pe6b)
