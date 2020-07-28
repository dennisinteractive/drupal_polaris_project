help:
	$(info *********************************************************************************** )
	$(info                      Polaris CMS: List of commands                                  )
	$(info *********************************************************************************** )
	$(info make site-create             - Used to build and install the site for the first time)
	$(info make build-vm                - Used to build the site on local VM                   )
	$(info make build-ci                - Used to build the site on CI                         )
	$(info make build-qa                - Used to build the site on QA                         )
	$(info make site-install            - Used to install the site from scratch                )
	$(info make db-import               - Imports DB backups, imports config and runs updates  )
	$(info make site-update             - Imports config and runs updates                      )
	$(info make aws-credentials         - Checks and creates AWS credentials                   )
	$(info make update-aws-credentials: - Update-aws-credentials AWS credentials               )
	$(info *********************************************************************************** )

site-create:
	cp .env.vm .env
	echo "MYSQL_DATABASE=$(shell basename $(shell pwd))" >> .env
	mkdir -p private && chmod -R 644 private
	composer install
	drush -y sql-create
	drush si polaris -y
	drush cex -y
	drush php-eval 'node_access_rebuild();'
	git init
	git status
	echo "Site created and installed, now it's time to commit your files"

build-vm:
	cp .env.vm .env
	echo "MEMCACHE_PREFIX=$(shell basename $(shell pwd))" >> .env
	make restart-memcache
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
	make uli

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

restart-memcache:
	# Restart memcache
	sudo service memcached stop
	sudo service memcached start

uli:
	drush uli --uri=http://$(shell basename $(shell pwd)).vm.cms.didev.co.uk

# This database needs to be copied from S3
db-import:
	drush sql-create -y
	gunzip -c sql/database.sql.gz | drush sqlc
	make site-update

site-install:
	drush site:install -y

site-update:
	drush cr
	drush cim -y
	drush updb -y
	drush cex -y
	drush cr

run-tests:
	cd tests && ./behat
	./vendor/bin/phpunit

aws-credentials:
	aws-check-credentials create

update-aws-credentials:
	aws-check-credentials update
