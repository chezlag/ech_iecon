*2_ ----------------------------------------------------------------------------
* Base original

u "$rutaoriginales/h1991s1i.dta", clear
append using "$rutaoriginales/h1991s1m.dta" 
append using "$rutaoriginales/h1991s2i.dta" 
append using "$rutaoriginales/h1991s2m.dta" 
cap rename *, lower
rename ident correlat
sort correlat
save "$rutainterm/h1991.dta", replace

u "$rutaoriginales/p1991s1i.dta", clear
append using "$rutaoriginales/p1991s1m.dta" 
append using "$rutaoriginales/p1991s2i.dta" 
append using "$rutaoriginales/p1991s2m.dta" 
rename correlativ correlat
cap rename *, lower
sort correlat
save "$rutainterm/p1991.dta", replace

merge m:1 correlat using "$rutainterm/h1991.dta"
/*
Hay 3 hogares que están en personas pero no en la base hogares:
correlat==103269 | correlat==107683 | correlat==200716
Son 13 personas en total.

En la base del 1991 compatibilizada el 107683 está en ambas bases, 
pero los otros dos solamente están en hogares.
*/

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

