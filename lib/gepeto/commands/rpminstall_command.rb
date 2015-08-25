module RpmInstallCommand
  def self.included(base)
    base.class_eval do
      desc "rpminstall <RPM_PATH>", "Instala rpm indicado em container docker"
      def rpminstall(*args)
        do_rpminstall(*args)
      end
    end
  end

  protected
  def do_rpminstall(rpm_path)
    rpm_path = File.expand_path(rpm_path)
    rpm_dir = File.dirname(rpm_path)
    extrarepo_file = File.join(gepeto_root, "config/extra_repo.repo")
    dockerfile     = File.join(gepeto_root, "config/rpminstall/Dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpminstall/entrypoint.sh")
    yum_cache_dir  = File.join("/tmp/cache/yum")
    container_name = File.basename(rpm_path).gsub(/-\d.*/,'' ) + '.rpminstall'

    Dir.mktmpdir do |root_dir|
      run_cmds [
        "mkdir -p '#{yum_cache_dir}'",
        "cp -fv '#{dockerfile}' '#{buildfile}' '#{extrarepo_file}' '#{root_dir}'",
        "cd '#{root_dir}' && docker build -f Dockerfile -t #{container_name} .",
        [
          "cd '#{root_dir}' && ",
          "docker run --rm=true -ti ",
          "-v #{yum_cache_dir}:/var/cache/yum/",
          "-v #{rpm_dir}:/rpminstall",
          "-e RPM_TO_INSTALL='/rpminstall/#{File.basename(rpm_path)}'",
          "#{container_name}"
        ].compact.join(' ')
      ]
    end
  end
end
