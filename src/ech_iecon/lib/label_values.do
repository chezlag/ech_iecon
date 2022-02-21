// value labels 2001–2019

cap lab drop 	bc_filtloc
cap lab drop 	bc_mes
cap lab drop 	bc_dpto
cap lab drop 	bc_ccz
cap lab drop 	bc_area
cap lab drop 	bc_pe2
cap lab drop 	bc_pe4
cap lab drop 	bc_pe5
cap lab drop 	bc_pe6a
cap lab drop 	bc_pe6b
cap lab drop 	bc_pe13
cap lab drop 	bc_nivel
cap lab drop 	bc_pobp
cap lab drop 	bc_pf41
cap lab drop 	bc_cat2
cap lab drop 	bc_pf081
cap lab drop 	bc_pf082
cap lab drop 	bc_rama
cap lab drop 	bc_tipo_ocup
cap lab drop 	bc_pf04
cap lab drop 	bc_pf22
cap lab drop 	bc_pf34
cap lab drop 	sino

lab def bc_filtloc 1 "Localidades de más de 5mil habitantes" ///
  2 "Localidades de 5mil habitantes o menos" 
lab def bc_mes 1 "Enero" ///
  2 "Febrero" ///
  3 "Marzo" ///
  4 "Abril" ///
  5 "Mayo" ///
  6 "Junio" ///
  7 "Julio" ///
  8 "Agosto" ///
  9 "Septiembre" ///
  10 "Octubre" ///
  11 "Noviembre" ///
  12 "Diciembre" 
lab def bc_dpto 1 "Montevideo" ///
  2 "Artigas" ///
  3 "Canelones" ///
  4 "Cerro Largo" ///
  5 "Colonia" ///
  6 "Durazno" ///
  7 "Flores" ///
  8 "Florida" ///
  9 "Lavalleja" ///
  10 "Maldonado" ///
  11 "Paysandú" ///
  12 "Río Negro" ///
  13 "Rivera" ///
  14 "Rocha" ///
  15 "Salto " ///
  16 "San José " ///
  17 "Soriano" ///
  18 "Tacuarembó " ///
  19 "Treinta y Tres" 
lab def bc_ccz 1 "CCZ 1" ///
  2 "CCZ 2" ///
  3 "CCZ 3" ///
  4 "CCZ 4" ///
  5 "CCZ 5" ///
  6 "CCZ 6" ///
  7 "CCZ 7" ///
  8 "CCZ 8" ///
  9 "CCZ 9" ///
  10 "CCZ 10" ///
  11 "CCZ 11" ///
  12 "CCZ 12" ///
  13 "CCZ 13" ///
  14 "CCZ 14" ///
  15 "CCZ 15" ///
  16 "CCZ 16" ///
  17 "CCZ 17" ///
  18 "CCZ 18" 
lab def bc_area 1 "Montevideo" ///
  2 "Interior >5000" ///
  3 "Interior <5000" ///
  4 "Rural disperso" 
lab def bc_pe2 1 "Varón" ///
  2 "Mujer" 
lab def bc_pe4 1 "Jefe" ///
  2 "Cónyugue" ///
  3 "Hijo" ///
  4 "Padres o suegros " ///
  5 "Otro pariente" ///
  6 "Otro no pariente" ///
  7 "Servicio doméstico" 
lab def bc_pe5 1 "Unión libre" ///
  2 "Casado" ///
  3 "Divorciado o separado" ///
  4 "Viudo" ///
  5 "Soltero" 
lab def bc_pe6a 1 "Sin atención" ///
  2 "Mutualista" ///
  3 "Disse" ///
  4 "Salud pública" ///
  5 "Otros privados" 
lab def bc_pe6b 1 "Sin atención" ///
  2 "Mutualista" ///
  3 "Salud pública" ///
  4 "Otros privados" 
lab def bc_pe13 1 "Público" ///
  2 "Privado" 
lab def bc_nivel 0 "Sin instrucción" ///
  1 "Primaria" ///
  2 "Secundaria" ///
  3 "Enseñanza técnica o UTU" ///
  4 "Magisterio o Profesorado" ///
  5 "Universidad o similar" 
