g ht11_css_sindef=ht11_css/ipc
g dif_sindef=ht11_iecon-ht11_css_sindef
g ht11_iecon2=ht11_iecon
g ine_ht112=ine_ht11

compare ht11_iecon ht11_css_sindef if pe4!=7 & (abs(dif)>2) & nper==1

*-------------------------------------------------------------------------------
* Cómo se fue modificando 
/* diferencias en personas
                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_c~ef         10572        -13644    -2482.262   -254.8047
ht11_ie~n>ht11_c~ef           133      254.8115     355.4999       805.5
                       ----------
jointly defined             10705        -13644    -2447.005       805.5
                       ----------
total                       10705


cambio la forma de generar la salud del hogar, porque en ytransf_5 están las 
cuotas militares de los que no son funcionrio públicos y se duplicaban


                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_n~ef           758         -7959    -3147.353   -254.8047
ht11_ie~n>ht11_n~ef           338      254.8115     789.2288        2274
                       ----------
jointly defined              1096         -7959    -1933.334        2274
                       ----------
total                        1096


para la cuota_p y cuota_o no saco la condición de cuotmilit==0 porque queda mal

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_n~ef            35     -1342.508    -447.9415   -254.8047
ht11_ie~n>ht11_n~ef           398      254.8115     908.8651        3411
                       ----------
jointly defined               433     -1342.508     799.1925        3411
                       ----------
total                         433

reemplazo cuotmilit =0 en los casos en que va para ytransf_5, y lo cambio 
a la primera parte en el programa ingreso_2006

                                        ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_n~ef            39     -1342.508    -514.8197   -254.8047
ht11_ie~n>ht11_n~ef           366      254.8115     832.5609        2274
                       ----------
jointly defined               405     -1342.508     702.8131        2274
                       ----------
total                         405

genero disse_p, disse_s, disse en el paso cero a ver si soluciona 
los de disse son los que declaran tener disse y están en el seguro de paro


ahora son diferencias a nivel de hogar

                                      ---------- difference ----------
                            count       minimum      average     maximum
------------------------------------------------------------------------
ht11_ie~n<ht11_c~ef            10     -1342.508    -506.6246   -254.8047
ht11_ie~n>ht11_c~ef           121      254.8115     877.7705        2274
                       ----------
jointly defined               131     -1342.508     772.0915        2274
                       ----------
total                         131





*-------------------------------------------------------------------------------
*/

*-------------------------------------------------------------------------------
* Para ver las diferencias
gsort -dif correlat nper
*br if abs(dif)>2 & pe4!=7
*br correlat nper e44_2_1 e44_2_2 disse* cuotabps cuotmilit salud ht11_iecon ht11_css_sindef dif_sindef if abs(dif)>2&pe4!=7

*dropeo variables generadas para chequeo
cap drop ht11_css_sindef 
cap drop dif_sindef ine_ht112
cap drop ht11_iecond
cap drop dif_sindef2
cap drop ht11_iecon2
