Verificación externa
==============

En este documento describimos los pasos para poder verificar los datos extraídos de los indultos contra los datos ofrecidos por el propio BOE dentro de su buscador. Esta es una tarea que se encuentra incluida dentro de la metodología de la aplicación web de [elindultometro][]

Este proceso es un paso de la metodología para la creación del repositorio de indultos para ver el proceso completo debe acceder a [este][] documento

[este]: ./UPDATE.md
[elindultometro]: http://elindultometro.es

***

## Ruby process

### Extraer resultados de la búsqueda en el BOE

Ejecutar la tarea rake encargada de extraer los resultados de la búsqueda de la web del BOE

    rake crosscheck:pardons[<year>]

_Nota_: El script escribe los resultados en el fichero `crosscheck/crosscheck<year>.csv`

***

## Hoja de cálculo

### Comparación de resultados

Utilizando una hoja de cálculo importamos el fichero `crosscheck/crosscheck<year>.csv` y lo cruzamos _(VLOOKUP)_ con los indultos que hemos detectado para ese año en nuestro proceso completo de parsing. 
  
Si encontramos diferencias tanto en un sentido como en el otro, debemos utilizar los enlaces al propio boe para tratar de detectar la causa. Si procede podremos realizar un proceso manual para la incorporación de los indultos no detectados o podemos constatar por el contrario no se trata de indultos _per\_se_ sino de disposiciones que simplemente mencionan la palabra indulto.
  