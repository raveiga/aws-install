#!/usr/bin/env bash
#
# Version: 1.0
# Script programado por Rafa Veiga.
# Curso DAW2 - DWCS. 2020-2021.
# Script específico para máquina Debian-buster alfons con la imagen Community AMI en EC2 de Amazon.
#
# La máquina en Amazon EC2 se crea en 1 minuto.
# Con este script se instala y configura en 5 minutos 20 segundos de reloj.
#
# Modo de uso:
# Desde la home de nuestra máquina Debian en Amazon EC2 con el usuario admin: /home/admin, ejecutar el siguiente comando:
#
# wget https://raw.githubusercontent.com/raveiga/aws-install/main/aws_instalacion.sh -O aws_instalacion.sh && sudo bash aws_instalacion.sh
#

# Variables globales del Script.
versionPHP=7.4

clear
echo =========================================================================================================================
echo -e "\n     SCRIPT DE INSTALACION DE LEMP (Linux Nginx Mysql PHP) EN SERVIDOR AMAZON AWS CON DEBIAN"
echo -e "\n     Se instalarán NGINX, MariaDB, PHP $versionPHP, PHPMyadmin y los dominios virtuales que desee."
echo -e "\n     Más información en:"
echo -e "\n     https://manuais.iessanclemente.net/index.php?title=Servidor_Virtual_VPS_con_Amazon_EC2_-_Debian_-_AWS_Educate_-_Instalaci%C3%B3n_r%C3%A1pida_y_recomendada"
echo
echo -e "\n     Programación: Rafa Veiga. - Curso de DAW2 Ordinario - IES San Clemente. 2020-2021\n"
echo -e "     Licencia: CC-BY-SA Creative Commons.\n"
echo =========================================================================================================================
echo -e "\n"
read -rsp $'Pulse [ENTER] para continuar o [CTRL+C] para detener la instalación ...\n'

# Configuramos nuestro entorno para la próxima vez que iniciemos sesión, colores y descomentamos los alias de comando ll, la y l
sudo sed 's/#export GCC_COLORS/export GCC_COLORS/g' -i .bashrc
sudo sed "s/#alias ll='ls -l'/alias ll='ls -al'"/g -i .bashrc

# Instalamos lsb_release
sudo apt install lsb-release

# Añadimos los backports al sources.list
sudo echo -e "deb http://ftp.debian.org/debian $(lsb_release -c -s)-backports main" >> /etc/apt/sources.list
sudo echo -e "deb-src http://ftp.debian.org/debian $(lsb_release -c -s)-backports main" >> /etc/apt/sources.list

# Este script es para la instalacion de LEMP en un servidor de Debian Buster recien instalado.
# Actualizamos repositorio
echo -e "\nInstalando y actualizando paquetes...\n\n"
sudo apt update -y

# Actualizamos paquetes y distribución
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y

# Ajustamos la fecha y hora correcta de nuestro sistema
sudo dpkg-reconfigure tzdata

# Reconfiguramos locales
sudo dpkg-reconfigure locales

# Instalamos los paquetes más comunes
sudo apt install zip unzip htop -y

# Instalamos Git
sudo apt install git -y

# Si tenemos una instalación previa de Apache2 la desinstalamos.
sudo service apache2 stop
sudo systemctl disable --now apache2
sudo update-rc.d -f apache2 remove
sudo apt remove apache2 --purge

# Instalamos PHP-FPM stack en la version indicada por versionPHP al principio del script.
sudo apt install lsb-release apt-transport-https ca-certificates -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# Instalamos PHP FPM
sudo apt install php$versionPHP-fpm -y

# Instalamos los paquetes adicionales de PHP
sudo apt install php$versionPHP-{mysql,gmp,curl,intl,mbstring,xmlrpc,gd,xml,cli,zip,bz2} -y

# Configuramos PHP para que muestre los errores por pantalla.
sudo sed 's/display_errors = Off/display_errors = On/g' -i /etc/php/$versionPHP/fpm/php.ini

