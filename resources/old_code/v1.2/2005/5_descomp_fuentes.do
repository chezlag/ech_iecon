*5_ ----------------------------------------------------------------------------

mvencode  g1_1_2 g1_1_3 g1_1_8 g1_1_7 g1_1_9 g3_8 g3_4 g5_5 g5_6 g3_6 g3_7 g4_1_2 g5_7 g5_10 g5_9 g4_2_4 g4_2_5 g4_2_6 g4_2_3 g5_11, mv(0) override

capture drop bc_pg11p 
capture drop bc_pg12p 
capture drop pg13p 
capture drop bc_pg14p 
capture drop bc_pg15p 
capture drop bc_pg16p 
capture drop bc_pg17p 
capture drop bc_pg21p
capture drop bc_pg22p 
capture drop pg23p 
capture drop bc_pg24p 
capture drop bc_pg25p 
capture drop bc_pg26p 
capture drop pg27p

** ingreso de la ocupación principal como dependientes

gen bc_pg11p=g1_1_1 if bc_pf41==1
gen bc_pg21p=g1_1_1 if bc_pf41==2
gen bc_pg12p=g1_1_2+g1_1_3+g1_1_8 if bc_pf41==1
gen bc_pg22p=g1_1_2+g1_1_3+g1_1_8 if bc_pf41==2
gen bc_pg14p=g1_1_5 if bc_pf41==1
gen bc_pg24p=g1_1_5 if bc_pf41==2
gen bc_pg15p=g1_1_6 if bc_pf41==1
gen bc_pg25p=g1_1_6 if bc_pf41==2
gen bc_pg16p=g1_1_4 if bc_pf41==1
gen bc_pg26p=g1_1_4 if bc_pf41==2

gen bc_pg17p=g1_1_7 if bc_pf41==1 // 18/6 se le saca g1_1_9*monto1
gen bc_pg27p=g1_1_7 if bc_pf41==2 // 18/6 se le saca g1_1_9*monto1

*replace pg17p_cf=pg17p_cf+disse_p  if bc_pf41==1 & bc_pe6a==3 
*replace pg27p_cf=pg27p_cf+disse_p  if bc_pf41==2 & bc_pe6a==3 

gen bc_pg13p=g3_8+g3_4 if bc_pf41==1
replace bc_pg13p=g3_8+monto2*g3_9_1+g3_4 if bc_pf41==1 & g3_9_2==2
gen bc_pg23p=g3_8+g3_4 if bc_pf41==2
replace bc_pg23p=g3_8+monto2*g3_9_1+g3_4 if bc_pf41==2 & g3_9_2==2

capture drop bc_pg11o 
capture drop bc_pg12o 
capture drop bc_pg13o 
capture drop bc_pg14o
capture drop bc_pg15o
capture drop bc_pg16o
capture drop bc_pg17o
capture drop bc_pg21o
capture drop bc_pg22o
capture drop bc_pg23o
capture drop bc_pg24o
capture drop bc_pg25o
capture drop bc_pg26o
capture drop bc_pg27o

* ingreso de la ocupación secundaria como dependiente

gen bc_pg11o=g1_2_1 if f13==1
gen bc_pg21o=g1_2_1 if f13==2
gen bc_pg12o=g1_2_2+g1_2_3+g1_2_8 if f13==1
gen bc_pg22o=g1_2_2+g1_2_3+g1_2_8 if f13==2
gen bc_pg14o=g1_2_5 if f13==1
gen bc_pg24o=g1_2_5 if f13==2
gen bc_pg15o=g1_2_6 if f13==1
gen bc_pg25o=g1_2_6 if f13==2
gen bc_pg16o=g1_2_4 if f13==1
gen bc_pg26o=g1_2_4 if f13==2
gen bc_pg17o=g1_2_7 if f13==1 // 18/6 se saca g1_2_9*monto1
gen bc_pg27o=g1_2_7 if f13==2 // 18/6 se saca g1_2_9*monto1

*replace pg17o_cf=pg17o_cf+disse_s  if f13==1 & (bc_pf41!=1 & bc_pf41!=2) & bc_pe6a==3 
*replace pg27o_cf=pg27o_cf+disse_s  if f13==2 & (bc_pf41!=1 & bc_pf41!=2) & bc_pe6a==3 

