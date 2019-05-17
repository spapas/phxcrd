# Phxcrd

A project-template for starting CRUD apps with Phoenix framework. This is based mainly on my own requirements.

This doesn't include webpack or any other JS bundlers; just use good ol vanilla JS where you need it!

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
* A milligram styled template
* A script to easily *rename* this project so it can be used as a template for your own projects
* A way to define filters (for querying) for a schema (check authority_controller for example)
* Sentry integration for error reporting
* Configuration using secrets and a secret template
* Multiple environments (dev/uat/prod) each with its own secret (copy the template and rename it)
* A fabric (https://www.fabfile.org/ for fabric 1.x) script to quickly deploy changes
* A config file for supervisord (http://supervisord.org)

## Missing stuff

* Fix all tests
* Various refactoring decisions
* Check out `phx mix.digest`

## Compiling comeonin-argon

Read this first: https://github.com/riverrun/comeonin/wiki/Requirements

TL;DR: You'll need to install the MS VS Build tools and then run vcvarsall.bat amd64. Notice that the location of vcvaralls.bat is different for different versions so just search it.

Then run `mix compile` to properly compile argon.

## Requirements

I've tested it on both Windows 10 with 

```
Erlang/OTP 21 [erts-10.1] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1]

Elixir 1.8.1 (compiled with Erlang/OTP 20)
```

and Centos 6.5 with 

```
Erlang/OTP 21 [erts-10.3.5] [source] [64-bit] [smp:1:1] [ds:1:1:10] [async-threads:1] [hipe]

Elixir 1.8.2 (compiled with Erlang/OTP 21)
```

Please notice that to install Erlang I've used the repository from https://packages.erlang-solutions.com/erlang/.
To install elixir I've just compiled from source, it worked flawlessly. I then moved elixir to /opt/elixir-1.8.2/
and added 

```
PATH=$PATH:/opt/elixir-1.8.2/bin/
export PATH
```

to my `~/.bash_profile`.

You'll also need wkhtmltopdf to be installed to support PDF generation (if you don't want it comment out the corresponding lines from mix.exs)


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

You can use the `renameproj.bat` file to create a project with different name than dod. The script is for windows cmd but you can take a look
at it and convert it to unix/bash or take a look at this gist: https://gist.github.com/krystofbe/92aed7cd03c9a631eb3c7af490525c4e

Before starting the script you must set the following variables like so:

```
set CURRENT_NAME="Dod"
set CURRENT_OTP="dod"

set NEW_NAME="NewName"
set NEW_OTP="new_name"
``` 

## Deploying changes

I've provided a simple fabric script for that: The script will

* Add / commit and push local changes
* Retrieve and merge changes to server
* Install deps and run migrations
* Restart server (using supervisorctl)

Just run `fab env full_deploy` (env = uat or prod) and you should be good to go. Notice that I use fabric 1.x (because fabric 2.x does not support various things) thus you'll need to have python 2.x installed.

## Signal handling

It may be worth it to respond to signals for restarting using `:init.restart`.

* http://erlang.org/doc/man/kernel_app.html#erl_signal_server
* https://medium.com/@ellispritchard/graceful-shutdown-on-kubernetes-with-signals-erlang-otp-20-a22325e8ae98
