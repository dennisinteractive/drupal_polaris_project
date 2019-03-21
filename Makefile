help:
	$(info *********************************************************************************** )
	$(info                      Polaris CMS: List of commands                                  )
	$(info *********************************************************************************** )
	$(info make make build-vm           - Used to build the site on local VM                   )
	$(info make build-ci                - Used to build the site on CI                         )
	$(info make build-qa                - Used to build the site on QA                         )
	$(info make make build-vm           - Used to build the site on local VM                   )
	$(info make db-import               - Imports DB backups, imports config and runs updates  )
	$(info make site-update             - Imports config and runs updates                      )
	$(info make aws-credentials         - Checks and creates AWS credentials                   )
	$(info make update-aws-credentials: - Update-aws-credentials AWS credentials               )
	$(info *********************************************************************************** )

start:
	docker run -v "${PWD}:/var/www/polaris-cms" --rm --name drupal8 -p 8080:80 -d dennisdigital/drupalci:8-apache-interactive

ssh:
	docker exec -it drupal8 bash

build-profile:
	composer config --global --auth http-basic.repo.packagist.com dennisdigital ${PACKAGIST_TOKEN}
	composer create-project dennisdigital/polaris-drupal-project:dev-CMS-96_scaffolding /var/www/polaris-cms --stability dev --no-interaction
	make install-profile

install-profile:
	cd /var/www/polaris-cms/web && sh profiles/contrib/polaris/scripts/install.sh

test-profile:
	cd /var/www/polaris-cms/web
	sudo -u www-data php core/scripts/run-tests.sh --keep-results --color --concurrency "31" --sqlite sites/default/files/.ht.sqlite --verbose --suppress-deprecations polaris
	cd /var/www/polaris-cms && sudo -u www-data ./vendor/bin/phpunit

build-vm:
	cp .env.vm .env
	# Restart memcache
	sudo service memcached stop
	sudo service memcached start
	echo "MEMCACHE_PREFIX=$(shell basename $(shell pwd))" >> .env
	# Create .env and override db name using current directory
	echo "MYSQL_DATABASE=$(shell basename $(shell pwd))" >> .env
	# Fix directory permissions
	mkdir -p private && chmod -R 644 private
	# Run composer
	composer install
	# AWS Credentials
	make aws-credentials
	# Import db
	make db-import
	# Site login
	drush uli --uri=http://$(shell basename $(shell pwd)).vm.cms.didev.co.uk

build-ci:
	cp .env.dist .env
	mkdir -p private && chmod -R 644 private
	composer install
	make db-import
	make run-tests

build-qa:
	cp .env.dist .env
	mkdir -p private && chmod -R 644 private
	composer install
	make db-import
	make run-tests

# This database needs to be copied from S3
db-import:
	drush sql-create -y
	gunzip -c sql/database.sql.gz | drush sqlc
	make site-update

site-install:
	drush site:install -y

site-update:
	drupal config:import
	drupal update:execute
	drupal config:export
	drupal cr

run-tests:
	cd tests && ./behat
	./vendor/bin/phpunit

aws-credentials:
	aws-check-credentials create

update-aws-credentials:
	aws-check-credentials update
