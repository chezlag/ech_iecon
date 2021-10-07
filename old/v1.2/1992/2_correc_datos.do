*2_ ----------------------------------------------------------------------------
* Base original

*Hogares
u "$rutaoriginales/h1992s1i.dta", clear
tostring ident, g(newident)
g a="21"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/h1992s1i.dta", replace

u "$rutaoriginales/h1992s1m.dta", clear
tostring ident, g(newident)
g a="11"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/h1992s1m.dta", replace

u "$rutaoriginales/h1992s2i.dta", clear
tostring ident, g(newident)
g a="22"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/h1992s2i.dta", replace

u "$rutaoriginales/h1992s2m.dta", clear
tostring ident, g(newident)
g a="12"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/h1992s2m.dta", replace

u "$rutainterm/h1992s1i.dta", clear
append using "$rutainterm/h1992s1m.dta" 
append using "$rutainterm/h1992s2i.dta" 
append using "$rutainterm/h1992s2m.dta" 
cap rename *, lower
destring correlat_str, g(correlat)
sort correlat
save "$rutainterm/h1992.dta", replace

*Personas
u "$rutaoriginales/p1992s1i.dta", clear
tostring correlativ, g(newident)
g a="21"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/p1992s1i.dta", replace

u "$rutaoriginales/p1992s1m.dta", clear
tostring correlativ, g(newident)
g a="11"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/p1992s1m.dta", replace

u "$rutaoriginales/p1992s2i.dta", clear 
tostring correlativ, g(newident)
g a="22"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/p1992s2i.dta", replace 

u "$rutaoriginales/p1992s2m.dta", clear 
tostring correlativ, g(newident)
g a="12"
egen correlat_str=concat(a newident)
drop a newident
save "$rutainterm/p1992s2m.dta", replace

u "$rutainterm/p1992s1i.dta", clear
append using "$rutainterm/p1992s1m.dta" 
append using "$rutainterm/p1992s2i.dta" 
append using "$rutainterm/p1992s2m.dta" 
cap rename *, lower
destring correlat_str, g(correlat)
sort correlat
save "$rutainterm/p1992.dta", replace

merge m:1 correlat using "$rutainterm/h1992.dta"

/*
Hay 18 hogares que están en personas pero no en la base hogares:

correlat==11503146|correlat==11503692|correlat==11503997|correlat==11504097|
correlat==11505930|correlat==11508910|correlat==11509555|correlat==11510469|
correlat==11512560|correlat==11513628|correlat==11514383|correlat==11514695|
correlat==11515465|correlat==12604646|correlat==12604718|correlat==12609729|
correlat==12617134|correlat==12617982

Son 52 personas en total.
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
