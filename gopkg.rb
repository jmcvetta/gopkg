require 'git_http'

class GoPkg
  class App < GitHttp::App
    
    def call(env)
      @env = env
      @req = Rack::Request.new(env)
      
      cmd, path, @reqfile, @rpc = match_routing
      puts match_routing
      
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
      path = File.join(ENV['PWD'], 'example.git')
      puts path
      if File.exists?(path) # TODO: check is a valid git directory
        return path
      end
      puts 'false'
      false
    end
    
    def get_info_refs
      service_name = get_service_type
      puts service_name

      if has_access(service_name)
        cmd = git_command("#{service_name} --stateless-rpc --advertise-refs .")
        refs = `#{cmd}`

        @res = Rack::Response.new
        @res.status = 200
        @res["Content-Type"] = "application/x-git-%s-advertisement" % service_name
        hdr_nocache
        @res.write(pkt_write("# service=git-#{service_name}\n"))
        @res.write(pkt_flush)
        @res.write(refs)
        @res.finish
      else
        dumb_info_refs
      end
    end
  end
  
end