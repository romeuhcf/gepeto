require 'gepeto/repository'

module RpmBuildCommand
  def self.included(base)
    base.class_eval do
      desc "rpmbuild <REPO_DIR>", "Usa docker para criar rpm como o koji faria"
      def rpmbuild(*args)
        do_rpmbuild(*args)
      end
    end
  end

  protected
  def do_rpmbuild(repo_root_path)
    repository = Gepeto::Repository.new(repo_root_path)

    app_name       = repository.app_name
    bundler_cache_dir  = File.join(gepeto_root, "var/cache/bundler", app_name)
    yum_cache_dir  = File.join(gepeto_root, "var/cache/yum")
    dockerfile     = File.join(gepeto_root, "config/rpmbuild/Dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpmbuild/build.sh")
    container_path = File.join(gepeto_root, "var/#{app_name}")
    run_cmds [
      "mkdir -p '#{container_path}'",
      "mkdir -p '#{bundler_cache_dir}'",
      "mkdir -p '#{yum_cache_dir}'",
      "cp -f '#{dockerfile}' '#{buildfile}' '#{container_path}'",
      "cd '#{container_path}' && docker build -t #{app_name}.rpmbuild .",
      [
        "docker run --rm=true -t",
        "-v #{repo_root_path}:/code",
        "-v #{bundler_cache_dir}:/bundler_cache_dir",
        "-v #{yum_cache_dir}:/var/cache/yum/",
        "-v #{container_path}:/container_path",
        "-e 'EXTRA_REPOS=#{repository.extra_repo(gepeto_root).join(' ')}'",
        "#{app_name}.rpmbuild"
      ].join(' '),
      "find #{container_path} # Arquivos gerados:"
    ]
  end
end
