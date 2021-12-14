
*asiste
g bc_pe11=2 
	replace bc_pe11=1 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1) 
	replace bc_pe11=-9 if bc_pe3<3 & bc_pe3!=.

*asistió
g bc_pe12=e49
	replace bc_pe12=-9 if (e193==1|e197==1|e201==1|e212==1|e215==1|e218==1|e221==1|e224==1) 
	replace bc_pe12=-9 if bc_pe3<3 & bc_pe3!=.
*asistencia actual pco o privada
g bc_pe13=-13

*nivel
g bc_nivel=-13
g nivel_aux=-15

replace nivel_aux=0 if bc_pe11==0 & bc_pe12==0 // nunca asistió
 
replace nivel_aux=0 if ((e51_2==0 & e51_3==0) | ((e193==1 | e193==2) & e51_2==9))  

replace nivel_aux=1  if ((((e51_2>0 & e51_2<=6) | (e51_3>0 & e51_3<=6)) &  e51_4==0) | (e51_2==6 & e51_4==9))  /* //Primaria */

replace nivel_aux=2  if  ((((e51_4>0 & e51_4<=3) | (e51_5>0 & e51_5<=3) | (e51_6>0 & e51_4<=6)) & (e51_7==0 & e51_8==0 & e51_9==0 & e51_10==0)) /* // Secundaria
*/ | (e51_7!=0 & e51_7_1==3) | (e51_4==3 & e51_8==9) | (e51_5==3 & e51_8==9)) 
 
replace nivel_aux=3  if  ((e51_7>0 &  e51_7<=9 & e51_7_1<3) | (e51_7!=0 & e51_4==0 & e51_5==0 & e51_6==0) /* // UTU
*/ & e51_8==0 & e51_9==0 & e51_10==0 )

replace nivel_aux=4  if (e51_8>0 & e51_8<=5) &  e51_9==0 &  e51_10==0 &  e51_11==0  // magisterio o profesorado

replace nivel_aux=5  if ((e51_9>0 & e51_9<=9) | (e51_10>0 & e51_10<=9) | (e51_11>0 & e51_11<=9)) // universidad o similar

replace nivel_aux=0 if nivel_aux==-15 & (e51_2==9 | e51_3==9)

*años de bc_educación
g bc_edu=-15

*Primaria
replace bc_edu=0 if nivel_aux==0
replace bc_edu= e51_2 if nivel_aux==1 & ((e51_2>=e51_3 & e51_2!=9) | (e51_2>0 & e51_2!=9 & e51_3==9))
replace bc_edu= e51_3 if nivel_aux==1 & ((e51_3>e51_2 & e51_3!=9)  | (e51_3>0 & e51_3!=9 & e51_2==9))

*Secundaria
replace bc_edu=6+e51_4 if nivel_aux==2 & e51_4<=3 & e51_4>0
replace bc_edu=9+e51_5 if nivel_aux==2 & e51_4==3 & e51_5<9 & e51_5>0
replace bc_edu=9+e51_6 if nivel_aux==2 & e51_4==3 & e51_6<9 &  e51_6>0
replace bc_edu=9 if nivel_aux==2 & e51_4>0 &  e51_5==0 & e51_6==0  & e201_1==1
replace bc_edu=9 if nivel_aux==2 & e51_4==3 & e51_5==9
replace bc_edu=12 if nivel_aux==2 & e51_4==3 & e51_5==9 & e212_1==1
replace bc_edu=9 if nivel_aux==2 & e51_4==3 & e51_6==9
replace bc_edu=12 if nivel_aux==2 & e51_4==3 & e51_6==9 & e212_1==1
replace bc_edu=6 if nivel_aux==2 & e51_4==9 
replace bc_edu=9 if nivel_aux==2 & e51_4==9 & e201_1==1
replace bc_edu=9+e51_5 if bc_edu==. & nivel_aux==2  & e51_5!=0
replace bc_edu=9+e51_6 if bc_edu==. & nivel_aux==2 

* UTU actual
replace bc_edu=6+e51_7 if nivel_aux==3 & e51_7<9
replace bc_edu=6 if nivel_aux==3 & e51_7==9

*magisterio
replace bc_edu=e51_8+12 if nivel_aux==4 & e51_8<9 & e51_8>0
replace bc_edu=12 if nivel_aux==4 & e51_8==9
replace bc_edu=15 if nivel_aux==4 & e51_8==9 & e215_1==1

*Terciaria
replace bc_edu=e51_9+12 if nivel_aux==5 & e51_9<9  &  e51_9>0
replace bc_edu=e51_10+12 if nivel_aux==5 & e51_10<9  &  e51_10>0
replace bc_edu=e51_11+12+e51_9 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9>=e51_10 
replace bc_edu=e51_11+12+e51_10 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9<e51_10
replace bc_edu=12 if nivel_aux==5 & e51_9==9
replace bc_edu=12 if nivel_aux==5 & e51_10==9
replace bc_edu=15 if nivel_aux==5 & e51_9==9 & e218_1==1
replace bc_edu=16 if nivel_aux==5 & e51_10==9 & e218_1==1
replace bc_edu=12+e51_9 if nivel_aux==5 & e51_11==9  & e51_9>=e51_10
replace bc_edu=12+e51_10 if nivel_aux==5 & e51_11==9  & e51_9<e51_10 

