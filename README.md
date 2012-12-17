boe
===

Descargando y parseando el BOE. More information to follow...

Rake
----

Existen una tarea Rake para ejecutar el parsing de los indultos:

    $ rake -T
    rake default                   # Run tests
    rake parse:pardons[year,path]  # Extract pardons from BOE files
    rake test                      # Run tests

Los datos extraídos se redirigen a ficheros en la carpeta `output/`.
