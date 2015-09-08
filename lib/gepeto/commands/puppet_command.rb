require 'tmpdir'
require 'gepeto/run_commands'
class PuppetCommand
  include RunCommands

  def validate(puppet_root, puppet_module, app_environment = 'stage', rpm_path_after = nil, facter_role = nil)
    fail('Diretório do puppet não encotrado') unless File.directory?(puppet_root)
    fail("Favor indicar o módulo puppet a ser aplicado") if puppet_module.to_s.empty?
    fail("RPM não encontrado '#{rpm_path_after}'") if rpm_path_after and !File.file?(rpm_path_after)
  end

  def call(puppet_root, puppet_module, app_environment = 'stage', rpm_path_after = nil, facter_role = nil)
    puppet_root    = File.expand_path(puppet_root)
    dockerfile     = File.join(gepeto_root, "config/puppet/puppet.dockerfile")
    buildfile      = File.join(gepeto_root, "config/puppet/puppet.sh")
    yum_cache_dir  = File.join(gepeto_cache_root, "var/cache/yum")
    rpm_path_after = rpm_path_after && File.expand_path(rpm_path_after)

    facter_product  = puppet_module
    facter_environment = app_environment

    tag = "#{puppet_module}_#{facter_role}"

    Dir.mktmpdir(nil, "#{gepeto_cache_root}/var") do |root_dir|
      run_cmds [
        "mkdir -p '#{yum_cache_dir}'",
        "cp -f '#{dockerfile}' '#{buildfile}' '#{root_dir}'",
        "cd '#{root_dir}' && docker build -f puppet.dockerfile -t #{tag}.puppet .",
        [
          "cd '#{root_dir}' && ",
          "docker run --rm=true -ti ",
          "-e PUPPET_MODULE='#{puppet_module}'",
          "-e FACTER_product='#{facter_product}'",
          (facter_role && "-e FACTER_role='#{facter_role}'"),
          "-e FACTER_environment='#{facter_environment}'",
          "-v '#{puppet_root}:/etc/puppet'",
          "-v #{yum_cache_dir}:/var/cache/yum/",
          (rpm_path_after && "-v #{File.dirname(rpm_path_after)}:/rpm_after"),
          (rpm_path_after && "-e RPM_TO_INSTALL='/rpm_after/#{File.basename(rpm_path_after)}'"),
          "#{tag}.puppet "
        ].compact.join(' ')
      ]
    end
  end
end

desc "<PUPPET_DIR> <PRODUCT|PUPPET_MODULE> Provision a docker container and apply informed puppet on it".green
command :puppet do |c|
  c.desc "facter 'environment' for hiera/puppet"
  c.flag [:e,:environment], type: String, default_value: 'stage'

  c.desc "facter 'role' hiera/puppet"
  c.flag [:r,:role], type: String, default_value: 'web'

  c.desc "optional RPM file to install after puppet run"
  c.flag [:p,:rpm], type: String

  c.action do |global_options,options,args|
    help_now!("Extra arguments found: '#{args.inspect}'".red.on_yellow) if args.size > 2
    help_now!("Requirement arguments not found: '#{args.inspect}'".red.on_yellow) if args.size < 2
    params = [args.shift, args.shift, options[:environment], options[:rpm], options[:role]]
    cmd = PuppetCommand.new
    begin
      cmd.validate(*params)
    rescue
      help_now!($!.message.red.on_yellow)
    end
    cmd.call(*params)

  end
end

