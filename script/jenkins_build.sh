#!/bin/bash
#
# Currently a stub for jenkins as called from
# https://gamma-ci.dlt.psu.edu/jenkins/job/scholarsphere/configure
#       Build -> Execute Shell Command ==
#       test -x $WORKSPACE/script/jenkins_build.sh && $WORKSPACE/script/jenkins_build.sh
# to run CI testing.
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
HHOME="/opt/heracles"
JENKINS_HOME="/opt/heracles/jenkins"
WORKSPACE="${JENKINS_HOME}/jobs/scholarsphere-ci/workspace"
RESQUE_POOL_PIDFILE="${WORKSPACE}/tmp/pids/resque-pool.pid"
RUBY_VERSION=`cat $WORKSPACE/.ruby-version`

function rbenv_environment {
# Initialize rbenv
      export HOME=$HHOME
      export RBENV_ROOT=/$HOME/.rbenv
      export PATH="$RBENV_ROOT/bin:$PATH"
      eval "$(rbenv init -)"
           }
#echo "=-=-=-=-= $0 source ${HHOME}/.bashrc"
source ${HHOME}/.bashrc

#echo "=-=-=-=-= $0 cd ${WORKSPACE}"
cd ${WORKSPACE}

# Install rbenv if not there
if [ ! -d "$HHOME/.rbenv" ]; then
echo "=-=-=-=-= Install rbenv"
git clone https://github.com/sstephenson/rbenv.git $HHOME/.rbenv
git clone https://github.com/sstephenson/ruby-build.git $HHOME/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~tomcat/.bash_profile
fi

rbenv_environment

INSTALLED_RUBY_VERSION=`rbenv version | awk '{print $1}'`

#$ Get newer version of ruby and ruby build
#echo $RUBY_VERSION
#echo $INSTALLED_RUBY_VERSION


INSTALLED_RUBY_VERSION=1
if [ "${RUBY_VERSION}" != "${INSTALLED_RUBY_VERSION}" ]; then
    cd $HHOME/.rbenv/plugins/ruby-build
    git pull

    rbenv_environment
    rbenv install $RUBY_VERSION --skip-existing
#    rbenv install $RUBY_VERSION --force
    rbenv shell 2.0.0-p353
    rbenv rehash

    #source ${HHOME}/.bash_profile

    cd $HHOME
    gem install bundler
    gem install passenger --no-ri --no-rdoc
    rbenv rehash
    passenger-install-apache2-module --auto
    PASSENGER_VERSION=`$HHOME/.rbenv/versions/$RUBY_VERSION/bin/passenger-config --version`

cat > /opt/heracles/.passenger.tmp <<EOL
LoadModule passenger_module $HHOME/.rbenv/versions/$RUBY_VERSION/lib/ruby/gems/2.0.0/gems/passenger-$PASSENGER_VERSION/buildout/apache2/mod_passenger.so
PassengerRoot $HHOME/.rbenv/versions/$RUBY_VERSION/lib/ruby/gems/2.0.0/gems/passenger-$PASSENGER_VERSION
PassengerDefaultRuby $HHOME/versions/$RUBY_VERSION/bin/ruby
EOL

sudo /bin/mv /opt/heracles/.passenger.tmp /etc/httpd/conf.d/passenger.conf
fi

# Initialize rbenv if there was not a new version of ruby to install
rbenv_environment
rbenv rehash
rbenv shell 2.0.0-p353

cd $HHOME

echo "=-=-=-=-= $0 bundle install"
bundle install

echo "=-=-=-=-= $0 cp -f ${HHOME}/config/{database,fedora,solr,hydra-ldap,devise}.yml ${WORKSPACE}/config"
cp -f ${HHOME}/config/{database,fedora,solr,hydra-ldap,devise}.yml ${WORKSPACE}/config

echo "=-=-=-=-= $0 resque-pool --daemon --environment test start"
bundle exec resque-pool --daemon --environment test start

echo "=-=-=-=-= $0 bundle exec rake --trace scholarsphere:generate_secret"
bundle exec rake --trace scholarsphere:generate_secret

echo "=-=-=-=-= $0 HEADLESS=true RAILS_ENV=test bundle exec rake --trace scholarsphere:ci"
HEADLESS=true RAILS_ENV=test bundle exec rake --trace scholarsphere:ci
retval=$?

 echo "=-=-=-=-= $0 kill resque-pool's pid to stop it"
 [ -f $RESQUE_POOL_PIDFILE ] && {
     kill -2 $(cat $RESQUE_POOL_PIDFILE)
 }

echo "=-=-=-=-= $0 finished $retval"
exit $retval
#
# end
