Xksoap
======

# Xksoap wiki
Xksoap es una librería para facilitar el consumo de servicios SOAP en Android utilizando la librería Ksoap2, éste proyecto busca reducir el tiempo de codificación necesario para poder consumir este tipos de servicios, está escrito en Xtend debido a las grandes ventajas que ofrece este lenguaje, entre otras su capacidad de generar código java, así como anotaciones activas; con esto queremos que los desarrolladores no tengan que perder tiempo sobrescribiendo métodos que al final son solo código espagueti, la librería permitirá con una anotación hacer que cualquier bean sea serializable para la librería Ksoap, incluyendo _tipos primitivos, listas y objetos definidos_, también se tendrá una anotación en la cual al definir ciertos parámetros generara el código necesario para consumir el servicio, enviando los parámetros definidos por el desarrollador y a su vez llevando a cabo los “casting” necesarios para obtener la respuesta del servicio, sin tener que escribir algún “Marshall” para esto, estas anotaciones satisfarán de manera inicial las configuraciones más generales de la librería Ksoap2 y a su vez permitirán al desarrollador tener libertad de poder extender o definir sus propios comportamientos.

# Contribución
1. Fork del proyecto.Haga una copia reemplazando su nombre de usuario.

   `git clone git://github.com/<NOMBRE_DE_USUARIO>/Xksoap.git`

1. Hacer instalación en limpio de Maven

   `mvn clean install`

1. Push de los cambios a su fork/branch

   `git push origin Xkasoapfeature`

1. Hacer un Pull Request

   Haga un pull request en Github para su contribución.

# Requerimientos

   maven 3

# Licencia

MIT License
[opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)