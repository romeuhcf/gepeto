module RpmInstallCommand
  def self.included(base)
    base.class_eval do
      desc "rpminstall <RPM_PATH> <REPO_DIR>", "Instala rpm indicado em container docker"
      def rpminstall(*args)
        do_rpminstall(*args)
      end
    end
  end

  protected

  def do_rpminstall(rpm_path, repo_root_path)
    repository = Repository.new(repo_root_path)

    rpm_path = File.expand_path(rpm_path)
    rpm_dir = File.dirname(rpm_path)
    dockerfile     = File.join(gepeto_root, "config/rpminstall/Dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpminstall/entrypoint.sh")
    yum_cache_dir  = File.join(gepeto_root, "var/cache/yum")
    container_name = File.basename(rpm_path).gsub(/-\d.*/,'' ) + '.rpminstall'

    Dir.mktmpdir do |root_dir|
      run_cmds [
        "mkdir -p '#{yum_cache_dir}'",
        "cp -fv '#{dockerfile}' '#{buildfile}' '#{root_dir}'",
        "cd '#{root_dir}' && docker build -t #{container_name} .",
        [
          "cd '#{root_dir}' && ",
          "docker run --rm=true -ti ",
          "-v #{yum_cache_dir}:/var/cache/yum/",
          "-v #{rpm_dir}:/rpminstall",
          "-e RPM_TO_INSTALL='/rpminstall/#{File.basename(rpm_path)}'",
          "-e 'EXTRA_REPOS=#{repository.extra_repo(gepeto_root).join(' ')}'",
          "#{container_name}"
        ].compact.join(' ')
      ]
    end
  end
end