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
* Protege ese directorio con autenticación por HTTP con el usuario admin y la contraseña que le indiquemos.

# Modo de uso:

**Atención: Es necesario tener instalado sudo en la máquina Debian: apt install sudo**

Desde la shell de nuestra máquina Debian, como usuario local sin ser root, copiar el siguiente comando y ejecutar:

**wget https://raw.githubusercontent.com/raveiga/aws-install/main/aws_instalacion.sh -O aws_instalacion.sh && sudo bash aws_instalacion.sh**

Seguir los pasos indicados.

Saludos.
Rafa Veiga.

IES San Clemente - 2020-2022
