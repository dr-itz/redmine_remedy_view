# Redmine Remedy View

**Warning: this is only lightly tested**

Add a project module to view tickets from a Remedy AR installation. Redmine
tickets can be created from a Remedy Ticket.

This plugin is targeted at a specific Remedy installation and is not generic.
Nevertheless it might serve as a base for another integration.

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


FIXME: java part


## Uninstallation

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

FIXME

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
