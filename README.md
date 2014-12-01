Xksoap
======

# Xksoap wiki
Xksoap es una librer�a para facilitar el consumo de servicios SOAP en Android utilizando la librer�a Ksoap2, �ste proyecto busca reducir el tiempo de codificaci�n necesario para poder consumir este tipos de servicios, est� escrito en Xtend debido a las grandes ventajas que ofrece este lenguaje, entre otras su capacidad de generar c�digo java, as� como anotaciones activas; con esto queremos que los desarrolladores no tengan que perder tiempo sobrescribiendo m�todos que al final son solo c�digo espagueti, la librer�a permitir� con una anotaci�n hacer que cualquier bean sea serializable para la librer�a Ksoap, incluyendo _tipos primitivos, listas y objetos definidos_, tambi�n se tendr� una anotaci�n en la cual al definir ciertos par�metros generara el c�digo necesario para consumir el servicio, enviando los par�metros definidos por el desarrollador y a su vez llevando a cabo los �casting� necesarios para obtener la respuesta del servicio, sin tener que escribir alg�n �Marshall� para esto, estas anotaciones satisfar�n de manera inicial las configuraciones m�s generales de la librer�a Ksoap2 y a su vez permitir�n al desarrollador tener libertad de poder extender o definir sus propios comportamientos.

# Contribuci�n
1. Fork del proyecto.Haga una copia reemplazando su nombre de usuario.

   `git clone git://github.com/<NOMBRE_DE_USUARIO>/Xksoap.git`

1. Hacer instalaci�n en limpio de Maven

   `mvn clean install`

1. Push de los cambios a su fork/branch

   `git push origin Xkasoapfeature`

1. Hacer un Pull Request

   Haga un pull request en Github para su contribuci�n.

# Requerimientos

   maven 3

# Licencia

MIT License
[opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)