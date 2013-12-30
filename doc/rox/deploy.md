# Deployment

## Installation

Clone ROX Center in a directory accessible to your web server.

### Configuration

You must first set up the configuration files. Each of the following files has development and production samples in the [`config/samples`](config/samples) directory.

* `config/database.yml` is the configuration to connect to your MySQL database.
* `config/redis.yml` is the configuration to connect to your Redis database.
* `config/rox-center.yml` is the ROX Center configuration.
* `config/initializers/secret_token.rb` configures the secret token and secret key base used to verify the integrity of session cookies.

In the `rox-center.yml` file, you must choose between database authentication (ROX Center stores its own passwords in the MySQL database), or LDAP authentication (against an external LDAP server). If you are using LDAP authentication, you must also set up the LDAP configuration files.

* `config/ldap.yml` contains the configuration to connect to your LDAP server.
* `config/initializers/ldap.rb` customizes the LDAP configuration.

### GCC

The `libv8` gem requires GCC for compilation.
Install it with your package manager before running `bundle install`.

```bash
# MacPorts
port install apple-gcc42
port select --set gcc apple-gcc42

# Yum
yum install gcc gcc-c++ autoconf automake

# Aptitude
apt-get install build-essential
```

### Development Setup

```bash
cd /path/to/rox-center

# Install gems.
bundle install

# Create the database, load the schema and initialize seed data.
rake db:setup

# Start a resque worker.
QUEUE=* INTERVAL=2 bundle exec rake resque:work

# Start the server.
bundle exec rails server
```

### Production Setup

ROX Center comes with a sample configuration file for the [Unicorn](http://unicorn.bogomips.org) server in `config/samples/unicorn.rb`. Copy it to `config/unicorn.rb` and update it to suit your environment.

```bash
cd /path/to/rox-center

# Install gems.
bundle install --deployment --without test development

# Create the database, load the schema and initialize seed data.
rake db:setup

# Pre-compile assets.
RAILS_ENV=production bundle exec rake assets:precompile

# Start a resque worker.
RAILS_ENV=production PIDFILE=tmp/pids/resque.pid BACKGROUND=yes QUEUE=* INTERVAL=2 bundle exec rake resque:work

# Start the unicorn server.
RAILS_ENV=production bundle exec unicorn_rails -c config/unicorn.rb -E production -D
```

## Upgrade

### Full Upgrade

```bash
cd /path/to/rox-center

# Gracefully stop the unicorn server.
sudo kill -s QUIT `cat tmp/pids/unicorn.pid`

# Gracefully stop the resque worker.
sudo kill -s QUIT `cat tmp/pids/resque.pid`

# Backup the database, rotate logs.

# Update the code.
git pull

# Upgrade gems.
bundle install --deployment --without test development

# Migrate the database.
RAILS_ENV=production rake db:migrate

# Pre-compile assets.
RAILS_ENV=production bundle exec rake assets:precompile

# Clear and warm up the cache.
RAILS_ENV=production rake cache:deploy

# Start a resque worker.
RAILS_ENV=production PIDFILE=tmp/pids/resque.pid BACKGROUND=yes QUEUE=* INTERVAL=2 bundle exec rake resque:work

# Start the unicorn server.
RAILS_ENV=production bundle exec unicorn_rails -c config/unicorn.rb -E production -D
```

### Hot Deploy

When an upgrade requires no migration and resque workers do not need to be restarted, ROX Center can be upgraded with no downtime.
The changelog will indicate to which versions this scenario is applicable.

```bash
cd /path/to/rox-center

# Update the code.
git pull

# Upgrade gems.
bundle install --deployment --without test development

# Pre-compile assets.
RAILS_ENV=production bundle exec rake assets:precompile

# Restart the unicorn server (worker by worker, with no downtime).
sudo kill -s USR2 `cat tmp/pids/unicorn.pid`
```
