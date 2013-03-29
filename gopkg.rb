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
      #@reqfile = 'example.git'

      return render_method_not_allowed if cmd == 'not_allowed'
      return render_not_found if !cmd

      @dir = get_git_dir(path)
      return render_not_found if !@dir

      Dir.chdir(@dir) do
        self.method(cmd).call()
      end
    end

    def get_git_dir(path)
      root = @config[:project_root] || `pwd`
      #path = File.join(root, path)
      path = File.join(root, 'example.git')
      if File.exists?(path) # TODO: check is a valid git directory
        return path
      end
      false
    end
    
  end
end