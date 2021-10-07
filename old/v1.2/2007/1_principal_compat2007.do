* compatibilización 2007 - luego de revisión

clear all
set more off
/*Estas rutas serán las definitvas por ahora están en Documentos
gl rutaprogramas "S:/empleo/datos/encuestas/ech/programas/Compatibilización ECH"
gl rutaoriginales "S:/empleo/datos/encuestas/ech/ech originales"
gl rutabases "S:/empleo/datos/encuestas/ech/personas/bases compatibilizadas"
gl rutainterm "S:/empleo/datos/encuestas/ech/personas/intermedias"
*/

gl rutaprogramas "C:/Users/amarroig/Documents/ech/programas/revision_compatibilizacion/2007"
gl rutaoriginales "C:/Users/amarroig/Documents/ech"
gl rutabases "C:/Users/amarroig/Documents/ech/personas/bases compatibilizadas"
gl rutainterm "C:/Users/amarroig/Documents/ech/personas/intermedias"

do "$rutaprogramas/2_correcdatos_2007.do"

do "$rutaprogramas/compatibilizacion_2007.do"

do "$rutaprogramas/ingreso_2007.do"

do "$rutaprogramas/paso1_2007.do"

do "$rutaprogramas/paso2_2007.do"

do "$rutaprogramas/zcheck_ingr_2007.do"

do "$rutaprogramas/labels.do"

save "$rutabases/p7", replace
