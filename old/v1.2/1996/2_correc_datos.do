*2_ ----------------------------------------------------------------------------
* Base original

* Arreglo HT4 en h1996s2m.dta
u "$rutaoriginales/h1996s2m.dta", clear
destring ht4 ht6-ht9 ht10 ht12 ht16, replace
save "$rutainterm/h1996s2m.dta", replace

u "$rutaoriginales/h1996s1i.dta", clear
append using "$rutaoriginales/h1996s1m.dta" 
append using "$rutaoriginales/h1996s2i.dta" 
append using "$rutainterm/h1996s2m.dta" 
cap rename *, lower
rename ident correlat
sort correlat
save "$rutainterm/h1996.dta", replace

u "$rutaoriginales/p1996s1i.dta", clear
append using "$rutaoriginales/p1996s1m.dta" 
append using "$rutaoriginales/p1996s2i.dta" 
append using "$rutaoriginales/p1996s2m.dta" 
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p1996.dta", replace

merge m:1 correlat using "$rutainterm/h1996.dta"

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
