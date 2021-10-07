*-------------------------------------------------------------------------------
*- Ingresos por Jubilaciones, pensiones, becas, contribuciones

clear all
set more off

*- 1. Jubilaciones, pensiones, etc.

foreach num of numlist  81/99 0/17  {
use "C:\Users\hrueda\Documents\Compat\Ingresos\ing`num'.dta", clear
foreach var in bc_pg91 bc_pg92 bc_pg911 bc_pg912 bc_pg921 bc_pg922 bc_pg101 bc_pg102 bc_pg111 bc_pg112 {
gen `var'_d=0
replace `var'_d=`var'*bc_ipc
}
matrix A`num'= J(1,10,0)

sum bc_pg91_d [aw=bc_pesoan] if bc_pg91_d !=0 & bc_pg91_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,1]=a

sum bc_pg92_d [aw=bc_pesoan] if bc_pg92_d !=0 & bc_pg92_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,2]=a

sum bc_pg911_d [aw=bc_pesoan] if bc_pg911_d !=0 & bc_pg911_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,3]=a

sum bc_pg912_d [aw=bc_pesoan] if bc_pg912_d !=0 & bc_pg912_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,4]=a

sum bc_pg921_d [aw=bc_pesoan] if bc_pg921_d !=0 & bc_pg921_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,5]=a

sum bc_pg922_d [aw=bc_pesoan] if bc_pg922_d !=0 & bc_pg922_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,6]=a

sum bc_pg101_d [aw=bc_pesoan] if bc_pg101_d !=0 & bc_pg101_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,7]=a

sum bc_pg102_d [aw=bc_pesoan] if bc_pg102_d !=0 & bc_pg102_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,8]=a

sum bc_pg111_d [aw=bc_pesoan] if bc_pg111_d !=0 & bc_pg111_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,9]=a

sum bc_pg112_d [aw=bc_pesoan] if bc_pg112_d !=0 & bc_pg112_d !=. & bc_filtloc==1
scalar a=r(mean)
matrix A`num'[1,10]=a

}


mat A= A81
foreach i of numlist 82/99 0/17 {
mat A= A\A`i'
} 

mat def anio=J(37,1,.)

forvalues i=1/37 {
mat anio[`i',1]=`i'+1980
}

mat A= anio, A
mat list A, format (%9,0fc)


foreach j in  A {
svmat `j'
}

