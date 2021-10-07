*-------------------------------------------------------------------------------
*- Este es un chequeo de que la variable ht11d esté bien construida
*-------------------------------------------------------------------------------

clear all
set more off
cd "C:\Users\hrueda\Documents\Compat\Ingresos\Comparacion"

u "C:\Users\hrueda\Documents\Compat\ech\ech originales\2015\Fusionado_2015_terceros.dta"
append using "C:\Users\hrueda\Documents\Compat\ech\ech originales\2016\fusionado_2016_terceros.dta"
append using "C:\Users\hrueda\Documents\Compat\ech\ech originales\2017\Fusionado_2017_terceros.dta"

destring mes, replace
destring anio, replace
*destring numero, replace

g bc_area=.
replace bc_area=0 if region_4==1 // Montevideo
replace bc_area=1 if region_4==2 // Interior mayores de 5000
replace bc_area=2 if region_4==3 // Interior menores de 5000
replace bc_area=3 if region_4==4 // rurales - rural dispersa

cap drop bc_filtloc
g bc_filtloc=(region_4<3) // localidades de mÃ¡s de 5000 

gen bc_ipc=.
replace	bc_ipc=	0.53846233	if	mes==	1	&	anio==	2015
replace	bc_ipc=	0.52789826	if	mes==	2	&	anio==	2015
replace	bc_ipc=	0.52154472	if	mes==	3	&	anio==	2015
replace	bc_ipc=	0.51813664	if	mes==	4	&	anio==	2015
replace	bc_ipc=	0.51530666	if	mes==	5	&	anio==	2015
replace	bc_ipc=	0.51261318	if	mes==	6	&	anio==	2015
replace	bc_ipc=	0.51008730	if	mes==	7	&	anio==	2015
replace	bc_ipc=	0.50374396	if	mes==	8	&	anio==	2015
replace	bc_ipc=	0.49855489	if	mes==	9	&	anio==	2015
replace	bc_ipc=	0.49448654	if	mes==	10	&	anio==	2015
replace	bc_ipc=	0.49125993	if	mes==	11	&	anio==	2015
replace	bc_ipc=	0.48913214	if	mes==	12	&	anio==	2015
replace	bc_ipc=	0.49119517	if	mes==	1	&	anio==	2016
replace	bc_ipc=	0.48015175	if	mes==	2	&	anio==	2016
replace	bc_ipc=	0.47218217	if	mes==	3	&	anio==	2016
replace	bc_ipc=	0.46726823	if	mes==	4	&	anio==	2016
replace	bc_ipc=	0.46508147	if	mes==	5	&	anio==	2016
replace	bc_ipc=	0.46113937	if	mes==	6	&	anio==	2016
replace	bc_ipc=	0.45937723	if	mes==	7	&	anio==	2016
replace	bc_ipc=	0.45740384	if	mes==	8	&	anio==	2016
replace	bc_ipc=	0.45469714	if	mes==	9	&	anio==	2016
replace	bc_ipc=	0.45347990	if	mes==	10	&	anio==	2016
replace	bc_ipc=	0.45276367	if	mes==	11	&	anio==	2016
replace	bc_ipc=	0.45215940	if	mes==	12	&	anio==	2016
replace	bc_ipc=	0.45375597	if	mes==	1	&	anio==	2017
replace	bc_ipc=	0.44286367	if	mes==	2	&	anio==	2017
replace	bc_ipc=	0.43991003	if	mes==	3	&	anio==	2017
replace	bc_ipc=	0.43689306	if	mes==	4	&	anio==	2017
replace	bc_ipc=	0.43592207	if	mes==	5	&	anio==	2017
replace	bc_ipc=	0.43515855	if	mes==	6	&	anio==	2017
replace	bc_ipc=	0.43411938	if	mes==	7	&	anio==	2017
replace	bc_ipc=	0.43275826	if	mes==	8	&	anio==	2017
replace	bc_ipc=	0.42929361	if	mes==	9	&	anio==	2017
replace	bc_ipc=	0.42698187	if	mes==	10	&	anio==	2017
replace	bc_ipc=	0.42498549	if	mes==	11	&	anio==	2017
replace	bc_ipc=	0.42372914	if	mes==	12	&	anio==	2017


gen ht11d=ht11*bc_ipc

bys numero: egen m_ht11d = max(ht11d)
replace ht11d=m_ht11d if ht11d==0

bys anio: sum ht11d  [aw=pesoano] if ht11d  !=0 & ht11d  !=. & bc_filtloc==1

*- Me voy a quedar con la 2017 para comparar


keep anio numero ht11d nper e30  bc_filtloc

rename nper bc_nper
rename numero bc_correlat
rename ht11d ht11_original_d
rename anio bc_anio

save "15_17_original.dta",replace

u "C:\Users\hrueda\Documents\Compat\ech\ech compatibilizadas\p15.dta", clear
append using "C:\Users\hrueda\Documents\Compat\ech\ech compatibilizadas\p16.dta"
append using "C:\Users\hrueda\Documents\Compat\ech\ech compatibilizadas\p17.dta"

keep bc_anio bc_correlat bc_ht11d bc_nper e30  bc_filtloc bc_pesoan

save "15_17_compat.dta",replace

merge 1:1 bc_correlat bc_nper bc_anio using "C:\Users\hrueda\Documents\Compat\Ingresos\Comparacion\15_17_original.dta"

bys bc_anio: sum ht11_original_d  [aw=bc_pesoan] if ht11_original_d  !=0 & ht11_original_d  !=. & bc_filtloc==1 & e30!=14
bys bc_anio: sum bc_ht11d  [aw=bc_pesoan] if bc_ht11d  !=0 & bc_ht11d  !=. & bc_filtloc==1 & e30!=14

