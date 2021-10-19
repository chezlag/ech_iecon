// variables de identificación general

rename numero  bc_correlat
rename nper    bc_nper
rename pesoano bc_pesoan

assert inlist(bc_area, 1, 2, 3, 4)
clonevar bc_area = region_4
* localidades de más de 5000 hab.
gen    bc_filtloc = (region_4<3)
recode bc_filtloc (0=2)

// características generales y de las personas

* sexo
gen bc_pe2 = e26

* edad
gen bc_pe3 = e27

* parentesco
g bc_pe4=-9
	replace bc_pe4=1 if `pe4_jefe'
	replace bc_pe4=2 if `pe4_conyuge'
	replace bc_pe4=3 if `pe4_hije'
	replace bc_pe4=4 if `pe4_padresuegro'
	replace bc_pe4=5 if `pe4_otroparient'
	replace bc_pe4=6 if `pe4_nopariente'
	replace bc_pe4=7 if `pe4_servdom'

* estado civil

g bc_pe5=-9
	replace bc_pe5=1 if `pe5_unionlibre'
	replace bc_pe5=2 if `pe5_casado'
	replace bc_pe5=3 if `pe5_divsep'
	replace bc_pe5=4 if `pe5_viudo'
	replace bc_pe5=5 if `pe5_soltero'
