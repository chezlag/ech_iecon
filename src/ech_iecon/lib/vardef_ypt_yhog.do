// vardef_ypt_yhog.do
// Ingreso personal total e ingresos del hogar –– replicación INE

* otros ingresos 
gen OTROSY = (g258_1/12) + g154_1 // devolución de fonasa + otros ingresos

// PT1 – ingresos personales

egen    pt1_iecon = rowtotal(YTDOP YTDOS YTINDE YTRANSF OTROSY)
recode  pt1_iecon   (. = 0)

egen    HPT1 = sum(pt1_iecon), by(bc_correlat)
replace HPT1 = 0 if !esjefe

// PT2 – INGRESOS DE LA OCUPACIÓN PRINCIPAL.

*PRIVADOS.
gen  PT2PRIV   = YTDOP if deppri_op

*PÚBLICOS.
gen  PT2PUB    = YTDOP if deppub_op

*INDEPENDIENTE.
gen  PT2NODEP  = YTINDE if independiente_op

* PT2 TOTAL.
egen pt2_iecon = rowtotal(PT2PRIV PT2PUB PT2NODEP)


// PT4 – TOTAL DE INGRESOS POR TRABAJO. OCUPACION PRINCIPAL Y SECUNDARIA

egen pt4_iecon = rowtotal(YTDOP YTDOS YTINDE)


// HT11 – INGRESOS DEL HOGAR

* ingresos relevados con frecuencia anual
#del ;
local yhog_anual "h160_1 h160_2 h163_1 h163_2 h164 h165 h166
	h269_1 h167_1_1 h167_1_2 h167_2_1 h167_2_2 h167_3_1 h167_3_2
	h167_4_1 h167_4_2 h170_1 h170_2   h271_1   h171_1   h172_1";
#del cr

egen yhog_anual = rowtotal(`yhog_anual')
	// excluye h173_1 – seguramente por ser ingreso extraordinario

gen yhog1 = h155_1 + h156_1 + h252_1 + (yhog_anual/12) + ///
	yt_ss_militotr + YALIMENT_MEN + yt_ss_fonasa_nolab + yt_ss_emerotr + yt_ss_otrohog

egen yhog_iecon = max(yhog1), by(bc_correlat)
drop yhog_anual yhog1

egen ht11_iecon = rowtotal(HPT1 ine_ht13 yhog_iecon)


*Hasta aquí se replican resultados de INE
*-------------------------------------------------------------------------------
