# ScholarSphere [![Version](https://badge.fury.io/gh/psu-stewardship%2Fscholarsphere.png)](http://badge.fury.io/gh/psu-stewardship%2Fscholarsphere) [![Build Status](https://travis-ci.org/psu-stewardship/scholarsphere.png?branch=develop)](https://travis-ci.org/psu-stewardship/scholarsphere) [![Dependency Status](https://gemnasium.com/psu-stewardship/scholarsphere.png)](https://gemnasium.com/psu-stewardship/scholarsphere)

ScholarSphere is Penn State's self- and proxy-deposit repository for access to and preservation of scholarly works and data. It is built atop [Sufia](https://github.com/projecthydra/sufia), a [Hydra](http://projecthydra.org)/Rails-based component.

ScholarSphere is being developed as part of
[Penn State's Digital Stewardship Program](http://stewardship.psu.edu/).
Development on ScholarSphere began as part of the prototype
[CAPS project](http://stewardship.psu.edu/2011/02/caps-a-curation-platform-prototype.html). Code
and documentation are freely available via [Github](http://github.com/psu-stewardship/scholarsphere).

For more information, read the [ScholarSphere development docs](https://github.com/psu-stewardship/scholarsphere/wiki).

## License

ScholarSphere is available under the Apache 2.0 license.
[Read the copyright statement and license](/psu-stewardship/scholarsphere/blob/master/LICENSE.md).

## Install

Infrastructural components

 * Ruby 2.0 (we use RVM to manage our Rubies)
 * Fedora (if you don't have access to an instance, use the built-in
   hydra-jetty submodule)
 * Solr (if you don't have access to an instance, use the built-in
   hydra-jetty submodule)
 * A relational database (SQLite and MySQL have been tested)
 * Redis (for activity streams and background jobs)

Install system dependencies

 * libmysqlclient-dev (if running MySQL as RDBMS)
 * libsqlite3-dev (if running SQLite as RDBMS)
 * libmagick-dev (or libmagickcore-dev on Ubuntu 12.10)
 * libmagickwand-dev
 * clamav
 * clamav-daemon
 * libclamav-dev
 * [FITS](http://code.google.com/p/fits/) -- put it in a
  directory on your PATH
 * ghostscript (required to create thumbnails from pdfs)

Get the ScholarSphere code

    git clone https://github.com/psu-stewardship/scholarsphere.git

Install gems

    bundle install

Copy config samples

    cp config/database.yml.sample config/database.yml
    cp config/fedora.yml.sample config/fedora.yml
    cp config/solr.yml.sample config/solr.yml
    cp config/redis.yml.sample config/redis.yml
    cp config/hydra-ldap.yml.sample config/hydra-ldap.yml

If you're using SQLite, a vanilla Redis installation, and the
Hydra-Jetty Solr and Fedora components (see below), you should not
need to tweak the database.yml, fedora.yml, solr.yml, or redis.yml
files.

If you're planning to use LDAP for user account information and
groups, you will need to know some information about your LDAP
service, which will go into hydra-ldap.yml.

Create database

    rake db:create

(Re-)Generate the app's secret token

    rake scholarsphere:generate_secret

Migrate database

    rake db:migrate

If you'll be *developing* ScholarSphere, setup test databases and load
fixture data

    RAILS_ENV=test rake db:create
    RAILS_ENV=test rake db:migrate
    RAILS_ENV=test rake scholarsphere:fixtures:generate
    RAILS_ENV=test rake scholarsphere:fixtures:refresh

To use the built-in Fedora and Solr instances, get the bundled hydra-jetty,
configure it, & fire it up

    git submodule init
    git submodule update
    rake jetty:config
    rake jetty:start

Start the resque-pool workers (needed for characterization, audit,
unzip, and resolrization services)

    resque-pool --daemon --environment development start

Run the app server (the bundled app server is Unicorn)

    rails server

Browse to http://localhost:3000/ and you should see ScholarSphere!

## Usage Notes

### Auditing All Datastreams

To audit the digital signatures of every version of every object in the
repository, run the following command

    script/audit_repository

You'll probably want to schedule this regularly (e.g., via cron) in production environments.
Note that this does not *force* an audit -- it respects the value of max_days_between_audits
in application.rb.  Also note that if you want to run this on any environment other than
development, you will need to call the script with RAILS_ENV=environment in front.

### Re-solrize All Objects

If for some reason you need to force all objects to be re-solrizer,
perhaps because you have updated which fields are facetable and which
are not, ScholarSphere contains a rake task that kicks off a
re-solrization asynchronously via a Resque job.

     rake scholarsphere:resolrize

Note that if you want to run this on any environment other than development, you will need to
call the script with RAILS_ENV=environment in front.

### Characterize All Uncharacterized Datastreams

In the event that some objects have not undergone characterization (for whatever reason),
there is a rake task that sweeps through the entire repository looking for objects that lack
a characterization datastream.  For each object that lacks this datastream, a CharacterizationJob
that will characterize and thumbnailize the object is queued up.

     rake scholarsphere:characterize

Note that if you want to run this on any environment other than development, you will need to
call the script with RAILS_ENV=environment in front.

### Export Metadata as RDF/XML

There is a rake task that exports the metadata of every object that is readable by the public to
the RDF/XML format.  This might be useful as an export mechanism, e.g., to Summon or a similar
discovery system.

     rake scholarsphere:export:rdfxml

Note that if you want to run this on any environment other than development, you will need to
call the script with RAILS_ENV=environment in front.

### Harvesting Authorities Locally

ScholarSphere supports "authority suggestion," a feature that links controlled
vocabularies to descriptive metadata elements.  This provides functionality both
for mapping string values to URIs and for populating dropdowns in metadata form
fields, e.g., if a user types "Cro" into a subject field, they might see a list
that includes "Croatian independence," the subject they were going to type out.

In order to avoid network latency, these vocabularies are harvested in advance
and stuffed into the ScholarSphere relational database for easy and quick lookups.

To get a sense for how this works, pull in database fixtures containing
pre-harvested authorities

    rake db:data:load

To harvest more authorities:

1. Harvest the authority (See available harvest tasks via `rake -T
scholarsphere:harvest`) -- N.B. depending on the size of the vocabulary, this
may take a *very* long time, especially if you're using a slower database such
as SQLite.
1. (OPTIONAL) Generate fixtures so other instances don't need to re-harvest (See
available database tasks via `rake -T db`)
1. Register the vocabulary with a domain term in generic_file_rdf_datastream.rb
(See the bottom of the file for examples)

## [Contribute](CONTRIBUTING.md)
