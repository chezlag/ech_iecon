*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif_cine=ht11-ht11_css_sindef

compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 
bys bc_correlat: egen pt3h=sum(pt3)
compare ht11 ht11_css_sindef if (abs(dif_cine)>2) & bc_nper==1 & abs(pt3h-dif_cine)>2

/*------------------------------------------------------------------------------
 
. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                 34         -5000    -595.6275         -75
ht11>ht11_cs~f                490      5.000031     430.8163       12000
                       ----------
jointly defined               524         -5000      364.215       12000
                       ----------
total                         524


*Parece que el ingreso del ine tiene dos veces sumado el valor de pt3
*Si corrijo esto las diferencias quedan para 410 hogares por montos menores

bys bc_correlat: egen pt3h=sum(pt3)

. compare ht11 ht11_css_sindef if (abs(dif_cine)>2) & bc_nper==1 & abs(pt3h-dif_cine)>2

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f                 34         -5000    -595.6275         -75
ht11>ht11_cs~f                376      5.000031     215.5319        3082
                       ----------
jointly defined               410         -5000      148.265        3082
                       ----------
total                         410

------------------------------------------------------------------------------*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
*gsort -dif_cine bc_correlat bc_nper

*br bc_correlat ht11 ht11_css_sindef

*drop variables generadas para chequeo
drop ht11_css_sindef dif_cine 
cap drop pt3h

sort bc_correlat bc_nper