# Configuramos PHP para ajustar la latitud, longitud, y Zenit correctamente a las coordenadas del IES San Clemente.
sudo sed 's/;date.timezone =/date.timezone = "Europe\/Madrid"/g' -i /etc/php/$versionPHP/fpm/php.ini
sudo sed 's/;date.default_latitude = 31.7667/date.default_latitude = 42.8786939968523/g' -i /etc/php/$versionPHP/fpm/php.ini
sudo sed 's/;date.default_longitude = 35.2333/date.default_longitude = -8.547323048114777/g' -i /etc/php/$versionPHP/fpm/php.ini
sudo sed 's/;date.sunrise_zenith = 90.583333/date.sunrise_zenith = 90.70/g' -i /etc/php/$versionPHP/fpm/php.ini
sudo sed 's/;date.sunset_zenith = 90.583333/date.sunset_zenith = 90.70/g' -i /etc/php/$versionPHP/fpm/php.ini
sudo sed 's/upload_max_filesize = 2M/upload_max_filesize = 25M/g' -i /etc/php/$versionPHP/fpm/php.ini

# Instalamos Composer
sudo curl -sS https://getcomposer.org/installer | php

# Lo movemos a /usr/local/bin para que esté disponible desde cualquier directorio.
sudo mv composer.phar /usr/local/bin/composer

# Instalamos NodeJS y npm
sudo curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install nodejs -y

# Una vez instalado borramos el fichero nodesource_setup.sh
sudo rm nodesource_setup.sh

# Instalamos MariaDB
sudo apt install mariadb-server mariadb-client -y

# Securizando MariaDB
clear
echo
echo ==============================================================
echo -e "\nMariaDB/MySQL ya está instalado. Vamos a securizarlo"
echo Asegúrese de poner una contraseña del root de MySQL
echo -e "\nDónde pone current password for root, teclear ENTER."
echo -e "Introducir a continuación la contraseña deseada\n"
echo ==============================================================
echo
sudo mysql_secure_installation

# Instalamos Nginx
sudo apt install nginx apache2-utils -y

# Activamos server_tokens off en /etc/nginx/nginx.conf
sudo sed 's/# server_tokens off;/server_tokens off;/g' -i /etc/nginx/nginx.conf

# Insertamos el tamaño de archivos a 25M debajo de server_tokens off
sudo sed "/server_tokens off;/a \\\tclient_max_body_size 25M;" -i /etc/nginx/nginx.conf

# Ponemos permisos a admin:www-data a la carpeta /var/www
sudo chown admin:www-data /var/www -R

# Instalamos certbot para Nginx
sudo apt install certbot python3-certbot-nginx -y

# Creamos los dominios Virtuales
clear
echo
echo ===========================================================
echo -e "\n    Vamos a crear DOMINIOS Virtuales en NGINX\n"
echo ===========================================================
echo
echo
while read -n1 -r -p "Quieres crear o añadir otro dominio virtual a Nginx [s]|[n]?" && [[ $REPLY != n ]]; do
  case $REPLY in
    s)
echo -e "\n\nIntroduce el nombre del dominio que quieres crear en Nginx. Ejemplo: laravel.freeddns.org"
read dominio

if [ -z "$dominio" ]
then
      echo "ERROR: el nombre de $dominio no puede estar vacío."
else

