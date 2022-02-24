# TODO.md

## Icebox

- Unificar procesamiento de ingresos por rubros
- Unificar criterios de clasificación de trabajadores en todos los do-files
- `lib/vardef_y_ht11_sss.do`: Falta aprolijar y simplificar el proceso
- `lib/vardef_extras_iecon.do`: Revisar hasta cuando para atrás no se puede asignar el monto TUS
- Salud
	- Confirmar a quién hay que agregarle las cuotas de ASSE –– ¿importa que se por dentro o por fuera de FONASA? Antes de 2012 no se puede ver si es por fuera de FONASA. 
	- Antes de 2012 había otra modalidad para acceder a IAMC y Privado: 4 = caja de auxilio. ¿Cómo la contemplo?
- CIIU rev 4 Militar: ¿qué hacer con 5222, 5223, 8030? Aparecen intermitentemente en los do-files anteriores
- AFAM Contributivas
	- Antes de 2011 no se consideraban para los ingresos del núcleo la remuneración de independientes ni jubilaciones y pensiones. –– ¿Esto es a propósito?
- Imputación de cuotas mutuales pagas por empleador
	- ¿Por qué no imputarlas a dependientes públicos en ocupación secundaria?

## Next

- `bc_seguro`: Siempre da 0 porque la variable que se utiliza para crearla no existe la mayoría de los añós.
- `bc_pa*`: ¿Qué hacemos con ingresos agropecuarios cuando ya no se relevan? ¿No habríamos de ponerlos como faltantes en el año en lugar de como 0? Para ser consistentes en la nomenclatura.
- `bc_pf41_os`: Crear dos variables: catocup en op y catocup en os
- TRANSFERENCIAS ALIMENTICIAS. ¿Por qué cuento TUS en yalim_tot cuando se releva individualmente (2015 en adelante) pero no cuando se releva a nivel de hogar?
- Fix: En 2018 estaban mal los montos de AFAM-PE
- CCZ: Revisar que se mantenga constante el diagramado!! En 2012 aparecen dos marcos: ccz10 (2010) y ccz04 (2004). ¿Cuál se usa en la compatibilización?? Asumo que el de 2010...

## In process

- Refactor to separate specs by year