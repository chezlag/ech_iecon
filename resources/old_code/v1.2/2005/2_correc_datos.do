*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h2005.dta", clear
cap rename *, lower
rename correlativ correlat
sort correlat
save "$rutainterm/h2005.dta", replace

u "$rutaoriginales/p2005.dta", clear
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p2005.dta", replace

merge m:1 correlat using "$rutainterm/h2005.dta"

*-------------------------------------------------------------------------------
* Arreglos de nombres de variables 

*-------------------------------------------------------------------------------
* Recodificación de datos

*-------------------------------------------------------------------------------
* Cambios de variables
destring dpto, replace

sort correlat nper
