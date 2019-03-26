#!/usr/bin/env bash

composer install

cd web
/usr/bin/env PHP_OPTIONS="-d sendmail_path=`which true`" drush si polaris_drupal_profile --db-url=mysql://travis@127.0.0.1/polaris -y
