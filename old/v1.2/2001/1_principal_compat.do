*1_ compatibilización 2001 -----------------------------------------------------

clear all
set more off
/*Estas rutas serán las definitvas por ahora están en Documentos
gl rutaprogramas "S:/empleo/datos/encuestas/ech/programas/Compatibilización ECH/2001"
gl rutaoriginales "S:/empleo/datos/encuestas/ech/ech originales/2001"
gl rutabases "S:/empleo/datos/encuestas/ech/personas/bases compatibilizadas"
gl rutainterm "S:/empleo/datos/encuestas/ech/personas/intermedias"
*/

/*Rutas de Alejandra
gl rutaprogramas "/home/amarroig/iecon/datos/ech/programas/compat_project/2001"
gl rutaoriginales "/home/amarroig/iecon/datos/ech/ech originales/2001"
gl rutabases "/home/amarroig/iecon/datos/ech/personas/bases compatibilizadas"
gl rutainterm "/home/amarroig/iecon/datos/ech/personas/intermedias"
*/

/*Rutas de Horacio*/
gl rutaprogramas "S:\empleo\datos\encuestas\ech\programas\compat_project\2001"
gl rutaoriginales "C:\Users\hrueda\Documents\Compat\ech\ech originales\2001"
gl rutabases "C:\Users\hrueda\Documents\Compat\2001"
gl rutainterm "C:\Users\hrueda\Documents\Compat\ech\intermedias\2001"


/*------------------------------------------------------------------------------
2_correc_datos
	*- Abre base original y arma fusionada con hogares (si es necesario)
	*- Renombra y recodifica variables y casos de la encuesta
*/	
run "$rutaprogramas/2_correc_datos.do"

/*------------------------------------------------------------------------------
3_compatibilizacion_mod_1_4
	*- Hace compatibles variables de los módulos 1 a 4:
		1- Características generales y de las personas
		2- Atención de la salud
		3- Educación
		4- Mercado de trabajo
*/
run "$rutaprogramas/3_compatibilizacion_mod_1_4.do"

/*------------------------------------------------------------------------------
4_ingreso_ht11_iecon
	*- Genera un ingreso del hogar (ht11_iecon) sumando todos los ingresos que se 
	declaran en la encuesta, sin descomponer por fuentes, que incluye seguro 
	de salud (si corresponde).
	*- Genera variables intermedias como cuotas militares, ingresos por alimentos
	transferidos a menores, etc. que luego se utilizan para la descomposición 
	por fuentes.
*/
run "$rutaprogramas/4_ingreso_ht11_iecon.do"

/*------------------------------------------------------------------------------
5_descomp_fuentes
	*- Genera variables de ingresos descomponiendo por fuentes y sin incluir 
	seguro de salud.
*/
run "$rutaprogramas/5_descomp_fuentes.do"

/*------------------------------------------------------------------------------
6_ingreso_ht11_sss
	*- Genera variables de ingresos agregadas como ingresos laborales, ingresos
	por capital, jubilaciones y pensiones, etc.
	*- Genera un ingreso del hogar como resultado de sumar las distintas fuentes
	de ingresos.
	*- Imputa seguro de salud para el hogar y se genera ht11_css para comparar 
	con el ht11_iecon.
	*- Genera ingresos per cápita incluyendo seguro y sin incluir
*/
run "$rutaprogramas/6_ingreso_ht11_sss.do"

/*------------------------------------------------------------------------------
7_check_ingr
	*- Compara el ht11_iecon con ht11_css.
*/
run "$rutaprogramas/7_check_ingr.do"

/*------------------------------------------------------------------------------
8_arregla_base_comp
	*- Drop de variables intermedias.
*/
run "$rutaprogramas/8_arregla_base_comp.do"

/*------------------------------------------------------------------------------
labels
	*- Etiquetas de valores de variables compatibles.
*/
run "$rutaprogramas/9_labels.do"
