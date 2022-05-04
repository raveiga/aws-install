## Instalación de LEMP (Linux Nginx Mysql y PHPMyadmin) en máquina Debian.

Este script **actualiza los paquetes del sistema** e instala los siguientes **paquetes nuevos**:
* Nginx
* PHP 7.4
* MariaDB
* Securiza la instalación de MariaDB
* PHPMyadmin (configura acceso con el usuario PHPMyAdmin con privilegios de root)
* Git
* Composer
* NodeJS
* LetsEncrypt
* Configura múltiples dominios virtuales
* Crea un enlace simbólico /dbgestion en el dominio que le indiquemos.
* Protege ese directorio con autenticación por HTTP con el usuario logueado y la contraseña que le indiquemos.

# Modo de uso:

**ATENCIÓN**: es necesario tener instalado **sudo**.

Como root ejecutar:
**apt install sudo**

Como root ejecutamos:
**visudo**

Comprobamos si aparece una línea como la siguiente, dónde MiUsuario es el usuario logueado. En el caso de que no aparezca la creamos con nuestros datos:

**MiUsuario  ALL=(ALL:ALL) ALL**

Guardamos el fichero y salimos de root y volvemos a nuestro shell del usuario normal:

Desde la **shell** de nuestra máquina Debian, como usuario normal sin ser root, copiar el siguiente comando y ejecutar:

**wget --no-cache https://raw.githubusercontent.com/raveiga/aws-install/main/aws_instalacion.sh -O aws_instalacion.sh && sudo bash aws_instalacion.sh $USER**

Seguir los pasos indicados.

Saludos.
Rafa Veiga.

IES San Clemente - 2020-2022
