*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h1990s1i.dta", clear
append using "$rutaoriginales/h1990s1m.dta" 
append using "$rutaoriginales/h1990s2i.dta" 
append using "$rutaoriginales/h1990s2m.dta" 
cap rename *, lower
destring ha0, g(correlat)
sort correlat
save "$rutainterm/h1990.dta", replace

u "$rutaoriginales/p1990s1i.dta", clear
append using "$rutaoriginales/p1990s1m.dta" 
append using "$rutaoriginales/p1990s2i.dta" 
append using "$rutaoriginales/p1990s2m.dta" 
cap rename *, lower
destring ha0, g(correlat)
sort correlat
save "$rutainterm/p1990.dta", replace

merge m:1 correlat using "$rutainterm/h1990.dta"


*-------------------------------------------------------------------------------
* Arreglos de nombres de variables 

destring ha3, g(dpto)
destring pe1, g(nper)

*-------------------------------------------------------------------------------
* Recodificación de datos


*-------------------------------------------------------------------------------
* Cambios de variables

sort correlat nper

