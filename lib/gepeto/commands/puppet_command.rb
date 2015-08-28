module PuppetCommand
  def self.included(base)
    base.class_eval do
      desc "puppet <PUPPET_DIR> <PUPPET_MODULE> [APP_ENVIRONMENT (stage|production|whatever)] [RPM_TO_INSTALL_AFTER]", "Usa docker para provisionar maquina com puppet"
      def puppet(*args)
        do_puppet(*args)
      end
    end
  end

  protected
  def do_puppet(puppet_root, puppet_module, app_environment = 'stage', rpm_path_after = nil)
    puppet_root    = File.expand_path(puppet_root)
    dockerfile     = File.join(gepeto_root, "config/puppet/puppet.dockerfile")
    buildfile      = File.join(gepeto_root, "config/puppet/puppet.sh")
    yum_cache_dir  = File.join(gepeto_root, "var/cache/yum")
    rpm_path_after = rpm_path_after && File.expand_path(rpm_path_after)

    facter_product  = puppet_module
    facter_environment = app_environment

    Dir.mktmpdir do |root_dir|
      run_cmds [
        "mkdir -p '#{yum_cache_dir}'",
        "cp -f '#{dockerfile}' '#{buildfile}' '#{root_dir}'",
        "cd '#{root_dir}' && docker build -f puppet.dockerfile -t #{puppet_module}.puppet .",
        [
          "cd '#{root_dir}' && ",
          "docker run --rm=true -ti ",
          "-e PUPPET_MODULE='#{puppet_module}'",
          "-e FACTER_product='#{facter_product}'",
          "-e FACTER_environment='#{facter_environment}'",
          "-v '#{puppet_root}:/etc/puppet'",
          "-v #{yum_cache_dir}:/var/cache/yum/",
          (rpm_path_after && "-v #{File.dirname(rpm_path_after)}:/rpm_after"),
          (rpm_path_after && "-e RPM_TO_INSTALL_AFTER='/rpm_after/#{File.basename(rpm_path_after)}'"),
          "#{puppet_module}.puppet "
        ].compact.join(' ')
      ]
    end
  end
end