lab def bc_pobp 1 "Menor de 14 años" ///
  2 "Ocupados" ///
  3 "Desocupados, busca trabajo por primera vez" ///
  4 "Desocupados" ///
  5 "Desocupados , seguro de desempleo" ///
  6 "Inactivo – tareas del hogar" ///
  7 "Inactivo – Estudiante" ///
  8 "Inactivo – Rentista" ///
  9 "Inactivo – Pensionista y Jubilado" ///
  11 "Inactivo – Otros" 
lab def bc_pf41 1 "Asalariado privado" ///
  2 "Asalariado público" ///
  3 "Cooperativista" ///
  4 "Patrón" ///
  5 "Cuenta propia s/l" ///
  6 "Cuenta propia c/l" ///
  7 "Otras actividades" 
lab def bc_cat2 1 "Asalariado privado" ///
  2 "Asalariado público" ///
  3 "Patrón" ///
  4 "Cuenta propia" ///
  5 "Otras actividades" 
lab def bc_pf081 1 "Menos de 10 personas" ///
  2 "10 personas o más" 
lab def bc_pf082 1 "Una persona" ///
  2 "Dos a cuatro personas" ///
  3 "Cinco a nueve personas" 
lab def bc_rama 1 "Agropecuaria y Minería" ///
  2 "Industria Manufactureras" ///
  3 "Electricidad, Gas y Agua" ///
  4 "Construcción" ///
  5 "Comercio, Restaurantes y Hoteles" ///
  6 "Transportes y Comunicaciones" ///
  7 "Servicios a empresas" ///
  8 "Servicios comunales, sociales y personales" 
lab def bc_tipo_ocup 0 "Fuerzas Armadas" ///
  1 "Miembro de poder ejecutivo y cuerpos legislativos y personal directivo de la administración pública y de las empresas" ///
  2 "Profesionales científicos e intelectuales" ///
  3 "Técnicos y profesionales de nivel medio" ///
  4 "Empleados de oficina" ///
  5 "Trabajadores de los servicios y vendedores de comercios y mercados" ///
  6 "Agricultores y trabajadores calificados agropecuarios y pesqueros" ///
  7 "Oficiales, operarios y artesanos de artes mecánicas y de otros oficios" ///
  8 "Operadores y montadores de instalaciones y máquinas" ///
  9 "Trabajadores no calificados" 
lab def bc_pf04 1 "Licencia" ///
  2 "Poco trabajo o mal tiempo" ///
  3 "Huelga o estar suspendido" ///
  4 "Otro motivo" 
lab def bc_pf22 1 "Volverá a trabajar en 30 días" ///
  2 "Espera resultados de gestiones" ///
  3 "Buscó antes y dejo de buscar" ///
  4 "Otros motivos" 
lab def bc_pf34 1 "Cerró el establecimiento" ///
  2 "Lo despidieron" ///
  3 "Otro motivo" 
lab def sino 1 "Si" ///
  2 "No" 
  
lab def bc_pe6a1 1 "Trabajo" 2 "Otro" 

lab val bc_filtloc bc_filtloc
lab val bc_mes bc_mes
lab val bc_dpto bc_dpto
lab val bc_ccz bc_ccz
lab val bc_area bc_area
lab val bc_pe2 bc_pe2
lab val bc_pe4 bc_pe4
lab val bc_pe5 bc_pe5
lab val bc_pe6a bc_pe6a
lab val bc_pe6b bc_pe6b
lab val bc_pe13 bc_pe13
lab val bc_nivel bc_nivel
lab val bc_pobp bc_pobp
lab val bc_pf41 bc_pf41
lab val bc_cat2 bc_cat2
lab val bc_pf081 bc_pf081
lab val bc_pf082 bc_pf082
lab val bc_rama bc_rama
lab val bc_tipo_ocup bc_tipo_ocup
lab val bc_pf04 bc_pf04
lab val bc_pf22 bc_pf22
lab val bc_pf34 bc_pf34
lab val bc_pe11 bc_pe12 bc_finalizo bc_pf21 bc_reg_disse bc_register bc_register2 bc_subocupado bc_subocupado1 sino
lab val bc_pe6a1 bc_pe6a1
