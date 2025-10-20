
[![Docker Pulls](https://img.shields.io/docker/pulls/adnexus/campaign-manager.svg)](https://hub.docker.com/r/adnexus/campaign-manager/)
[![Docker Stars](https://img.shields.io/docker/stars/adnexus/campaign-manager.svg)](https://hub.docker.com/r/adnexus/campaign-manager/)
[![](https://images.microbadger.com/badges/version/adnexus/campaign-manager.svg)](https://microbadger.com/images/adnexus/campaign-manager "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/adnexus/campaign-manager.svg)](https://microbadger.com/images/adnexus/campaign-manager "Get your own image badge on microbadger.com")
[![Build Status](https://travis-ci.org/adnexus/campaign-manager.svg?branch=master)](https://travis-ci.org/adnexus/campaign-manager)

Campaign Manager - ADNEXUS Campaign Management UI
==================================================

Campaign management user interface for [Adnexus](http://ad.nexus/)

An image of this repo is available directly from [Docker Hub](https://hub.docker.com/r/adnexus/campaign-manager/)


Getting Help
------------

User documentation can be found on [Read The Docs](https://adnexus.readthedocs.io)


Source Code
-----------

To start working with code, first make sure you have the following installed on your computer:

* [Ruby v3.3.x](https://www.ruby-lang.org/en/downloads/releases/)
* [Rails v8.0.x](https://guides.rubyonrails.org/)
* [MySQL v8.0](https://www.mysql.com/)
* [Docker](https://www.docker.com/) (recommended for development)

Next, get the code from this Github repo:

```
git clone git@github.com:ADNEXUS/campaign-manager.git
cd campaign-manager
```

The Adnexus campaign manager is a modern [Rails 8.x application](https://guides.rubyonrails.org/), and can be installed and managed in the standard Rails fashion:

Install using Rails:

```
bundle install
```

Configure the database:

```
rake db:setup
```

Run the tests:

```
rake test
```

Start the server:

```
rails s
```

Using Campaign Manager
----------------------

To run the campaign manager locally, open a browser to the host:

[http://localhost:3000](http://localhost:3000)

Username: `demo@ad.nexus`
Password: `adnexus`

For information about the campaign manager functionality:

[User Documentation](https://adnexus.readthedocs.io)

Getting Support
---------------

There are various ways of getting support:

* Email us at [support@ad.nexus](mailto://support@ad.nexus)
* Add a Github issue:  [github.com/adnexus/campaignmanager/issues](https://github.com/adnexus/campaignmanager/issues)
* Join the [Adnexus Slack Channel](https://join.slack.com/t/adnexus/shared_invite/enQtNjYxNzc3NTQwMzIwLTlkNWYyMzY0NzA3MTNmMjc2M2I0NzkxYjE0NGIwYTljMjQ2YzAwYTBmMTJhNWM0ZDc0NTljNTA3NzFjNzZlNDI)
