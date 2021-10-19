*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif_cine=ht11-ht11_css_sindef

compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 


/*------------------------------------------------------------------------------

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                 12         -6200    -1286.667   -38.00003
ht11>ht11_cs~f                333             3     229.3423        4000
                       ----------
jointly defined               345         -6200     176.6116        4000
                       ----------
total                         345
 

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 

sort bc_correlat bc_nper
