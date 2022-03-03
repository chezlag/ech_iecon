/* 
	vardef_y_aux_ht11.do

	Compatibilización previa a ht11 y descomposición por fuentes. 

	Streamline de los ingresos para acortar procesamiento en los demás programas
*/

// convierto varlists a variables ------------------------------------

* ingresos laborales
#del ;
loc yl_all     "yl_rem_salario_op yl_rem_comisiones_op yl_rem_aguinaldo_op yl_rem_vacacional_op yl_rem_propina_op yl_rem_atrasado_op
		        yl_rem_salario_os yl_rem_comisiones_os yl_rem_aguinaldo_os yl_rem_vacacional_os yl_rem_propina_os yl_rem_atrasado_os
		        yl_rem_esp_op yl_rem_esp_os yl_ben_mon yl_mix_mon_mes yl_mix_mon_ano yl_mix_esp";
#del cr
* ingresos por transferencias
loc yt_jubpen  "y_pg911 y_pg912 y_pg921 y_pg922 y_pg101 y_pg102"
loc yt_contrib "y_pg111_per y_pg111_hog y_pg112_per y_pg112_hog"
* ingresos de capital
loc yk_rentas  "y_pg121_ano y_pg121_mes y_pg122_ano y_pg122_mes y_pg131 y_pg132"
loc yk_util    "yk_util_per yk_util_hog"
loc yk_otro    "yk_otro_hog"

* lista de varlists
loc varlist_list `yl_all' ///
				 `yt_jubpen' `yt_contrib' ///
				 `yk_rentas' `yk_util' `yk_otro'

* genero variables agregadas de cada rubro
foreach varn in `varlist_list' {
	di "`varn'"
	egen `varn' = rowtotal(``varn'')
}

// agregados de ingresos ----------------------------------------------

* suma de ingresos laborales por remuneraciones
egen yl_rem_mon_op = rowtotal(yl_rem_salario_op yl_rem_comisiones_op yl_rem_aguinaldo_op yl_rem_vacacional_op yl_rem_propina_op)
egen yl_rem_mon_os = rowtotal(yl_rem_salario_os yl_rem_comisiones_os yl_rem_aguinaldo_os yl_rem_vacacional_os yl_rem_propina_os)

* suma de ingresos laborales op y os
egen yl_rem_mon    = rowtotal(yl_rem_mon_op yl_rem_mon_os)
egen yl_rem_esp    = rowtotal(yl_rem_esp_op yl_rem_esp_os)
* suma de ingresos por op/os
egen yl_rem_op = rowtotal(yl_rem_mon_op yl_rem_esp_op)
egen yl_rem_os = rowtotal(yl_rem_mon_os yl_rem_esp_os)

* suma de ingresos mixtos
gen  yl_mix_mon    = yl_mix_mon_mes + yl_mix_mon_ano/12
