*5_ ----------------------------------------------------------------------------
* Missing
mvencode pg11* pg12* pg13* pg14* pg15* pg16* pg17* pg21* pg22* pg23* pg24* pg25* pg26* pg27* ///
pg31* pg32* pg33* pg41* pg42* pg43* pg51* pg52* pg61* pg62* pg71* pg72* pg73* ///
pg81* pg82* pg91* pg92* pg10* , mv(0) override

*-------------------------------------------------------------------------------
* Trabajadores dependientes - ocup ppal
g bc_pg11p=pg11p if bc_pf41==1
g bc_pg21p=pg21p if bc_pf41==2
g bc_pg12p=pg12p if bc_pf41==1
g bc_pg22p=pg22p if bc_pf41==2
g bc_pg14p=pg14p if bc_pf41==1
g bc_pg24p=pg24p if bc_pf41==2
g bc_pg15p=pg15p if bc_pf41==1
g bc_pg25p=pg25p if bc_pf41==2
g bc_pg16p=pg16p if bc_pf41==1
g bc_pg26p=pg26p if bc_pf41==2
g bc_pg17p=pg17p if bc_pf41==1 
g bc_pg27p=pg27p if bc_pf41==2 

*-------------------------------------------------------------------------------
* Trabajadores dependientes - ocup ppal - benef sociales
g bc_pg13p=pg13p if bc_pf41==1
g bc_pg23p=pg23p if bc_pf41==2 

*-------------------------------------------------------------------------------
* Trabajadores dependientes - otras ocup
g bc_pg11o=pg11o 
g bc_pg21o=pg21o 
g bc_pg12o=pg12o 
g bc_pg22o=pg22o 
g bc_pg14o=pg14o 
g bc_pg24o=pg24o 
g bc_pg15o=pg15o 
g bc_pg25o=pg25o 
g bc_pg16o=pg16o 
g bc_pg26o=pg26o 
g bc_pg17o=pg17o 
g bc_pg27o=pg27o
	
*-------------------------------------------------------------------------------
* Trabajadores dependientes - otras ocup - benef sociales
g bc_pg13o=pg13o
g bc_pg23o=pg23o

*-------------------------------------------------------------------------------
* Trabajadores dependientes - total otras ocup
g bc_pg11t=bc_pg11o+bc_pg21o
g bc_pg12t=bc_pg12o+bc_pg22o
g bc_pg13t=bc_pg13o+bc_pg23o
g bc_pg14t=bc_pg14o+bc_pg24o
g bc_pg15t=bc_pg15o+bc_pg25o
g bc_pg16t=bc_pg16o+bc_pg26o
g bc_pg17t=bc_pg17o+bc_pg27o

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - ocup ppal
g bc_pg31p=pg31p if bc_pf41==5 //cp s/l
g bc_pg33p=pg33p if bc_pf41==5 //cp s/l
g bc_pg41p=pg41p if bc_pf41==6 //cp c/l
g bc_pg43p=pg43p if bc_pf41==6 //cp c/l
g bc_pg51p=pg51p if bc_pf41==4 //patrón
g bc_pg52p=pg52p if bc_pf41==4 //patrón
g bc_pg71p=pg71p if bc_pf41==3 //coop
g bc_pg73p=pg73p if bc_pf41==3 //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - ocup ppal - benef sociales 
g bc_pg32p=pg32p if bc_pf41==5 //cp s/l
g bc_pg42p=pg42p if bc_pf41==6 //cp c/l
g bc_pg72p=pg72p if bc_pf41==3 //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - otras ocup
g bc_pg31o=pg31o //cp s/l 
g bc_pg33o=pg33o //cp s/l
g bc_pg41o=pg41o //cp c/l
g bc_pg43o=pg43o //cp c/l
g bc_pg51o=pg51o //patrón
g bc_pg52o=pg52o //patrón
g bc_pg71o=pg71o //coop
g bc_pg73o=pg73o //coop

*-------------------------------------------------------------------------------
* Trabajadores no dependientes - otras ocup - benef sociales
g bc_pg32o=pg32o //cp s/l
g bc_pg42o=pg42o //cp c/l
g bc_pg72o=pg72o //coop

*-------------------------------------------------------------------------------
* Ingresos del capital

*Pruebo generarlas con 0 a ver si no da diferencias... ¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡

g bc_pg60p=0 if bc_pf41==4 //patrón
g bc_pg60p_cpsl=0 if bc_pf41==5 //cp s/l
g bc_pg60p_cpcl=0 if bc_pf41==6 //cp c/l

g bc_pg80p=0 if bc_pf41==3 //coop

g bc_pg60o=0
g bc_pg60o_cpsl=0
g bc_pg60o_cpcl=0

