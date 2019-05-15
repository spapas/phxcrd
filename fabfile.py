from __future__ import with_statement
from fabric.api import *
import fabric
import fnmatch
import os
#import with from __future__

def commit():
    """
    Commit from local to VCS
    """
    print "Commiting to  VCS"
    local('git add -A')
    with settings(warn_only=True):
        local('git commit')
    with settings(warn_only=True):
        local('git push origin master')
    print "Commit ok"

def pull():
    """
    Pull from remote to server
    """
    print "Pulling from remote to " + env.env
    with cd(env.directory):
        run('git fetch origin')
        run('git merge origin/master')
    print "fetch / merge ok"

def work():
    """
    Do work on server (copy settings and run collect static
    """
    with cd(env.directory):
        run('MIX_ENV='+env.env+' mix deps.get')
        run('MIX_ENV='+env.env+' mix ecto.migrate')

def restart():
    print("Restarting server");
    if env.env == 'uat':
        run(r'supervisorctl restart phxcrd') 
        #run('fuser -k 4000/tcp')
        #run('MIX_ENV='+env.env+' mix phx.server')


def full_deploy():
    """
    Commit - pull - do work - and restart server
    """
    commit();
    pull();
    work();
    restart();

def uat():
    """
    UAT settings
    """
    env.env = "uat"
    env.user = 'serafeim'
    env.hosts = ['uat1.hcg.gr']
    env.directory = '/home/serafeim/phxcrd'

def prod():
    """
    PROD settings
    """
    env.env = "prod"
    env.user = 'serafeim'
    env.hosts = ['']
    env.directory = '/home/serafeim/phxcrd'