gen bc_pg13o=g3_8+g3_4 if f13==1 & (bc_pf41!=1 & bc_pf41!=2)
replace bc_pg13o=g3_8+monto2*g3_9_1+g3_4 if f13==1 & (bc_pf41!=1 & bc_pf41!=2) & g3_9_2==2
gen bc_pg23o=g3_8+g3_4 if f13==2 & (bc_pf41!=1 & bc_pf41!=2)
replace bc_pg23o=g3_8+monto2*g3_9_1+g3_4 if f13==2 & (bc_pf41!=1 & bc_pf41!=2) & g3_9_2==2


capture drop bc_pg11t 
capture drop bc_pg12t 
capture drop bc_pg13t 
capture drop bc_pg14t 
capture drop bc_pg15t 
capture drop bc_pg16t 
capture drop bc_pg17t 
capture drop bc_pg21t 
capture drop bc_pg22t 
capture drop bc_pg23t 
capture drop bc_pg24t 
capture drop bc_pg25t 
capture drop bc_pg26t 
capture drop bc_pg27t

*- 08/10/18 agrrego los bc_pg21o-27o
mvencode bc_pg11p bc_pg12p bc_pg13p bc_pg14p bc_pg15p bc_pg16p bc_pg17p bc_pg11o bc_pg12o bc_pg13o bc_pg14o bc_pg15o bc_pg16o bc_pg17o bc_pg21o bc_pg22o bc_pg23o bc_pg24o bc_pg25o bc_pg26o bc_pg27o, mv(0) override
gen bc_pg11t=bc_pg11o+bc_pg21o
gen bc_pg12t=bc_pg12o+bc_pg22o
gen bc_pg13t=bc_pg13o+bc_pg23o
gen bc_pg14t=bc_pg14o+bc_pg24o
gen bc_pg15t=bc_pg15o+bc_pg25o
gen bc_pg16t=bc_pg16o+bc_pg26o
gen bc_pg17t=bc_pg17o+bc_pg27o


capture drop  bc_pg32p
capture drop  bc_pg42p
capture drop  bc_pg72p
gen bc_pg32p=g3_8+g3_4 if bc_pf41==5
replace bc_pg32p=g3_8+monto2*g3_9_1+g3_4 if bc_pf41==5 & g3_9_2==2
gen bc_pg42p=g3_8+g3_4 if bc_pf41==6
replace bc_pg42p=g3_8+monto2*g3_9_1+g3_4 if bc_pf41==6 & g3_9_2==2
gen bc_pg72p=g3_8+g3_4 if bc_pf41==3
replace bc_pg72p=g3_8+monto2*g3_9_1+g3_4 if bc_pf41==3 & g3_9_2==2

capture drop  bc_pg32o
capture drop  bc_pg42o
capture drop  bc_pg72o
gen bc_pg32o=g3_8+g3_4 if f13==5 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg32o=g3_8+monto2*g3_9_1+g3_4 if f13==5 & g3_9_2==2 & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
gen bc_pg42o=g3_8+g3_4 if bc_pf41==6  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg42o=g3_8+monto2*g3_9_1+g3_4 if f13==6 & g3_9_2==2  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
gen bc_pg72o=g3_8+g3_4 if bc_pf41==3  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)
replace bc_pg72o=g3_8+monto2*g3_9_1+g3_4 if f13==3 & g3_9_2==2  & (bc_pf41!=5 & bc_pf41!=6 & bc_pf41!=3)

capture drop bc_pg31p 
capture drop bc_pg33p 
capture drop bc_pg41p
capture drop bc_pg43p
capture drop bc_pg51p
capture drop bc_pg52p
capture drop bc_pg71p
capture drop bc_pg73p
capture drop bc_pg60p
capture drop bc_pg80p

gen bc_pg31p=g2_1 if bc_pf41==5
gen bc_pg33p=g2_2 if bc_pf41==5 // 18/6 se saca g1_2_9*monto1

gen bc_pg41p=g2_1 if bc_pf41==6
gen bc_pg43p=g2_2 if bc_pf41==6 // 18/6 se saca g1_1_9*monto1

gen bc_pg51p=g2_1 if bc_pf41==4
gen bc_pg52p=g2_2 if bc_pf41==4 // 18/6 se saca g1_1_9*monto1

gen bc_pg71p=g2_1 if bc_pf41==3
gen bc_pg73p=g2_2 if bc_pf41==3 // 18/6 se saca g1_1_9*monto1

