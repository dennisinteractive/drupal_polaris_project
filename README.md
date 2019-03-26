# Composer based Polaris installation

This project template should provide a kickstart for managing your site dependencies with [Composer](https://getcomposer.org/).

## Creating new sites

First you need to install [Composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx) and [Git](https://git-scm.com).

### Creating the project:

```
composer create-project dennisdigital/polaris-drupal-project:dev-CMS-96_scaffolding polaris --stability dev --no-interaction
```

If you want to run the docker image locally:

```
docker run -v ~/polaris/:/var/www/polaris --rm --name drupal8 -p 8080:80 -d dennisdigital/drupalci:8-apache-interactive
```
This is useful when you want to work on the project and test changes locally. You can ssh inside the images and run the same commands
as in .circleci folder.

```
docker exec -it drupal8 sh
```

If you want to see the site, browse http://localhost:8080


## Installing Polaris

Create project will install Polaris into the web directory. You can now install Polaris as you would with any Drupal 8 site. See: [Drupal installation guide](https://www.drupal.org/node/1839310).
If you are using the Polaris Vagrant box you can run the command on /var/www/html folder. Then visit http://polaris.vm.cms.didev.co.uk.
See the Readme of the [Vagrant box for more info](https://github.com/dennisinteractive/polaris-ansible).

Installing the profile
```
cd /var/www/html/polaris
make site-create
```

This will run a site installation, initialize git and export the config.

## Commit your files

Now you need to commit your files. Remember to export a db dump.
