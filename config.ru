# Copyright (c) 2013 Jason McVetta.  This is Free Software, released under the
# terms of the AGPL v3.  See www.gnu.org/licenses/agpl-3.0.html for details.
# Resist intellectual serfdom - the ownership of ideas is akin to slavery.

use Rack::ShowExceptions

require './gopkg'

if ENV['RACK_ENV'] == 'production'
  require 'newrelic_rpm'
  require 'new_relic/agent/instrumentation/rack'
  GoPkg::App.class_eval do
    include NewRelic::Agent::Instrumentation::Rack
  end
end


config = {
  :project_root => "/app",
#  :git_path => '/app/bin/bin/git',
  :upload_pack => true,
  :receive_pack => true,
}

run GoPkg::App.new(config)