g bc_pg80o=0


/*
g bc_pg60p=(pg61p+pg62p)/12 if bc_pf41==4 //patrón
g bc_pg60p_cpsl=(pg61p+pg62p)/12 if bc_pf41==5 //cp s/l
g bc_pg60p_cpcl=(pg61p+pg62p)/12 if bc_pf41==6 //cp c/l

g bc_pg80p=(pg81p+pg82p)/12 if bc_pf41==3 //coop

g bc_pg60o=(pg61o+pg62o)/12
g bc_pg60o_cpsl=0
g bc_pg60o_cpcl=0

g bc_pg80o=(pg81o+pg82o)/12
*/

*-------------------------------------------------------------------------------
* Otros lab
g bc_otros_lab=0
	replace bc_otros_lab=pg11p+pg12p+pg14p+pg15p+pg16p+pg17p+pg13p if bc_pf41!=1
	replace bc_otros_lab=bc_otros_lab+pg21p+pg22p+pg24p+pg25p+pg26p+pg27p+pg23p if bc_pf41!=2
	replace bc_otros_lab=bc_otros_lab+pg31p+pg33p+pg32p if bc_pf41!=5
	replace bc_otros_lab=bc_otros_lab+pg41p+pg43p+pg42p if bc_pf41!=6
	replace bc_otros_lab=bc_otros_lab+pg51p+pg52p if bc_pf41!=4
	replace bc_otros_lab=bc_otros_lab+pg71p+pg73p+pg72p if bc_pf41!=3

*-------------------------------------------------------------------------------
* Otros benef 
g bc_otros_benef=0
	
*-------------------------------------------------------------------------------
* Pagos atrasados
g bc_pag_at=0

*-------------------------------------------------------------------------------
* Otros suma pagos atrasados a indemnización por despido
g bc_otros=bc_pag_at

*-------------------------------------------------------------------------------
* Ingreso ciudadano
g bc_ing_ciud=0

*-------------------------------------------------------------------------------
* Jubilaciones o pensiones

g bc_pg91=pg911+pg912
g bc_pg92=pg921+pg922

rename pg911 bc_pg911
rename pg912 bc_pg912
rename pg921 bc_pg921
rename pg922 bc_pg922

*-------------------------------------------------------------------------------
* Otras transferencias

rename pg101 bc_pg101
rename pg102 bc_pg102
rename pg111 bc_pg111
rename pg112 bc_pg112
rename pg121 bc_pg121
rename pg122 bc_pg122

rename pg131 bc_pg131
rename pg132 bc_pg132

*-------------------------------------------------------------------------------
* Valor locativo
g bc_pg14=pg14

*-------------------------------------------------------------------------------
* Otras utilidades imputables al hogar
g bc_otras_utilidades=0
	replace bc_otras_utilidades=(pg61p+pg62p+pg81p+pg82p)/12 if (bc_pf41!=3&bc_pf41!=4&bc_pf41!=5&bc_pf41!=6)

g bc_ot_utilidades=0

g bc_otras_capital=0

*-------------------------------------------------------------------------------
*missing
mvencode bc_pg11p bc_pg21p bc_pg12p bc_pg22p bc_pg14p bc_pg24p bc_pg15p bc_pg25p bc_pg16p bc_pg26p bc_pg17p bc_pg27p bc_pg13p bc_pg23p bc_pg11o bc_pg21o bc_pg12o bc_pg22o bc_pg14o bc_pg24o bc_pg15o bc_pg25o bc_pg16o bc_pg26o bc_pg17o bc_pg27o bc_pg13o bc_pg23o bc_pg11t bc_pg12t bc_pg13t bc_pg14t bc_pg15t bc_pg16t bc_pg17t ///
bc_pg31p bc_pg33p bc_pg41p bc_pg43p bc_pg51p bc_pg52p bc_pg71p bc_pg73p bc_pg32p bc_pg42p bc_pg72p bc_pg31o bc_pg33o bc_pg41o bc_pg43o bc_pg51o bc_pg52o bc_pg71o bc_pg73o bc_pg32o bc_pg42o bc_pg72o bc_pg60p bc_pg60p_cpsl bc_pg60p_cpcl bc_pg80p bc_pg60o bc_pg60o_cpsl bc_pg60o_cpcl bc_pg80o bc_otros_lab bc_otros_benef ///
bc_pag_at bc_otros bc_ing_ciud bc_pg91 bc_pg92 bc_pg911 bc_pg921 bc_pg912 bc_pg922 bc_pg101 bc_pg102 bc_pg111 bc_pg112 bc_pg121 bc_pg122 bc_pg131 bc_pg132 bc_pg14 bc_otras_utilidades bc_ot_utilidades bc_otras_capital, mv(0) override













