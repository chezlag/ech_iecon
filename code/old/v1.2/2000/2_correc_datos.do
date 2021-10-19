*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h2000s1i.dta", clear
append using "$rutaoriginales/h2000s1m.dta" 
append using "$rutaoriginales/h2000s2i.dta" 
append using "$rutaoriginales/h2000s2m.dta" 
cap rename *, lower
rename ident correlat
sort correlat
save "$rutainterm/h2000.dta", replace

u "$rutaoriginales/p2000s1i.dta", clear
append using "$rutaoriginales/p2000s1m.dta" 
append using "$rutaoriginales/p2000s2i.dta" 
append using "$rutaoriginales/p2000s2m.dta" 
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p2000.dta", replace

merge m:1 correlat using "$rutainterm/h2000.dta"

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
