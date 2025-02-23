#!/bin/bash

# Actualizar paquetes del sistema
sudo yum update -y
sudo yum upgrade -y

# Instalar dependencias necesarias
sudo yum install -y httpd php php-pgsql php-curl php-json php-mbstring php-xml php-zip unzip git postgresql15.x86_64
sudo yum install -y httpd php php-pgsql php-mbstring php-xml php-json php-gd php-pear php-devel php-mysqli unzip nfs-utils amazon-efs-utils gcc-c++

# Configurar PHP para permitir almacenamiento de archivos grandes (ajustar según tus necesidades)
sudo echo "upload_max_filesize = 64M" | sudo tee -a /etc/php.ini
sudo echo "post_max_size = 64M" | sudo tee -a /etc/php.ini
sudo echo "max_execution_time = 300" | sudo tee -a /etc/php.ini

# Descargar Joomla
cd /var/www/html
sudo wget https://downloads.joomla.org/cms/joomla5/5-2-4/Joomla_5.2.4-Stable-Full_Package.zip
sudo unzip Joomla_5.2.4-Stable-Full_Package.zip
sudo rm -f Joomla_5.2.4-Stable-Full_Package.zip

# Configurar permisos de Joomla
sudo chown -R apache:apache /var/www/html
sudo chmod -R 755 /var/www/html
#rm /var/www/html/installation -rf

# Iniciar y habilitar Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Crear el directorio de montaje para EFS
sudo mkdir /mnt/efs
sudo mount -t efs ${efs_cms}:/ /mnt/efs
echo "${efs_cms}:/ /mnt/efs nfs4 defaults 0 0" | sudo tee -a /etc/fstab
sudo mount -a
sudo mkdir /mnt/efs/joomla_tmp
sudo mkdir /mnt/efs/joomla_logs
sudo mkdir /mnt/efs/joomla_cache

# Crear tablas Base de Datos Joomla
#GPASSWORD="${db_password}" psql -h ${db_host} -U ${db_username} -d ${db_name} -f /var/www/html/installation/sql/postgresql/base.sql
#GPASSWORD="${db_password}" psql -h ${db_host} -U ${db_username} -d ${db_name} -f /var/www/html/installation/sql/postgresql/extensions.sql
#GPASSWORD="${db_password}" psql -h ${db_host} -U ${db_username} -d ${db_name} -f /var/www/html/installation/sql/postgresql/supports.sql

# Crear fichero configuracion Joomla
#?php
#class JConfig {
#        public $offline = false;
#        public $offline_message = 'Este sitio no está disponible temporalmente por tareas de mantenimiento.<br />Por favor, inténtelo en otro momento.';
#        public $display_offline_message = 1;
#        public $offline_image = '';
#        public $sitename = 'JoomlaMilu';
#        public $editor = 'tinymce';
#        public $captcha = '0';
#        public $list_limit = 20;
#        public $access = 1;
#        public $debug = false;
#        public $debug_lang = false;
#        public $debug_lang_const = true;
#        public $dbtype = 'pgsql';
#        public $host = 'terraform-20250221163702222400000001.cnaei4ume8y6.eu-west-3.rds.amazonaws.com';
#        public $user = 'postgres';
#        public $password = 'admin123';
#        public $db = 'joomla_db';
#        public $dbprefix = 'rdfmt_';
#        public $dbencryption = 0;
#        public $dbsslverifyservercert = false;
#        public $dbsslkey = '';
#        public $dbsslcert = '';
#        public $dbsslca = '';
#        public $dbsslcipher = '';
#        public $force_ssl = 0;
#        public $live_site = '';
#        public $secret = 'vuW0sHTnb14XBP9Y';
#        public $gzip = false;
#        public $error_reporting = 'default';
#        public $helpurl = 'https://help.joomla.org/proxy?keyref=Help{major}{minor}:{keyref}&lang={langcode}';
#        public $offset = 'UTC';
#        public $mailonline = true;
#        public $mailer = 'mail';
#        public $mailfrom = 'emiliseto@gmail.com';
#        public $fromname = 'JoomlaMilu';
#        public $sendmail = '/usr/sbin/sendmail';
#        public $smtpauth = false;
#        public $smtpuser = '';
#        public $smtppass = '';
#        public $smtphost = 'localhost';
#        public $smtpsecure = 'none';
#        public $smtpport = 25;
#        public $caching = 0;
#        public $cache_handler = 'file';
#        public $cachetime = 15;
#        public $cache_platformprefix = false;
#        public $MetaDesc = '';
#        public $MetaAuthor = true;
#        public $MetaVersion = false;
#        public $robots = '';
#        public $sef = true;
#        public $sef_rewrite = false;
#        public $sef_suffix = false;
#        public $unicodeslugs = false;
#        public $feed_limit = 10;
#        public $feed_email = 'none';
#        public $log_path = '/var/www/html/administrator/logs';
#        public $tmp_path = '/var/www/html/tmp';
#        public $lifetime = 15;
#        public $session_handler = 'database';
#        public $shared_session = false;
#        public $session_metadata = true;
#}
#?>" > /var/www/html/configuration.php

# Instalar Composer (para gestionar dependencias de PHP)
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Instalar Redis
yes '' | sudo pecl install redis
echo "extension=redis.so" | sudo tee -a /etc/php.d/30-redis.ini
sudo dnf update
sudo dnf install -y redis6
sudo systemctl start redis6
sudo systemctl enable redis6
sudo systemctl is-enabled redis6
redis6-server --version

# Reiniciar el servidor web
sudo systemctl restart httpd

