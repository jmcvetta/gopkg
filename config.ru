use Rack::ShowExceptions

require './gopkg'

config = {
  :project_root => "/app",
  :git_path => '/usr/bin/git',
  :upload_pack => true,
  :receive_pack => true,
}

run GoPkg::App.new(config)