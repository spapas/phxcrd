# Phxcrd

A project-template for starting CRUD apps with Phoenix framework. This is based mainly on my own requirements

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
 

## Compiling comeonin-argon

Read this first: https://github.com/riverrun/comeonin/wiki/Requirements

TL;DR: You'll need to install the MS VS Build tools and then run vcvarsall.bat amd64. Notice that the location of vcvaralls.bat is different for different versions so just search it.

Then run `mix compile` to properly compile argon.
