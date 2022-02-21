// vardef_y_trabajo.do
// Ingreso de trabajo por todo concepto

// ingresos por trabajo dependiente – ocupación principal

* monetizo los pagos en especie
gen g127_1_y = g127_1 * mto_desa
gen g127_2_y = g127_2 * mto_almu
gen g132_1_y = g132_1 * mto_vaca
gen g132_2_y = g132_2 * mto_ovej
gen g132_3_y = g132_3 * mto_caba
* mensualizo ingresos relevados en forma anual
gen g133_2_y = g133_2 / 12

* genero locals por rubro para agregarlos
local ytdop_1_dinero   "g126_1   g126_2    g126_3    g126_4 g126_5 g126_6 g126_7 g126_8"
local ytdop_1_aliment  "g127_1_y g127_2_y  g127_3"
local ytdop_1_especie  "g128_1   g129_2    g130_1    g131_1"
local ytdop_1_pastoreo "g132_1_y g132_2_y  g132_3_y"
local ytdop_1_autocult "g133_1   g133_2_y"

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdop_1 = rowtotal(`ytdop_1_dinero' `ytdop_1_aliment' `ytdop_1_especie' ///
						`ytdop_1_pastoreo' `ytdop_1_autocult')

* ingresos TOTALES por trabajo dependiente en op –– sumo cuotas mutuales 
egen YTDOP =  rowtotal(ytdop_1 ytdop_2 ytdop_3 yt_ss_emp yt_ss_emeremp yt_ss_asseemp)

// ingresos por trabajo dependiente – ocupación secundaria

* monetizo los pagos en especie
gen g135_1_y = g135_1 * mto_desa
gen g135_2_y = g135_2 * mto_almu
gen g140_1_y = g140_1 * mto_vaca
gen g140_2_y = g140_2 * mto_ovej
gen g140_3_y = g140_3 * mto_caba
* mensualizo ingresos relevados en forma anual
gen g141_2_y = g141_2 / 12

* genero locals por rubro para agregarlos
local ytdos_1_dinero   "g134_1   g134_2    g134_3    g134_4 g134_5 g134_6 g134_7 g134_8"
local ytdos_1_aliment  "g135_1_y g135_2_y  g135_3"
local ytdos_1_especie  "g136_1   g137_2    g138_1    g139_1"
local ytdos_1_pastoreo "g140_1_y g140_2_y  g140_3_y"
local ytdos_1_autocult "g141_1   g141_2_y"

* suma: ingresos por trabajo dependiente en ocupación principal
egen ytdos_1 = rowtotal(`ytdos_1_dinero' `ytdos_1_aliment' `ytdos_1_especie' ///
						`ytdos_1_pastoreo' `ytdos_1_autocult')

* ingresos TOTALES por trabajo dependiente en os –– sumo cuotas mutuales 
egen YTDOS = rowtotal(ytdos_1 ytdos_2 ytdos_3)

// ingresos por trabajo independiente

* mensualizo ingresos relevados en forma anual
foreach varn in g143 g145 g146 g147 {
	gen `varn'_y = `varn'/12
}

* genero locals por rubro para agregarlos
local ytinde_1_utilidades  "g142   g143_y" // utilidades o retiro de $
local ytinde_1_autoconsumo "g144_1 g144_2_1 g144_2_2 g144_2_3 g144_2_4 g144_2_5"
local ytinde_1_negocioagro "g145_y g146_y   g147_y"

egen YTINDE_1 = rowtotal(`ytinde_1_utilidades' `ytinde_1_autoconsumo' `ytinde_1_negocioagro')

* ingresos TOTALES por trabajo independiente –– sumo cuotas mutuales
egen YTINDE   = rowtotal(YTINDE_1 YTINDE_2)