cap drop bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg51o bc_pg52o bc_pg71o bc_pg73o bc_pg60o bc_pg80o
gen bc_pg31o=g2_1 if (bc_pg31p==0|bc_pg31p==.) & f13==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) 
gen bc_pg33o=g2_2 if (bc_pg33p==0|bc_pg33p==.) & f13==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg41o=g2_1 if (bc_pg41p==0|bc_pg41p==.) & f13==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg43o=g2_2 if (bc_pg43p==0|bc_pg43p==.) & f13==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg51o=g2_1 if (bc_pg51p==0|bc_pg51p==.) & f13==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg52o=g2_2 if (bc_pg52p==0|bc_pg52p==.) & f13==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg71o=g2_1 if (bc_pg71p==0|bc_pg71p==.) & f13==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg73o=g2_2 if (bc_pg73p==0|bc_pg73p==.) & f13==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)

capture drop bc_otros_lab
gen bc_otros_lab=0
replace bc_otros_lab=g1_1_1+g1_1_2+g1_1_3+g1_1_4+g1_1_5+g1_1_6+g1_1_7+g1_1_8+g3_8+g3_4 if bc_pf41!=1 & bc_pf41!=2  
replace bc_otros_lab=g2_1+g2_2 if (bc_pf41!=3 & bc_pf41!=4 &  bc_pf41!=5 & bc_pf41!=6) & (f13!=3 & f13!=4 & f13!=5  & f13!=6) 
replace bc_otros_lab=g1_1_1+g1_1_2+g1_1_3+g1_1_4+g1_1_5+g1_1_6+g1_1_7+g1_1_8+g3_8+g3_4 if bc_pf41==-15 | bc_pf41==7 // Se agrega esta línea 08/10/18, 9/10 agrego bc_pf41==7
replace bc_otros_lab=bc_otros_lab+g2_1+g2_2 if (bc_pf41==-15 | bc_pf41==7) & (2<=bc_pobp<=5) // Se agrega esta línea  y se agrega bc_pf41a==7 , también se agrega pobp 

capture drop bc_otros_lab2
gen bc_otros_lab2=0
replace bc_otros_lab2=g1_2_1+g1_2_2+g1_2_3+g1_2_4+g1_2_5+g1_2_6+g1_2_7+g1_2_8 if f13!=1 & f13!=2  // 18/6 se saca (g1_2_9*monto1)
 
capture drop bc_otros_benef
gen bc_otros_benef=0
replace bc_otros_benef=g3_8+g3_4 if bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6 & f13!=1 & f13!=2 & f13!=3 & f13!=5 & f13!=6 
replace bc_otros_benef=g3_8+monto2*g3_9_1+g3_4 if bc_pf41!=1 & bc_pf41!=2 & bc_pf41!=3 & bc_pf41!=5 & bc_pf41!=6 & f13!=1 & f13!=2 & f13!=3 & f13!=5 & f13!=6 & g3_9_2==2


***************************************
capture rename g3_1 bc_pg911
capture rename g3_2 bc_pg912
capture rename g5_2 bc_pg921
capture rename g5_3 bc_pg922

cap drop bc_pg91 bc_pg92
gen bc_pg91=bc_pg911+bc_pg912
gen bc_pg92=bc_pg921+bc_pg922

cap drop bc_pg101
gen bc_pg101=0
replace bc_pg101=g3_3+g3_5
replace bc_pg101=g3_3+g3_5 if pobp==5 // 18/6 se saca disse_seguro 
capture rename g5_4 bc_pg102
cap drop bc_pg111 bc_pg112
gen bc_pg111=g3_6+g3_7
gen bc_pg112=g5_5+g5_6
capture rename g4_1_1 bc_pg121
gen bc_pg121a=bc_pg121+g4_2_1/12
drop bc_pg121
rename bc_pg121a bc_pg121
capture rename g5_8 bc_pg122
gen bc_pg122a=bc_pg122/12+g5_7/12
drop bc_pg122
rename bc_pg122a bc_pg122
capture rename g4_2_2 bc_pg131
gen bc_pg131a=bc_pg131/12
drop bc_pg131
rename bc_pg131a bc_pg131
cap drop bc_pg132
gen bc_pg132=g5_10/12+g5_9/12
capture rename ht13 bc_pg14

mvencode bc_pg14 bc_pg132 bc_pg131 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg122 bc_pg121, mv(0) override


mvencode g4_2_4 g4_2_5 g4_2_6 g4_1_2 g4_2_3 g5_11 , mv(0) override

mvencode g1_2_1 g1_2_2 g1_2_3 g1_2_4 g1_2_5 g1_2_6 g1_2_7 g1_2_8  g1_2_9 monto1 , mv(0) override

*-------------------------------------------------------------------------------
*- Ingresos de capital

