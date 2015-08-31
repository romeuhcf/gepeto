require 'gepeto/repository'
require 'gepeto/run_commands'
module RpmInstallCommand
  include RunCommands
  def validate(rpm_path, repo_root_path)
    fail('Diretório do repo não encotrado') unless File.directory?(repo_root_path)
    specs =  Dir[File.join(repo_root_path, '*.spec')]
    if specs.size > 1
      fail('Mais de um specfile encontrado no repositório')
    elsif specs.size < 1
      fail('Specfile NÃO encontrado no repositório')
    end

    fail("RPM não encontrado") unless File.file?(rpm_path)
  end

  def call(rpm_path, repo_root_path)
    repository = Gepeto::Repository.new(repo_root_path)
    repo_root_path = File.expand_path(repo_root_path)

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

desc "<RPM> Provision container and install RPM package".green
command :rpminstall do |c|
  c.action do |global_options,options,args|
  c.desc "When informed, use its .extra_repo file to set on yum.repos" # TODO trocar por lista de repos como string e não arquivo para facilitar instrumentação por outros programas

  c.flag [:p,:puppet_dir], :type => String
    help_now!("Extra arguments found: '#{args.inspect}'".red.on_yellow) if args.size > 1
    help_now!("Requirement arguments not found: '#{args.inspect}'".red.on_yellow) if args.size < 1
    params = [args.shift, options[:repo_dir]]
    cmd = RpmBuildCommand.new
    begin
      cmd.validate(*params)
    rescue
      help_now!($!.message.red.on_yellow)
    end
    cmd.call(*params)
  end
end

