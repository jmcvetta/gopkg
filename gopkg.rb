# Copyright (c) 2013 Jason McVetta.  This is Free Software, released under the
# terms of the AGPL v3.  See www.gnu.org/licenses/agpl-3.0.html for details.
# Resist intellectual serfdom - the ownership of ideas is akin to slavery.


require 'git_http'
require 'tmpdir'
require 'uri'


class GoPkg
  class App < GitHttp::App
    
    #@@github_pat = '^/github\.com/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+)/(tag|branch|rev)/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+.git)*$'
    @@github_pat = '^/github\.com/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+)/(tag)/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+).git*$'

    def call(env)
      puts '--------------------------------------------------------------------------------'
      @env = env
      @req = Rack::Request.new(env)
      
      cmd, path, @reqfile, @rpc = match_routing
      puts 'cmd: ' + cmd
      if cmd == 'not_allowed'
        puts 'not allowed: ' + cmd
        return render_method_not_allowed 
      end
      return render_not_found if !cmd

      #
      # Fetch the git tag
      #
      
      m = path.match(@@github_pat)
      puts 'm:'
      puts m
      if !m
        puts 'bad request - no match'
        return render_bad_request 
      end
      user = m[1]
      repo = m[2]
      variant = m[3] # tag branch or revision
      specifier = m[4]
      check_repo = m[5]
      github_repo = 'github.com/' + user + '/' + repo + '.git'
      # git on heroku chokes if we use http://github.com/...
      clone_cmd = "clone --bare --branch #{specifier} git://#{github_repo} ."
      checkout = File.join(Dir.tmpdir(), 'github.com', user, repo, variant, specifier, repo)
      puts 'user: ' + user
      puts 'repo: ' + repo
      puts 'variant: ' + variant
      puts 'specifier: ' + specifier
      puts 'check_repo: ' + check_repo
      puts 'clone_cmd: ' + clone_cmd
      puts 'checkout: ' + checkout
      if check_repo != repo
        puts 'bad request - check_repo'
        return render_bad_request 
      end
      
      if !File.exists?(File.join(checkout, 'objects')) 
        puts 'does not exist'
        `mkdir -p #{checkout}`
        Dir.chdir(checkout) do
          clone = git_command(clone_cmd)
          res = `#{clone}`
          puts res
        end
      end

      @dir = checkout
      puts @dir
      return render_not_found if !@dir

      Dir.chdir(@dir) do
        self.method(cmd).call()
      end
    end
    
    def render_bad_request
      [400, PLAIN_TYPE, ["Bad Request"]]
    end

  end
end