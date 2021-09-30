# Phxcrd

**Updated with Phoenix 1.6.x**

A project-template for starting CRUD apps with Phoenix framework. This is based mainly on my own requirements.

This doesn't include webpack or any other JS bundlers; just use good ol' vanilla JS! Everything client-side phoenix (presense, live views etc) is  working!


## Things that *are* included:

* A custom user model
* Multiple authentication with both LDAP (using exldap) and database (using comeonin and argon for password hashing)
* A permission model to add permissions to users (i.e Administrator, Editor etc)
* An authority model to assign users to authorities (i.e directorates, groups etc)
* Authorization using cancan (i.e only Administrators can access this view, only users belonging to the same Authority can edit a user's process)
* Creating PDFs with pdf_generator
* Creating xlsxs with elixlsx
* Local time support with timex
* Use accessible to be able to properly "Access" schema attributes
* Scrievner for pagination (check authority_controller for usage)
* Auditing models with ex_audit
* Send mails with bamboo (smtp)
* A bootstrap 5 styled template
* A script to easily *rename* this project so it can be used as a template for your own projects
* A way to define filters for a query among joins etc (check authority_controller for example - https://spapas.github.io/2019/07/25/declarative-ecto-query-filters/)
* Allow sorting pages with click (https://spapas.github.io/2019/10/17/declarative-ecto-query-sorting/)
* Integration of select2 with ajax (https://spapas.github.io/2019/06/04/phoenix-form-select2-ajax/)
* Sentry integration for error reporting
* Configuration using secrets and a secret template
* Multiple environments (dev/uat/prod) each with its own secret (copy the template and rename it)
* A fabric (https://www.fabfile.org/ for fabric 1.x) script to quickly deploy changes
* A config file for supervisord (http://supervisord.org)
* Custom JS includes on specific controller actions
* A i18n enabled Phoenix datepicker
* Properly configure phoenix presence along with a small demonstration
* Properly configure phoenix live view along with a small demonstration
* Proper CRUD handling with Phoenix Live View (add/edit/show/delete)
* An example of file uploading and usage of sendfile to implement authorization on uploaded files
* Phoenix Live Dashboard
* Custom handlers for alerts (https://spapas.github.io/2020/05/15/elixir-osmon-alerts/)

## Missing stuff

* Fix all tests
* Various refactoring decisions
* Check out `phx mix.digest`

## Compiling comeonin-argon

~~Read this first: https://github.com/riverrun/comeonin/wiki/Requirements~~

~~TL;DR: You'll need to install the MS VS Build tools and then run vcvarsall.bat amd64. Notice that the location of vcvaralls.bat is different for different versions so just search it. Then run `mix compile` to properly compile argon.~~

Depracated! I changed it with `pbkdf2_elixir` to avoid the compilation step on Windows!

## Requirements

I've tested it on  Windows 10 with

```
Erlang/OTP 24 [erts-12.0] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [jit]

Elixir 1.12.3 (compiled with Erlang/OTP 22)
```


## Deploying

I propose deploying with a fabric script or something similar; i.e pull the changes from your VCS and run required commands. This doesn't support distillery yet.

For the first time you want to deploy should just clone it from GH like

```
git clone https://github.com/spapas/phxcrd
```

and then go to the phxcrd directory and copy the `config/secret.exs.template` to `env_name.secret.exs` where `env_name` is either `dev`, `uat` or `prod`.

Then you should properly edit the secrets file for your environment.

After that you should set your mix environment ie run something like `export MIX_ENV=uat` on unix/bash or `set MIX_ENV=uat` on windows and finally you'll
be able to run `mix`. The following steps will be run anyway each time you deploy something from fabric but I recommend running them once to see the
output. So try running:

```
mix ecto.create # to create the env's db
mix ecto.migrate # to create tables in the database
mix run mix run priv/repo/seeds.exs # to seed the database
mix phx.server # to make sure that everything works fine
```

To auto-start the server I use supervisord; just copy `/etc/phxcrd-supervisor.conf` to your `/etc/supervisord.d/` directory.

## Templating

You can use the `renameproj.bat` file to create a project with different name than phxcrd. The script is for windows cmd but you can take a look
at it and convert it to unix/bash or take a look at this gist: https://gist.github.com/krystofbe/92aed7cd03c9a631eb3c7af490525c4e

Before starting the script you must set the following variables like so:

```
set CURRENT_NAME="Phxcrd"
set CURRENT_OTP="phxcrd"

set NEW_NAME="NewName"
set NEW_OTP="new_name"
```

Also notice it needs some utilities like sed and xargs which must be available to your github for windows installation folder.

## Deploying changes

I've provided a simple fabric script for that: The script will

* Add / commit and push local changes
* Retrieve and merge changes to server
* Install deps and run migrations
* Restart server (using supervisorctl)

Just run `fab env full_deploy` (env = uat or prod) and you should be good to go. Notice that I use the fabric 1.x syntax (because fabric 2.x does not support various things) thus you'll need to use fab-classic (`pip install fab-classic`).

## Signal handling

It may be worth it to respond to signals for restarting using `:init.restart`.

* http://erlang.org/doc/man/kernel_app.html#erl_signal_server
* https://medium.com/@ellispritchard/graceful-shutdown-on-kubernetes-with-signals-erlang-otp-20-a22325e8ae98
