*1_ compatibilización 1981-1989 ------------------------------------------------

clear all
set more off
/*Estas rutas serán las definitvas por ahora están en Documentos
gl rutaprogramas "S:/empleo/datos/encuestas/ech/programas/Compatibilización ECH/1981-1989"
gl rutabasesorig "S:/empleo/datos/encuestas/ech/personas/bases compatibilizadas/antes"
gl rutabases "S:/empleo/datos/encuestas/ech/personas/bases compatibilizadas"
*/
/*
cap cd "S:/empleo/datos/encuestas/ech" //servidor iecon
cap cd "/home/amarroig/iecon/datos/ech" //servidor remoto iecon
cap cd "//164.73.246.107/amarroig/alejandra/iecon/datos/encuestas/ech" //iesta

gl rutaprogramas "./programas/compat_project/1981-1989" // "./programas/Compatibilización ECH/1981-1989"
gl rutabasesorig "./personas/bases compatibilizadas/antes"
gl rutabases "./personas/bases compatibilizadas"
*/

cap cd "C:\Users\hrueda\Documents\Compat\ech"

gl rutaprogramas "S:\empleo\datos\encuestas\ech\programas\compat_project\1981-1989"
gl rutabasesorig "C:\Users\hrueda\Documents\Compat\ech\ech originales"
gl rutabases "C:\Users\hrueda\Documents\Compat\ech\ech compatibilizadas"
gl rutainterm "C:\Users\hrueda\Documents\Compat\ech\intermedias"

/*------------------------------------------------------------------------------
Para este período no se hace el mismo procedimiento que parte de las bases 
originales del INE. Las bases originales de la ECH en este período no están 
disponibles en la Web del INE por tanto no tiene sentido hacer el mismo 
procedimiento que para el resto del período.
Las bases que se toman como insumo son las que se encuentran compatibilizadas
en el servidor Iecon y se renombran algunas variables y se realizan algunas
modificaciones para la compatibilización.
*/	
run "$rutaprogramas/2_compat.do"



