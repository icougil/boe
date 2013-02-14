Agregar nuevos indultos
==============

En este documento describimos los pasos a realizar para poder extraer los nuevos indultos que se vayan incorporando en el BOE de cara a su incorporación posterior en la base de datos de [elindultometro][]

[elindultometro]: http://elindultometro.es

***

## Ruby process

### Descargar disposiciones BOE

Ejecutar la tarea rake encargada de descargar las disposiciones *BOE-A* de la web del BOE, este proceso puede tardar unos minutos dependiendo de la frecuencia con la que generemos la actualización.

    rake fetch:pardons[<year>]
 
### Parsear los indultos

Ejecutar la tarea *rake* encargada de recorrer las disposiciones descargadas, detectar y parsear los indultos encontrados.
 
    rake parse:pardons[<year>,<path>]
 
*Nota: El script informa por consola del número de indultos encontrados y si ha encontrado alguno que haya que depurar*
 
***

### Verificación interna

En caso de haber encontrado indultos que depurar debemos revisar el fichero "*output/IndultosDebug<year>.csv*".

Allí tendremos una fila por cada indulto que no ha sido parseado correctamente por el *parser*. Con la ayuda del fichero
de logs "*logs/parse_pardons<year>.log*" donde se guarda el texto de los indultos a depurar rellenaremos manualmente la información de los
indultos incompletos.

Una vez completado el proceso de depuración, añadimos los indultos (*Sin cabecera*) corregidos al fichero de salida del parser 
"*output/Indultos<year>.csv*".
  
*Nota: Este proceso de verificación puede hacerse en un editor de texto o en una hoja de cálculo tipo Excel*

***

### Verificación externa

La verificación externa es un proceso *adicional* que describimos en [este][] documento, ya que no tiene porqué ejecutarse con la misma periodicidad, de hecho creemos que un repaso anual es suficiente en este caso.

[este]: ./CROSSCHECK.md

***

## Google Refine (GR)

### Carga de proyectos auxiliares en GR

Si es **la primera vez** que ejecutamos este proceso, debemos importar dos proyectos auxiliares dentro de nuestro **GR**:

- CCAA_id: Proyecto para convertir nombres de CCAA's a sus respectivos códigos según la clasificación del INE.
- Match\_Crime\_Categories: Proyecto que incluye el listado de delito clasificados en sus respectivas categorías.

Para ello utilizamos la opción de *Import Project* de **GR**:

- Seleccionamos el fichero _refine/CCAA\_id.google-refine.tag.gz_ e importamos el proyecto.
- Seleccionamos el fichero _refine/Match\_Crime\_Categories.google-refine.tar.gz_ e importamos el proyecto.

*Nota*: es importante no cambiar el nombre en la importación, i.e., dejar el campo `Re-name project` en blanco.

### Carga inicial en GR

Creamos un nuevo proyecto en **GR** importando el fichero final *output/Indultos<year>.csv*. Se debe tener en cuenta:

- La codificación del texto: Los originales están en UTF-8 pero si hemos usado una hoja de cálculo para la verificación interna
  debemos tenerlo en cuenta ya que ha podido cambiar el formato del csv (tanto en codificación como en el delimitador)
- **Desmarcar `Parse cell text into numbers, dates, ...` ** en las opciones de importación de **GR**. Así no transformará automáticamente los tipos de dato. 
- Para seguir una nomenclatura concreta recomendamos utilizar el siguiente nombre de proyecto `<Fecha>\_pardons` donde <Fecha> es el día en el que se realiza este proceso de actualización. Por ejemplo: `20130213\_pardons`

### Transformación inicial en GR

Copiamos el contenido del *json* incluido en *refine/initialPardonsTransform.json*, en **GR** vamos a `Undo/Redo <span>&rarr;</span> Apply` y lo pegamos en la ventana emergente y aceptamos.

### Exportar proyecto GR y reimportarlo con otro nombre

Necesitaremos dos proyectos **GR** de cara a generar los dos ficheros de datos necesarios para el indultómetro, esto es debido a la relación *1:n* que existe entre los indultos y sus respectivos delitos.

Para ello lo más sencillo es exportar el proyecto actual de **GR** y reimportarlo cambiándole el nombre por `<Fecha>\_pardon\_crime\_categories`. Por ejemplo: `20130212\_pardon\_crime\_categories`

### Transformación final indultos en GR

Abrimos el proyecto original `<Fecha>\_pardons`

Copiamos el contenido del *json* incluido en "*refine/finalPardonsTransform.json*", en **GR** vamos a (*Undo/Redo -> Apply*) y lo pegamos en la ventana emergente y aceptamos.

Exportamos los datos en formato csv (comma separated value)

### Transformación final delitos\_categorías en GR

Abrimos el segundo proyecto "*<Fecha>\_pardon\_crime\_categories*"

Verificamos y retocamos si es necesario la transformación inicial de la lista de crímenes. Se debe tener en cuenta:

- La lista de los posibles delitos que tienen asignada una categoría está en el proyecto **GR** *Match\_Crime\_Categories*
- Necesitamos quedarnos con la relación de los delitos tal y como figuran en *Match\_Crime\_Categories* separados por "|".
- Para ello debemos eliminar calificativos como agravado, continuado, en grado de tentativa, etc.
- Cuando se trata de un concurso de delitos debemos separar los delitos en dos independientes.

Copiamos el contenido del *json* incluido en "*refine/finalPardonCrimeCatTransform.json*", en **GR** vamos a (*Undo/Redo -> Apply*) y lo pegamos en la ventana emergente y aceptamos.

Verificamos que se han generado correctamente las categorías, si vemos que falta alguna debemos retocar el crimen hasta que el *Matching*
 se ejecute correctamente para los delitos que no hayan sido clasificados.
 
Exportamos los datos en formato csv (comma separated value)

*Nota: En la versión actual de **GR** el proceso de matching se cachea y debemos cerrar y abrir refine antes de relanzar el cruce de nuevo*

***

## Conclusión

Una vez hemos exportado los dos ficheros CSV debemos incorporarlos a la base de datos del indultómetro para ello seguiremos las instrucciones de este otro [documento][]

[documento]: http://github.com/dcabo/indultometro/blob/master/UPDATE.md


