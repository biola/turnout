Turnout [![Build Status](https://travis-ci.org/biola/turnout.png?branch=master)](https://travis-ci.org/biola/turnout)
=======
Turnout is a [Ruby on Rails](http://rubyonrails.org) engine with a [Rack](http://rack.rubyforge.org/) component that allows you to put your Rails app in maintenance mode.

Features
========
* Easy installation
* Rake commands to turn maintenance mode on and off
* Easily provide a reason for each downtime without editing the maintenance.html file
* Allow certain IPs or IP ranges to bypass the maintenance page
* Allow certain paths to be accessible during maintenance
* Easily override the default maintenance.html file with your own
* Simple [YAML](http://yaml.org) based config file for easy activation, deactivation and configuration without the rake commands
* Supports Rails 2.3 - 3.0 and Ruby 1.8.7 - 1.9.3

Installation
============
Rails 3
-------
In your `Gemfile` add:

    gem 'turnout'

then run

    bundle install

Rails 2.3
---------
In your `config/environment.rb` file add:

    config.gem 'turnout'

then run

    rake gems:install

then in your `Rakefile` add:

    require 'turnout/rake_tasks'


Activation
==========

    rake maintenance:start

or

    rake maintenance:start reason="Somebody googled Google!"

or

    rake maintenance:start allowed_paths="/login,^/faqs/[0-9]*"

or

    rake maintenance:start allowed_ips="4.8.15.16"

or

    rake maintenance:start reason="Someone told me I should type <code>sudo rm -rf /</code>" allowed_paths="^/help,^/contact_us" allowed_ips="127.0.0.1,192.168.0.0/24"

Notes
-----
* The `reason` parameter can contain HTML
* Multiple `allowed_paths` and `allowed_ips` can be given. Just comma separate them.
* All `allowed_paths` are treated as regular expressions.
* If you need to use a comma in an `allowed_paths` regular expression just escape it with a backslash: `\,`.
* IP ranges can be given to `allowed_ips` using [CIDR notation](http://en.wikipedia.org/wiki/CIDR_notation).

Deactivation
============

    rake maintenance:end

Customization
=============

A [default maintenance page](https://github.com/biola/turnout/blob/master/public/maintenance.html) is provided, but you can create your own `public/maintenance.html` instead. If you provide a `reason` to the rake task, Turnout will use [Nokogiri](http://nokogiri.org) to parse the `maintenance.html` file and attempt to find a tag with `id="reason"`. It will replace the `inner_html` of the tag with the reason you provided. So be sure your `maintenance.html` file can be parsed as HTML.

Tips
====

There is no `denied_paths` feature because turnout denies everything by default.
However you can achieve the same sort of functionality by using
[negative lookaheads](http://www.regular-expressions.info/lookaround.html) with the `allowed_paths` setting, like so:

    rake maintenance:start allowed_paths="^(?!/your/under/maintenance/path)"

Behind the Scenes
=================
On every request the Rack app will check to see if `tmp/maintenance.yml` exists. If the file exists the maintenance page will be shown (unless allowed IPs are given and the requester is in the allowed range).

So if you want to get the maintenance page up or down in a hury `touch tmp/maintenance.yml` and `rm tmp/maintenance.yml` will work.

Turnout will attempt to parse the `maintenance.yml` file looking for `reason` and `allowed_ip` settings. The file is not cached so you can change these values manually or just rerun the `rake maintenance:start` command.

The location of `maintenance.yml` can be configured using `Turnout.config.update dir: 'your_dir'`.  In Rails, you can drop this in `./config/initializers/turnout_config.rb`.  Using rake activation this would be passed as environment variable `dir`: `dir=tmp/maint rake maintenance:start`.

Example maintenance.yml File
----------------------------

    ---
    reason: Someone told me I should type <code>sudo rm -rf /</code>
    allowed_paths:
    - ^/help
    - ^/contact_us
    allowed_ips:
    - 127.0.0.1
    - 192.168.0.0/24
