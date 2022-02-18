*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif_cine=ht11-ht11_css_sindef

compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 


/*------------------------------------------------------------------------------
 
. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                175        -12500    -1503.463   -39.99994
ht11>ht11_cs~f                 53             3     534.6981        5223
                       ----------
jointly defined               228        -12500     -1029.68        5223
                       ----------
total                         228

**************************** divido los pg61p/o pg62p/o pg81p/o pg82p/o entre 12

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                175     -1041.667    -181.6976   -3.333313
ht11>ht11_cs~f                 53             3     540.4576        5223
                       ----------
jointly defined               228     -1041.667    -13.82821        5223
                       ----------
total                         228

********* Le saqué los pg61p/o pg62p/o pg81p/o pg82p/o y generé las variables =0

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                 29          -854    -314.7644   -12.58331
ht11>ht11_cs~f                 53             3     540.9811        5223
                       ----------
jointly defined                82          -854     238.3394        5223
                       ----------
total                          82

Ahora con la nueva forma de condicionar al generar bc_otros_lab
ESto incluye haberle sacado pg61p/o etc... 

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                 29          -854    -314.7644   -12.58331
ht11>ht11_cs~f                  4           645          887        1500
                       ----------
jointly defined                33          -854     -169.096        1500
                       ----------
total                          33

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 

sort bc_correlat bc_nper
