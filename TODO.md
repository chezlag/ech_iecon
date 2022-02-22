# TODO.md

## Icebox

- Unificar procesamiento de ingresos por rubros
- Unificar criterios de clasificación de trabajadores en todos los do-files
- `lib/vardef_y_ht11_sss.do`: Falta aprolijar y simplificar el proceso
- `lib/vardef_extras_iecon.do`: Revisar hasta cuando para atrás no se puede asignar el monto TUS

## Next

- `bc_seguro`: Siempre da 0 porque la variable que se utiliza para crearla no existe la mayoría de los añós.
- `bc_pa*`: ¿Qué hacemos con ingresos agropecuarios cuando ya no se relevan? ¿No habríamos de ponerlos como faltantes en el año en lugar de como 0? Para ser consistentes en la nomenclatura.
- `bc_pf41_os`: Crear dos variables: catocup en op y catocup en os
- TRANSFERENCIAS ALIMENTICIAS. ¿Por qué cuento TUS en yalim_tot cuando se releva individualmente (2015 en adelante) pero no cuando se releva a nivel de hogar?

## In process

- Refactor to separate specs by year