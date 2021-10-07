*7_ ----------------------------------------------------------------------------
g ht11_css_sindef=bc_ht11_css/bc_ipc
g dif=bc_ht11_iecon-ht11_css_sindef
g dif_cine=ht11-ht11_css_sindef
g bc_ht11_iecon2=bc_ht11_iecon
g ht112=ht11

compare bc_ht11_iecon ht11_css_sindef  if (abs(dif)>2) & bc_nper==1 
compare ht11 ht11_css_sindef  	  if (abs(dif_cine)>2) & bc_nper==1 

compare ht11 ht11_css_sindef  if (abs(dif_cine)>2) & bc_nper==1 ///
& bc_correlat!=23043 /// tiene mal sumado g121_1
& bc_correlat!=36600 & bc_correlat!=37235 & bc_correlat!=50236 & bc_correlat!=42500 & bc_correlat!=77416 /// mal g124_3
& bc_correlat!=40613 /// mal ingr x 10640 cuotmilit que debería incluir, además hay algo de ytransf_4
& bc_correlat!=31094 // mal ingr x 8512 cuota_p es la g125_2


/*------------------------------------------------------------------------------
ANTES
                                     ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_cs~ef            10     -1342.508    -506.6246   -254.8047
ht11_ie~n>ht11_cs~ef           121      254.8115     877.7705        2274
                        ----------
jointly defined                131     -1342.508     772.0915        2274
                        ----------
total                          131

AHORA

*-------------- SACANDO LAS AFAM Y CAMBIANDO NOMBRES BC_
Notas: 
bc_correlat!=23043, ine mal ingreso
bc_correlat!=50236&bc_correlat!=42500&bc_correlat!=77416, ine mal ingreso, g124_3 lo sumo
bc_correlat!=40613, está mal el ingreso por lo menos hay 10640 de cuotmilit que debería incluir, además hay algo de ytransf_4




*-------------------- DIFERENCIAS INTERNAS
. compare bc_ht11_iecon ht11_css_sindef  if (abs(dif)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
bc_ht11~n<ht11_cs~f           569     -4300.004     -581.534   -111.7598
bc_ht11~n>ht11_cs~f           220      254.8115     1276.283        5685
                       ----------
jointly defined               789     -4300.004    -63.51155        5685
                       ----------
total                         789



*-------------------- DIFERENCIAS CON INE
. compare ht11 ht11_css_sindef      if (abs(dif_cine)>2) & bc_nper==1 

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f               2837        -10000    -731.2814   -101.1192
ht11>ht11_cs~f               5763       2.00001     811.2037       28272
                       ----------
jointly defined              8600        -10000      302.363       28272
                       ----------
total                        8600

. compare ht11 ht11_css_sindef  if (abs(dif_cine)>2) & bc_nper==1 ///
> & bc_correlat!=23043 /// tiene mal sumado g121_1
> & bc_correlat!=36600 & bc_correlat!=37235 & bc_correlat!=50236 & bc_correlat!=42500 & bc_correlat!=77416 /// mal g1
> 24_3
> & bc_correlat!=40613 /// mal ingr x 10640 cuotmilit que debería incluir, además hay algo de ytransf_4
> & bc_correlat!=31094 // mal ingr x 8512 cuota_p es la g125_2

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11<ht11_cs~f               2831         -6822    -713.2452   -101.1192
ht11>ht11_cs~f               5762       2.00001     806.4378        6384
                       ----------
jointly defined              8593         -6822     305.7719        6384
                       ----------
total                        8593

------------------------------------------------------------------------------*/


*-------------------------------------------------------------------------------
* Para ver las diferencias

*gsort dif bc_correlat bc_nper
*gsort dif_cine bc_correlat bc_nper

*br if bc_correlat!=23043 & bc_correlat!=36600 & bc_correlat!=37235 & bc_correlat!=50236 & bc_correlat!=42500 & bc_correlat!=77416 & bc_correlat!=40613 & bc_correlat!=31094 

*drop variables generadas para chequeo
drop ht11_css_sindef dif dif_cine bc_ht11_iecon2 ht112

sort bc_correlat bc_nper
