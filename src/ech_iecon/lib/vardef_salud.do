/* 
	vardef_salud.do
	Defino variables principales de salud 2011–2019
*/

// variables auxiliares ---------------------------------------------

* derecho de atención en cada servicio
gen ss_asse = `ss_asse'
gen ss_iamc = `ss_iamc'
gen ss_priv = `ss_priv'
gen ss_mili = `ss_mili'
gen ss_bps  = `ss_bps'
gen ss_muni = `ss_muni'
gen ss_otro = `ss_otro'
gen ss_emer = `ss_emer'
/* * V2: solo para quienes se repregunta
gen ss_asseV2 = `ss_asseV2'
gen ss_iamcV2 = `ss_iamcV2'
gen ss_privV2 = `ss_privV2'
gen ss_miliV2 = `ss_miliV2' */

* origen del derecho de atención
clonevar ss_asse_o = `ss_asse_o'
clonevar ss_iamc_o = `ss_iamc_o'
clonevar ss_priv_o = `ss_priv_o'
clonevar ss_mili_o = `ss_mili_o'
clonevar ss_emer_o = `ss_emer_o'

* nper de personas que generan derechos de salud a otros integrantes del hogar
gen nper_d_asseemp = `nper_d_asseemp'
gen nper_d_iamcemp = `nper_d_iamcemp'
gen nper_d_privemp = `nper_d_privemp'
gen nper_d_mili    = `nper_d_mili'
gen nper_d_emeremp = `nper_d_emeremp'

* chequeo: solo se repregunta a quienes declaran tener derecho de atención
/* foreach inst in asse iamc priv mili emer {
	assert inrange(ss_`inst'_o, 1, 6)  if ss_`inst'
	assert ss_`inst'_o==0 if !ss_`inst'
} */

* accede a la salud por fonasa (dentro o fuera del hogar)
gen ss_fonasa = inlist(ss_asse_o, 1, 4) | ///
				inlist(ss_iamc_o, 1, 6) | ///
				inlist(ss_priv_o, 1, 6)

* fonasa dentro del hogar
gen ss_fonasa_o_h = ss_asse_o==1 | ss_iamc_o==1 | ss_priv_o==1

* accede a salud sin pago – fonasa o por otras personas dentro o fuera del hogar
gen ss_sinpago   = inlist(ss_asse_o, 1, 4, 5, 6) | /// 
			  	   inlist(ss_iamc_o, 1, 6, 3, 5) | /// 
			  	   inlist(ss_priv_o, 1, 6, 3, 5)   

* derecho de atención origina en un pago de alguien dentro del hogar
gen ss_asse_o_hpago = inlist(ss_asse_o, 2, 3)
gen ss_iamc_o_hpago = ss_iamc_o==2
gen ss_priv_o_hpago = ss_priv_o==2

* derecho de atención militar originado por alguien del hogar
gen     ss_mili_o_h = ss_mili_o==1

* cuota IAMC paga por empleador 
*	excluyendo personas sin derecho a atenderse en ASSE o seguro privado
*	o quienes acceden a través de un pago (o bajos recursos en ASSE)
gen ss_iamcemp =  ss_iamc_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)
gen ss_asseemp =  ss_asse_o==5 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)
gen ss_privemp =  ss_priv_o==5 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago)
gen ss_emeremp =  ss_emer_o==4

* cuotas para este hogar generadas desde otro hogar 
gen ss_otrohog = (ss_asse_o==6 & (!ss_iamc | ss_iamc_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_iamc_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_priv | ss_priv_o_hpago)) ///
		       | (ss_priv_o==3 & (!ss_asse | ss_asse_o_hpago) & (!ss_iamc | ss_iamc_o_hpago))
* emergencia móvil paga de otro hogar
gen ss_emerotr = ss_emer_o==3


// variables compatibilizadas ----------------------------------------

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