# Creamos las carpetas correspondientes al nuevo dominio
sudo mkdir -p /var/www/$dominio/public
echo -e "Si usted desea configurar el dominio $dominio para su uso con LARAVEL"
echo -e "Tiene que editar editar el fichero  /etc/nginx/sites-available/$dominio y descomentar/comentar las líneas indicadas."
echo -e "\n"
echo -e "\n\nAñadimos el siguiente contenido de ejemplo, a la página index.php del dominio: \"$dominio\"."
echo -e "<?php\necho \"<center><h2>Dominio funcionando correctamente<br/><br/> $dominio</h2></center>\";" | sudo tee /var/www/$dominio/public/index.php
sudo chown admin:www-data /var/www/$dominio -R
echo -e "\n---- Añadimos la siguiente configuración para el dominio virtual \"$dominio\"\n"
echo "server {" | sudo tee /etc/nginx/sites-available/$dominio
echo -e "\tlisten 80;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\tlisten [::]:80;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\troot /var/www/$dominio/public;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tserver_name $dominio;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tindex index.php index.html index.htm index.nginx-debian.html;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tadd_header X-Frame-Options \"SAMEORIGIN\";" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\tadd_header X-XSS-Protection \"1; mode=block\";" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\tadd_header X-Content-Type-Options \"nosniff\";" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tfastcgi_hide_header 'X-Powered-By';" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tlocation / {" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\ttry_files \$uri \$uri/ =404;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\t# Para el dominio de LARAVEL COMENTAR LA LINEA ANTERIOR Y DESCOMENTAR LA SIGUIENTE LINEA:" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\t# try_files \$uri \$uri/ /index.php?\$query_string;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t}" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\t# Para el dominio de LARAVEL DESCOMENTAR LA SIGUIENTE LINEA:" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t#error_page 404 /index.php;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\tlocation ~ \\.php\$ {" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\tfastcgi_pass unix:/var/run/php/php$versionPHP-fpm.sock;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\tfastcgi_index index.php;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\t#Para una instalación normal que no sea de LARAVEL descomentar la siguiente línea:" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\t#fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\t\t#Para LARAVEL descomentar la siguiente línea y comentar la línea anterior:" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t\tfastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\n\t\tinclude fastcgi_params;" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "\t}" | sudo tee -a /etc/nginx/sites-available/$dominio
echo -e "}" | sudo tee -a /etc/nginx/sites-available/$dominio

# Agregamos la configuracion a sites-enabled
sudo ln -s /etc/nginx/sites-available/$dominio /etc/nginx/sites-enabled/$dominio
echo -e "\n";
fi

;;
esac
done

# Reiniciamos el servidor NGINX para que lea los nuevos dominios virtuales.
sudo service nginx restart
clear

# Vamos a generar los certificados SSL con LetsEncrypt
# Ésto ya no hace falta, por eso lo comento, por que ya lo incluye LetsEncrypt.
# Generamos grupo Diffie-Hellman para dar más seguridad a los certificados.
#clear
#echo -e "\nGenerando grupo Diffie-Hellman para dar más seguridad en HTTPS..."
#echo -e "\n"
#sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 1024

# Ahora vamos a configurar los certificados para los dominios creados.
# Pero antes de nada hay que revisar que tengamos en dynu.com bien puestas las direcciones IP.

clear
echo -e "\n\n"
echo =================================================================================================
echo -e "\n                                      !! IMPORTANTE !! "
echo -e "             1.-   Antes de continuar tienes que comprobar en tu máquina de Amazon "
echo -e " que tienes permitido en los grupos de seguridad el acceso por HTTP y HTTPS a tu servidor."
echo
echo -e "2.- Comprueba en DYNU.com ( https://www.dynu.com/ ) la dirección IPV4 de tus dominios creados"
echo -e "              para que apunten a la dirección IP pública de este servidor que es:"
curl ifconfig.me
echo -e "\n"
echo =================================================================================================
echo -e "\n"
read -p "Presione [Enter] cuando hayas terminado de revisar tus dominios en DYNU.COM"
echo -e "\n\n"
echo ====================================================
echo -e "\nVamos a generar los Certificados SSL con LetsEncrypt...\n"
echo -e "Responda a las siguientes preguntas de CERTBOT:\n"
echo ====================================================
echo -e "\n"

sudo certbot

# Ahora vamos a instalar phpmyadmin en el servidor que nos solicite:
clear
echo -e "\n\n"
echo =========================================================================================================
echo -e "\n                                   Instalación de PHPMyAdmin"
echo -e "\n                  NO MARCAR ni Apache2 ni Lighttpd y PULSAR en OK directamente."
echo -e "\n              Aceptar YES en \"Configure database for phpmyadmin with dbconfig-common\".\n"
echo -e "\n                       Poner una contraseña para el usuario phpmyadmin.\n"
echo -e "\n     Para administrar el mysql desde phpmyadmin nos conectaremos con el usuario phpmyadmin.\n"
echo =========================================================================================================
echo
read -rsp $'Pulse [ENTER] para continuar.\n'

