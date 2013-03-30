# Copyright (c) 2013 Jason McVetta.  This is Free Software, released under the
# terms of the AGPL v3.  See www.gnu.org/licenses/agpl-3.0.html for details.
# Resist intellectual serfdom - the ownership of ideas is akin to slavery.


require 'git_http'
require 'tmpdir'
require 'uri'
require 'fileutils'


class GoPkg
  class App < GitHttp::App
    
    #@@github_pat = '^/github\.com/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+)/(tag|branch|rev)/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+.git)*$'
    @@github_pat = '^/github\.com/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+)/(tag)/([A-Za-z0-9_.\-]+)/([A-Za-z0-9_.\-]+)$'

    def call(env)
      @env = env
      @req = Rack::Request.new(env)
      
      cmd, path, @reqfile, @rpc = match_routing
      return render_method_not_allowed if cmd == 'not_allowed'
      return render_not_found if !cmd

      m = path.match(@@github_pat)
      return render_bad_request if !m
      user = m[1]
      repo = m[2]
      variant = m[3] # tag branch or revision
      specifier = m[4]
      check_repo = m[5]
      return render_bad_request if check_repo != repo
      
      # git on heroku chokes if we use http://github.com/...
      github_repo = 'git://github.com/' + user + '/' + repo + '.git'
      checkout = File.join(Dir.tmpdir(), 'github.com', user, repo, variant, specifier, repo)
      
      if !File.exists?(File.join(checkout)) || File.ctime(checkout) < Time.now - 120
        FileUtils.rm_rf(checkout)
        `mkdir -p #{checkout}`
        Dir.chdir(checkout) do
          git_cmds = [
            "init .",
            "remote add other #{github_repo}",
            "fetch other",
            "merge #{specifier}",
            "remote rm other",
          ]
          git_cmds.each do |s|
            gitcmd = git_command(s)
            `#{gitcmd}`
            #`#{gitcmd} 2>&1 > /dev/null`
          end
        end
      end

      @dir = checkout
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