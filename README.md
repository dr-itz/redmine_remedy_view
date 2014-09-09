# Redmine Remedy View

Add a project module to view tickets from a Remedy AR installation. Redmine
tickets can be created from a Remedy Ticket.

**Note**: This plugin is targeted at a specific Remedy installation and is not
generic. Nevertheless it might serve as a base for another integration.

Requirements:

  * Redmine 2.2 or higher
  * Ruby 1.9.3 or higher
  * Java 6 or higher
  * Ant 1.8 or higher

## Installation

Installing the plugin requires these steps. From within the Redmine root
directory:

 1. **Get the plugin**

	```
	cd plugins
	git clone git://github.com/dr-itz/redmine_remedy_view.git
	```

 2. **Run bundler**

	Run excatly the same as during Redmine installation. This might be:

	```
	bundle install --without development test
	```

 3. **Run plugin migrations**

	```
	bundle exec rake redmine:plugins NAME=redmine_remedy_view RAILS_ENV=production
	```

 4. **Restart Redmine**

	The second step is to restart Redmine. How this is done depends on how Redmine is
	setup. After the restart, configuration of the plugin can begin.


Next, the synchronisation needs to be configured, i.e. the two database
connections:

~~~~
$ cd $REDMINE/plugins/redmine_remedy_view/java/config
$ cp configuration.properties production.properties
$ vi production.properties
~~~~

Configure the database connections accordingly. Also, check the file
``config/sync.properties'' that defines the table and column names.

Before the synchronisation tool can be used, the code must be compiled

~~~~
$ cd $REDMINE/plugins/redmine_remedy_view/java/
$ ant dist
$ chmod 755 ./dist/bin/Remedy2Redmine
~~~~

Next, test the synchronisation:

~~~~
$ cd $REDMINE/plugins/redmine_remedy_view/java/
$ ./dist/bin/Remedy2Redmine config/production.properties sync
~~~~

If there's no error message, the synchronisation works. Create a little wrapper
script like this in `$REDMINE/plugins/redmine_remedy_view/sync_remedy.sh`:

~~~~
#!/bin/bash
cd $(dirname $0)
./java/dist/bin/Remedy2Redmine java/config/production.properties sync
~~~~

Make it executable (`chmod 755 sync_remedy.sh`) and call it from a cron job at
regular intervals.


## Uninstalling

Uninstalling the plugin is easy as well. Again, execute from within the Redmine
root directory.

 1. **Reverse plugin migrations**

	```
	bundle exec rake redmine:plugins NAME=redmine_remedy_view RAILS_ENV=production VERSION=0
	```

 2. **Removing the plugin directory**

	```
	rm -r plugins/redmine_remedy_view
	```

 3. **Run bundler**

	Run excatly the same as during Redmine installation. This might be:

	```
	bundle install --without development test
	```

 4. **Restart Redmine**

	The second step is to restart Redmine. Once restarted, the plugin will be gone.

## Usage

  * Configure the Roles that need Remedy access with the Remdy permissions
	``View Remedy Tickets'' and where appropriate the ``Configure Remedy
	View''.
  * In each project that needs the Remedy View, enable the Module
  * In the ``Settings'' sub-tab ``Remedy'' define the filters.
  * Check the ``Remedy'' tab in the project

## Development and test

To run the tests, an additional Gem is required for code coverage: simplecov. If
bundler was initially run with `--without developmen test`, run again without
these arguments to install *with* the development and test gems.

To run the tests:

````
bundle exec rake redmine:plugins:test NAME=redmine_remedy_view
````


## License

Since this is a Redmine plugin, Redmine is licensed under the GPLv2 and the
GPLv2 is very clear about derived work and such, this plugin is licensed under
the same license.
