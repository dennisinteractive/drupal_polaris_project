# Composer based Polaris installation

This project template should provide a kickstart for managing your site dependencies with [Composer](https://getcomposer.org/).

## Creating new sites

First you need to install [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx) and [Git](https://git-scm.com).

### Creating the project:

```
composer create-project dennisdigital/polaris-drupal-project:^2.0.0 polaris --stability dev --no-interaction
```

If you want to check out a different version of the profile or any contrib module:

```
cd polaris && composer require dennisdigital/polaris:dev-[BRANCH]
```

If you want to run the docker image locally:

```
docker run -v ./[LOCAL_FOLDER]/:/var/www/polaris --rm --name polaris -p 8080:80 -d dennisdigital/drupalci:8-apache-interactive
```
This is useful when you want to work on the project and test changes locally. You can ssh inside the container and run the same commands
as in .circleci folder.

```
docker exec -it polaris sh
```

If you want to see the site, browse http://localhost:8080

## Running phpunit tests inside the container
```
cd /var/www/polaris
vendor/bin/phpunit
```

## Installing Polaris

Create project will install Polaris into the web directory. You can now install Polaris as you would with any Drupal 8 site. See: [Drupal installation guide](https://www.drupal.org/node/1839310). The folder name should be the repo name without *-cms*: Repo name: *itpro-cms*, folder name *itpro*.
If you are using the Polaris Vagrant box you can run the command on /var/www/html folder. Then visit http://polaris.vm.cms.didev.co.uk.
See the Readme of the [Vagrant box for more info](https://github.com/dennisinteractive/polaris-ansible).

Installing the profile
```
cd /var/www/html/polaris
make site-create
```

This will run a site installation, initialize git and export the config.

## Login into site

Login into site and add an administrator account with username: admin and password: {the usual one} which can be shared with the team for development purposes.

## Commit your files

Now you need to commit your files. Remember to export a db dump.