sudo apt -t buster-backports install php-twig -y
sudo apt install phpmyadmin -y

# Arreglamos el problema con el PHPMyAdmin y MariaDB
echo -e "use mysql;\n" | sudo tee fix.sql
echo -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;\n" | sudo tee -a fix.sql
echo -e "FLUSH PRIVILEGES;\n" | sudo tee -a fix.sql
echo -e "exit\n" | sudo tee -a fix.sql
sudo mysql -u root < fix.sql
sudo rm fix.sql

# Reiniciamos el MySQL.
echo -e "\nReiniciando MariaDB...\n"
sudo service mysql restart
clear

echo -e "\n\n\n=========================================================================\n"
echo -e "Vamos a proteger la instalación de PHPMyAdmin accesible desde la URL /dbgestion"
echo -e "Escribe a continuación la contraseña para la autenticación con usuario \"admin\".\n\nPulsa [Enter] para NO proteger la instalación de PHPMyAdmin."
echo -e "\n=========================================================================\n"
# Con read -s se oculta el texto que se escribe, con -r se muestra.
read -r autenticacion

if [ -z "$autenticacion" ]
then
      echo "Vale, no protegeremos el directorio /dbgestion."
else
    # Creamos el directorio de contraseñas en /etc/nginx/passwd para el usuario admin
    echo $autenticacion | sudo htpasswd -i -c /etc/nginx/passwd admin
    echo -e "\nHemos creado el fichero /etc/nginx/passwd para el usuario admin y contraseña $autenticacion"

    # Pedimos el dominio para hacer el enlace simbólico
    echo -e "\n¿En qué dominio quiere instalar el acceso a /dbgestion? Pulse [0] para no instalar el enlace simbólico a PHPMyAdmin: \n"
    cd /var/www
    select d in */;

    do
        test -n "$d" && break
        echo De acuerdo, no hacemos el enlace simbólico /dbgestion a PHPMYadmin
        d="x"
        break
    done

    if [ "$d" != "x" ]
    then
        d=${d::-1}

        echo -e "\nBorrando enlace simbólico antiguo por si acaso existiera... Si da fallo cannot remove es que no existía."
        sudo rm /var/www/$d/public/dbgestion
        echo -e "\n\nSe ha creado correctamente el acceso directo a PHPMyadmin en el dominio: $d"
        sudo ln -s /usr/share/phpmyadmin /var/www/$d/public/dbgestion

        echo -e "\n\tlocation /dbgestion {\n\t\tauth_basic \"Acceso Admin\";\n\t\tauth_basic_user_file /etc/nginx/passwd;\n\t}" | sudo tee temp.txt
        sudo sed "/\error_page 404 \/index.php;/ r temp.txt" -i /etc/nginx/sites-available/$d
        sudo rm temp.txt
		sudo service nginx restart
    fi
fi

#Eliminamos el fichero de instalacion:
sudo rm aws_instalacion.sh

clear
echo -e "\n\n========================================================================================================================"
echo -e "\n                                      INSTALACIÓN Y CONFIGURACIÓN REALIZADA CON ÉXITO "
echo -e "\n\n               Para que funcione correctamente LARAVEL tienes que revisar la configuración de los dominios"
echo -e "\n   Revisa y edita las configuraciones de tus dominios de LARAVEL con \"sudo nano /etc/nginx/sites-available/xxxxxx...\""
echo -e "\n                  Una vez hechos los cambios en el fichero, REINICIA NGINX con \"sudo service nginx restart\""
echo -e "\n\n                         Y ya puedes probar a conectarte con tu navegador a tus dominios virtuales."
echo -e "\n\n                         Para la url \"/dbgestion\" el usuario es \"admin\" y la contraseña que hayas puesto."
echo -e "\n\n                     Para entrar en \"phpmyadmin\" el usuaro es \"phpmyadmin\" y la contraseña que hayas puesto."
echo -e "\n\n                                                  ! GRACIAS !"
echo -e "\n\n                                             Rafa Veiga 2020-2021"
echo -e "\n========================================================================================================================\n\n\n"
