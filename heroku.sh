#!/bin/bash
#
# Copyright (c) 2013 Jason McVetta.  This is Free Software, released under the
# terms of the AGPL v3.  See www.gnu.org/licenses/agpl-3.0.html for details.
# Resist intellectual serfdom - the ownership of ideas is akin to slavery.
#

heroku create $1
heroku addons:add newrelic:standard
git push heroku master
