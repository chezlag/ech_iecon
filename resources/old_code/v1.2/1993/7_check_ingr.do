*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif_cine=ht11-ht11_css_sindef

compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 


/*------------------------------------------------------------------------------
 
. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                  5         -3354    -1125.317    -46.5835
                       ----------
jointly defined                 5         -3354    -1125.317    -46.5835
                       ----------
total                           5

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort -dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 
cap drop pt3h

sort bc_correlat bc_nper
