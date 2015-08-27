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
    repo_root_path = File.expand_path(repo_root_path)
    app_name       = File.basename(repo_root_path)
    bundler_cache_dir  = File.join("/tmp/cache/bundler", app_name)
    yum_cache_dir  = File.join("/tmp/cache/yum")
    dockerfile     = File.join(gepeto_root, "config/rpmbuild/Dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpmbuild/build.sh")
    extrarepo_file = File.join(gepeto_root, "config/extra_repo.repo")
    container_path = File.join("/tmp/gepeto/#{app_name}")
    run_cmds [
      "mkdir -p '#{container_path}'",
      "mkdir -p '#{bundler_cache_dir}'",
      "mkdir -p '#{yum_cache_dir}'",
      "cp -f '#{dockerfile}' '#{buildfile}' '#{extrarepo_file}' '#{container_path}'",
      "cd '#{container_path}' && docker build -t #{app_name}.rpmbuild .",
      [
        "docker run --rm=true -t",
        "-v #{repo_root_path}:/root/rpmbuild/SOURCES/code",
        "-v #{bundler_cache_dir}:/bundler_cache_dir",
        "-v #{yum_cache_dir}:/var/cache/yum/",
        "#{app_name}.rpmbuild"
      ].join(' '),
      "mv -f #{repo_root_path}/*.rpm #{container_path}",
      "mv -f #{repo_root_path}/*.bz2 #{container_path}",
      "find #{container_path} # Arquivos gerados:"
    ]
  end
end
