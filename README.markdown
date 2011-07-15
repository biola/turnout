Turnout
=======
Turnout is a Ruby on Rails engine with a Rack component that allows you to put your Rails app in maintenance mode.

Features
========
* Easy installation
* Rake commands to turn maintenance mode on and off
* Easily override the default maintenance.html file with your own
* Allow certain IPs or IP ranges to bypass the maintenance page
* Easily provide a reason for each downtime without editing the maintenance.html file

Installation
============
In your Gemfile add:

    gem 'turnout'

Activation
==========

    rake maintenance:start

or

    rake maintenance:start reason="Somebody googled Google!"

or

    rake maintenance:start allowed_ips="4.8.15.16"

or

    rake maintenance:start reason="Someone told me I should type <code>sudo rm -rf /</code>" allowed_ips="127.0.0.1,192.168.0.0/24"

*Notice that you can allow multiple IP addresses or IP ranges using [CIDR notation](http://en.wikipedia.org/wiki/CIDR_notation).*

Deactivation
============

    rake maintenance:end

Customization
=============

A [default maintenance page](https://github.com/biola/turnout/blob/master/public/maintenance.html) is provided, but you can create your own `public/maintenance.html` instead. If you provide a `reason` to the rake task, Turnout will use [Nokogiri](http://nokogiri.org) to parse the `maintenance.html` file and attempt to find a tag with `id="reason"`. It will replace the `inner_html` of the tag with the reason you provided. So be sure your `maintenance.html` file can be parsed as HTML.

Behind the Scenes
=================
On every request the Rack app will check to see if `tmp/maintenance.yml` exists. If the file exists the maintenance page will be shown (unless allowed IPs are given and the requester is in the allowed range).

So if you want to get the maintenance page up or down in a hury `touch tmp/maintenance.yml` and `rm tmp/maintenance.yml` will work.

Turnout will attempt to parse the `maintenance.yml` file looking for `reason` and `allowed_ip` settings. The file is not cached so you can change these values manually or just rerun the `rake maintenance:start` command.

Example maintenance.yml File
----------------------------

    ---
    reason: Someone told me I should type <code>sudo rm -rf /</code>
    allowed_ips:
    - 127.0.0.1
    - 192.168.0.0/24
