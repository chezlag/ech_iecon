g ht11_nuev_cf_sindef=ht11_nuev_cf/bc_ipc
g dif_sindef=ht11_iecon-ht11_nuev_cf_sindef
g ht11_iecon2=ht11_iecon
g ine_ht112=ht11

compare ht11_iecon ht11_nuev_cf_sindef if bc_pe4!=7 & (abs(dif)>2)

*-------------------------------------------------------------------------------
*dropeo variables generadas para chequeo
cap drop ht11_nuev_cf_sindef 
cap drop dif_sindef ine_ht112
cap drop ht11_iecond
cap drop dif_sindef2
cap drop ht11_iecon2
