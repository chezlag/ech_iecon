*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h1993s1i.dta", clear
append using "$rutaoriginales/h1993s1m.dta" 
append using "$rutaoriginales/h1993s2i.dta" 
append using "$rutaoriginales/h1993s2m.dta" 
cap rename *, lower
rename ident correlat
sort correlat
save "$rutainterm/h1993.dta", replace

u "$rutaoriginales/p1993s1i.dta", clear
append using "$rutaoriginales/p1993s1m.dta" 
append using "$rutaoriginales/p1993s2i.dta" 
append using "$rutaoriginales/p1993s2m.dta" 
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p1993.dta", replace

merge m:1 correlat using "$rutainterm/h1993.dta"

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