recode bc_edu 23/38=22

*finalizó
g bc_finalizo=-13

*-------------------------------------------------------------------------------
*- Años de educación. Mejor forma de captar años para 2011-2017 
*- (No compatible para 1981-2018)
gen bc_edu_1=.

*Primaria

replace bc_edu_1=0 if nivel_aux==0

replace bc_edu_1= e51_2 if nivel_aux==1 & ((e51_2>=e51_3 & e51_2!=9) | (e51_2>0 & e51_2!=9 & e51_3==9))
replace bc_edu_1= e51_3 if nivel_aux==1 & ((e51_3>e51_2 & e51_3!=9)  | (e51_3>0 & e51_3!=9 & e51_2==9))


*Secundaria

replace bc_edu_1=6+e51_4 if nivel_aux==2 & e51_4<=3 & e51_4>0
replace bc_edu_1=9+e51_5 if nivel_aux==2 & e51_4==3 & e51_5<9 & e51_5>0
replace bc_edu_1=9+e51_6 if nivel_aux==2 & e51_4==3 & e51_6<9 &  e51_6>0
replace bc_edu_1=9 if nivel_aux==2 & e51_4>0 &  e51_5==0 & e51_6==0  & e201_1==1


replace bc_edu_1=9 if nivel_aux==2 & e51_4==3 & e51_5==9
replace bc_edu_1=12 if nivel_aux==2 & e51_4==3 & e51_5==9 & e212_1==1

replace bc_edu_1=9 if nivel_aux==2 & e51_4==3 & e51_6==9
replace bc_edu_1=12 if nivel_aux==2 & e51_4==3 & e51_6==9 & e212_1==1

replace bc_edu_1=6 if nivel_aux==2 & e51_4==9 
replace bc_edu_1=9 if nivel_aux==2 & e51_4==9 & e201_1==1

replace bc_edu_1=9+e51_5 if bc_edu_1==. & nivel_aux==2  & e51_5!=0
replace bc_edu_1=9+e51_6 if bc_edu_1==. & nivel_aux==2 

* UTU actual

replace bc_edu_1=12+e51_7 if nivel_aux==3 & e51_7_1==1 & e51_7<9  &  e51_7>0
replace bc_edu_1=9+e51_7 if nivel_aux==3 & e51_7_1==2 & e51_7<9 &  e51_7>0
replace bc_edu_1=6+e51_7 if nivel_aux==3 & e51_7_1==3 & e51_7<9 &  e51_7>0
replace bc_edu_1=e51_7 if nivel_aux==3 & e51_7_1==4 & e51_7<9 &  e51_7>0
 

replace bc_edu_1=16 if nivel_aux==3 & e51_7_1==1 & e51_7>0 & e212_1==1
replace bc_edu_1=12 if nivel_aux==3 & e51_7_1==2 & e51_7>0 & e212_1==1
replace bc_edu_1=9 if nivel_aux==3 & e51_7_1==3 & e51_7>0 & e212_1==1
replace bc_edu_1=6 if nivel_aux==3 & e51_7_1==4 & e51_7>0& e212_1==1

replace bc_edu_1=12 if nivel_aux==3 & e51_7_1==1 & e51_7==9
replace bc_edu_1=15 if nivel_aux==3 & e51_7_1==1 & e51_7==9 & e212_1==1

replace bc_edu_1=9 if nivel_aux==3 &  e51_7_1==2 & e51_7==9
replace bc_edu_1=12 if nivel_aux==3 &  e51_7_1==2 & e51_7==9 & e212_1==1

replace bc_edu_1=6 if nivel_aux==3 & e51_7_1==3 & e51_7==9
replace bc_edu_1=9 if nivel_aux==3 & e51_7_1==3 & e51_7==9 & e212_1==1

*magisterio

replace bc_edu_1=e51_8+12 if nivel_aux==4 & e51_8<9  &  e51_8>0

replace bc_edu_1=12 if nivel_aux==4 & e51_8==9
replace bc_edu_1=15 if nivel_aux==4 & e51_8==9 & e215_1==1

*Terciaria

replace bc_edu_1=e51_9+12 if nivel_aux==5 & e51_9<9  &  e51_9>0
replace bc_edu_1=e51_10+12 if nivel_aux==5 & e51_10<9  &  e51_10>0
replace bc_edu_1=e51_11+12+e51_9 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9>=e51_10 
replace bc_edu_1=e51_11+12+e51_10 if nivel_aux==5 & e51_11<9 & e51_11>0 & e51_9<e51_10

replace bc_edu_1=12 if nivel_aux==5 & e51_9==9
replace bc_edu_1=12 if nivel_aux==5 & e51_10==9

replace bc_edu_1=15 if nivel_aux==5 & e51_9==9 & (e218_1==1 | e221_1==1)
replace bc_edu_1=16 if nivel_aux==5 & e51_10==9 & (e218_1==1 | e221_1==1)

replace bc_edu_1=12+e51_9 if nivel_aux==5 & e51_11==9  & e51_9>=e51_10
replace bc_edu_1=12+e51_10 if nivel_aux==5 & e51_11==9  & e51_9<e51_10 

recode bc_edu_1 23/38=22