*gen bc_pg60p=g2_3/12 if bc_pf41==4
*gen bc_pg80p=g2_3/12 if bc_pf41==3
gen bc_pg60p=g4_2_3/12+g2_3/12+g5_11/12 if bc_pf41==4 // Correcta
gen bc_pg80p=g4_2_3/12+g2_3/12+g5_11/12 if bc_pf41==3 // Ut. del bloque otros ingresos, ut. del bloque ingresos no dependientes y ut. de negocios del exterior 
gen bc_pg60p_cpsl=g4_2_3/12+g2_3/12+g5_11/12 if bc_pf41==5 //
gen bc_pg60p_cpcl=g4_2_3/12+g2_3/12+g5_11/12 if bc_pf41==6

*gen bc_pg60o=g2_3/12 if (bc_pg60p==0|bc_pg60p==.) & f13==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
*gen bc_pg80o=g2_3/12 if (bc_pg80p==0|bc_pg80p==.) & f13==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6)
gen bc_pg60o=g4_2_3/12+g2_3/12+g5_11/12 if (bc_pg60p==0|bc_pg60p==.) & f13==4 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) // Correcta
gen bc_pg80o=g4_2_3/12+g2_3/12+g5_11/12 if (bc_pg80p==0|bc_pg80p==.) & f13==3 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) // Correcta
gen bc_pg60o_cpsl=g4_2_3/12+g2_3/12+g5_11/12 if (bc_pg60p_cpsl==0|bc_pg60p_cpsl==.) & f13==5 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) // Correcta
gen bc_pg60o_cpcl=g4_2_3/12+g2_3/12+g5_11/12 if (bc_pg60p_cpcl==0|bc_pg60p_cpcl==.) & f13==6 & (bc_pf41!=3 & bc_pf41!=4 & bc_pf41!=5 & bc_pf41!=6) // Correcta


capture drop bc_otras_utilidades
gen bc_otras_utilidades=0
*replace bc_otras_utilidades=g4_2_3/12+g5_11/12+g2_3/12 if bc_pf41!=3 & bc_pf41!=4 & f13!=3 & f13!=4
*replace bc_otras_utilidades=g4_2_3/12+g5_11+g2_3/12 if bc_pf41==-9 // Se agrega está línea 05/04/19
replace bc_otras_utilidades=g4_2_3/12+g2_3/12+g5_11/12 if bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6&f13!=3&f13!=4&f13!=5&f13!=6|(bc_pf41==-9&f13==0) // Correcta

capture drop bc_ot_utilidades
gen bc_ot_utilidades=0 // Correcta 26/04/19

*replace bc_ot_utilidades=g4_2_3/12+g5_11/12 if bc_pf41==3 | bc_pf41==4 | f13==3 | f13==4 // Original
*replace bc_ot_utilidades=g4_2_3/12+g5_11/12+g2_3/12 if bc_pf41==3 | bc_pf41==4 | f13==3 | f13==4 // 05/04/19
*replace bc_ot_utilidades=g4_2_3/12+g2_3/12+g5_11 if bc_pf41==3 | bc_pf41==4 | f13==3 | f13==4 // 05/04/19

gen bc_otros=0
replace bc_otros=(g4_2_4+g4_2_5+g4_2_6)/12 +g4_1_2

*-------------------------------------------------------------------------------
* Pagos atrasados
g bc_pag_at=0

*-------------------------------------------------------------------------------
* Ingreso ciudadano
g bc_ing_ciud=0

*-------------------------------------------------------------------------------
* Otras utilidades imputables al hogar

g bc_otras_capital=0

*-------------------------------------------------------------------------------
*missing
mvencode bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p bc_pg17p bc_pg27p bc_pg13p bc_pg23p bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o bc_pg13o bc_pg23o bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t ///
bc_pg31p bc_pg33p bc_pg41p bc_pg43p bc_pg51p bc_pg52p bc_pg71p bc_pg73p bc_pg32p bc_pg42p bc_pg72p bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg51o bc_pg52o bc_pg71o bc_pg73o bc_pg32o bc_pg42o bc_pg72o bc_pg60p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg80p bc_pg60o bc_pg60o_cpsl bc_pg60o_cpcl bc_pg80o bc_otros_lab bc_otros_benef ///
bc_pag_at bc_otros bc_ing_ciud bc_pg91 bc_pg92 bc_pg911 bc_pg921 bc_pg912 bc_pg922 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132 bc_pg14 bc_otras_utilidades bc_ot_utilidades bc_otras_capital, mv(0) override
