* compatibilización 2007 - luego de revisión

clear all
set more off
/*Estas rutas serán las definitvas por ahora están en Documentos
gl rutaprogramas "S:/empleo/datos/encuestas/ech/programas/Compatibilización ECH"
gl rutaoriginales "S:/empleo/datos/encuestas/ech/ech originales"
gl rutabases "S:/empleo/datos/encuestas/ech/personas/bases compatibilizadas"
gl rutainterm "S:/empleo/datos/encuestas/ech/personas/intermedias"


gl rutaprogramas "C:/Users/amarroig/Documents/ech/programas/revision_compatibilizacion/2007"
gl rutaoriginales "C:/Users/amarroig/Documents/ech/2007"
gl rutabases "C:/Users/amarroig/Documents/ech/personas/bases compatibilizadas"
gl rutainterm "C:/Users/amarroig/Documents/ech/personas/intermedias"
*/

/*Rutas de Horacio*/

gl rutaprogramas "S:\empleo\datos\encuestas\ech\programas\compat_project\2007"
gl rutaoriginales "C:\Users\hrueda\Documents\Compat\ech\ech originales\2007"
gl rutabases "C:\Users\hrueda\Documents\Compat\2007"
gl rutainterm "C:\Users\hrueda\Documents\Compat\ech\intermedias\2007"



u "$rutaoriginales/fusionado_2007_terceros.dta", clear
*u "$rutaoriginales/revisados 08042014/fusionado_2007_terceros.dta", clear

run "$rutaprogramas/2_correc_datos.do"

run "$rutaprogramas/3_compatibilizacion_mod_1_4.do"

run "$rutaprogramas/4_ingreso_ht11_iecon.do"

run "$rutaprogramas/5_descomp_fuentes.do"

run "$rutaprogramas/6_ingreso_ht11_nuev.do"

run "$rutaprogramas/7_zcheck_ingr_2007.do"

run "$rutaprogramas/8_arregla_base_comp.do"

run "$rutaprogramas/9_labels.do"

*save "$rutabases/p7", replace


