*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h1995s1i.dta", clear
append using "$rutaoriginales/h1995s1m.dta" 
append using "$rutaoriginales/h1995s2i.dta" 
append using "$rutaoriginales/h1995s2m.dta" 
cap rename *, lower
rename ident correlat
sort correlat
save "$rutainterm/h1995.dta", replace

u "$rutaoriginales/p1995s1i.dta", clear
append using "$rutaoriginales/p1995s1m.dta" 
append using "$rutaoriginales/p1995s2i.dta" 
append using "$rutaoriginales/p1995s2m.dta" 
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p1995.dta", replace

merge m:1 correlat using "$rutainterm/h1995.dta"

*-------------------------------------------------------------------------------
* Arreglos de nombres de variables 
rename pe1c dpto
rename persona nper

*-------------------------------------------------------------------------------
* Recodificación de datos

*-------------------------------------------------------------------------------
* Cambios de variables
destring dpto, replace

sort correlat nper
