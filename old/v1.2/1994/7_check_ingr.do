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
ht11<ht11_cs~f                  2      -666.667     -357.917   -49.16699
ht11>ht11_cs~f                472      29.99976     1164.269       31500
                       ----------
jointly defined               474      -666.667     1157.846       31500
                       ----------
total                         474

bys bc_correlat: egen pt3h=sum(pt3)

. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 & abs(dif_cine-pt3h)>2

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                  2      -666.667     -357.917   -49.16699
ht11>ht11_cs~f                358      29.99976     572.0866       11500
                       ----------
jointly defined               360      -666.667     566.9199       11500
                       ----------
total                         360


------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort -dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 
cap drop pt3h

sort bc_correlat bc_nper
