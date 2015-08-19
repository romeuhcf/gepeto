module RpmBuildCommand
  def self.included(base)
    base.class_eval do
      desc "rpmbuild REPO_DIR", "Usa docker para criar rpm como o koji faria"
      def rpmbuild(*args)
        do_rpmbuild(*args)
      end
    end
  end

  protected
  def do_rpmbuild(repo_root_path)
    repo_root_path = File.expand_path(repo_root_path)
    app_name       = File.basename(repo_root_path)
    cache_root     = "/tmp/cache"
    dockerfile     = File.join(gepeto_root, "config/rpmbuild/rpmbuild.dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpmbuild/build.sh")
    extrarepo_file = File.join(gepeto_root, "config/rpmbuild/extra_repo.repo")
    run_cmds [
      "mkdir -p '#{repo_root_path}/tmp'",
      "cp -f '#{dockerfile}' '#{buildfile}' '#{extrarepo_file}' '#{repo_root_path}/tmp'",
      "mkdir -p #{cache_root}",
      "cd '#{repo_root_path}' && docker build -f tmp/rpmbuild.dockerfile -t #{app_name}.rpmbuild .",
      [
        "docker run --rm=true -t",
        "-v #{repo_root_path}:/root/rpmbuild/SOURCES/code",
        "-v #{cache_root}:/cached_dirs",
        "#{app_name}.rpmbuild"
      ].join(' ')
    ]
  end

  def run_cmds(cmds)
    cmds.each do |cmd|
      puts "\e[34m", "=" * 100, cmd , "=" * 100, "\e[0m"
      system cmd
      raise unless $?.success?
    end
  end
end
