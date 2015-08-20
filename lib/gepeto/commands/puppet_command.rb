module PuppetCommand
  def self.included(base)
    base.class_eval do
      desc "puppet <PUPPET_DIR> <PUPPET_MODULE> [APP_ENVIRONMENT (stage|production|whatever)]", "Usa docker para provisionar maquina com puppet"
      def puppet(*args)
        do_puppet(*args)
      end
    end
  end

  protected
  def do_puppet(puppet_root, puppet_module, app_environment = 'stage')
    puppet_root    = File.expand_path(puppet_root)
    dockerfile     = File.join(gepeto_root, "config/puppet/puppet.dockerfile")
    buildfile      = File.join(gepeto_root, "config/puppet/puppet.sh")

    facter_product  = puppet_module
    facter_environment = app_environment

    Dir.mktmpdir do |root_dir|
      run_cmds [
        "cp -f '#{dockerfile}' '#{buildfile}' '#{root_dir}'",
        "cd '#{root_dir}' && docker build -f puppet.dockerfile -t #{puppet_module}.puppet .",
        [
          "cd '#{root_dir}' && ",
          "docker run --rm=true -ti ",
          "-e PUPPET_MODULE='#{puppet_module}'",
          "-e FACTER_product='#{facter_product}'",
          "-e FACTER_environment='#{facter_environment}'",
          "-v '#{puppet_root}:/etc/puppet'",
          "#{puppet_module}.puppet "
        ].join(' ')
      ]
    end
  end
end
