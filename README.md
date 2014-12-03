Xksoap
======

Xksoap is a library to make easier consume SOAP web services in Android, using Ksoap2 Library. This project seeks to reduce necesary codification time to consume this type of services, is write in Xtend because this language have a lot of advantages like java code generation and active annotations. with this we hope  developers don't waste time overriding methods that they are just boiler plate at the end.
The library let with an annotation make any bean serializable for ksoap2 library, including primitive types, list and personalized objects,also it has
an annotation in which with certain parameters, this generate the needed code to consume the service by sending the parameters defined by the developer also conducting the "casting" necessary for the service response, without write a "Marshall" for this, these annotations in initially satisfy the more general settings Ksoap2 library and in turn enable the developer to have freedom to extend or define their own behaviors.


# Contribution
1. Fork project. make your own copy replacing with your username

   `git clone git://github.com/<NOMBRE_DE_USUARIO>/Xksoap.git`

1. Make a Maven clean install

   `mvn clean install`

1. Push changes to your fork/branch

   `git push origin Xkasoapfeature`

1. Make a Pull Request

   Make a pull request in Github to contribute.

# Requirements

   Maven 3
   Eclipse Luna o newer

# License

MIT License
[opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)