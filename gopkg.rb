require 'git_http'

class GoPkg
  class App < GitHttp::App
    
    def call(env)
      @env = env
      @req = Rack::Request.new(env)
      
      cmd, path, @reqfile, @rpc = match_routing
      
      #
      # TODO: Fetch the required git tag
      #
      @reqfile = 'example.git'

      return render_method_not_allowed if cmd == 'not_allowed'
      return render_not_found if !cmd

      @dir = get_git_dir(path)
      return render_not_found if !@dir

      Dir.chdir(@dir) do
        self.method(cmd).call()
      end
    end

  end
end