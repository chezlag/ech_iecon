*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif_cine=ht11-ht11_css_sindef

compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 

bys bc_correlat: egen pt3h=sum(pt3)
compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 & abs(dif_cine-pt3h)>2

/*------------------------------------------------------------------------------

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                  3       -172026    -60965.66       -2631
ht11>ht11_cs~f                 58      5.498047     7264.095       41666
                       ----------
jointly defined                61       -172026     3908.533       41666
                       ----------
total                          61


. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 & abs(dif_cine-pt3h)>2

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                  3       -172026    -60965.66       -2631
ht11>ht11_cs~f                 55      5.498047     7508.009       41666
                       ----------
jointly defined                58       -172026     3966.267       41666
                       ----------
total                          58


Algunos de estos hogares con diferencias tienen sumadas las variables 
pg61p/o etc sin dividir entre 12 en el ht11 del ine

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort -dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 
cap drop pt3h

sort bc_correlat bc_nper
