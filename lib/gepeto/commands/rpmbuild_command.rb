require 'gepeto/repository'
require 'gepeto/run_commands'

class RpmBuildCommand
  include RunCommands

  def validate(repo_root_path)
    fail('Diretório do repo não encotrado') unless File.directory?(repo_root_path)
    specs =  Dir[File.join(repo_root_path, '*.spec')]
    if specs.size > 1
      fail('Mais de um specfile encontrado no repositório')
    elsif specs.size < 1
      fail('Specfile NÃO encontrado no repositório')
    end
  end

  def call(repo_root_path)
    repository = Gepeto::Repository.new(repo_root_path)
    repo_root_path = File.expand_path(repo_root_path)

    app_name       = repository.app_name
    bundler_cache_dir  = File.join(gepeto_cache_root, "var/cache/bundler", app_name)
    maven_cache_dir  = File.join(gepeto_cache_root, "var/cache/maven")
    yum_cache_dir  = File.join(gepeto_cache_root, "var/cache/yum")
    dockerfile     = File.join(gepeto_root, "config/rpmbuild/Dockerfile")
    buildfile      = File.join(gepeto_root, "config/rpmbuild/build.sh")
    container_path = File.join(gepeto_cache_root, "var/#{app_name}")
    run_cmds [
      "mkdir -p '#{container_path}'",
      "mkdir -p '#{maven_cache_dir}'",
      "mkdir -p '#{bundler_cache_dir}'",
      "mkdir -p '#{yum_cache_dir}'",
      "cp -f '#{dockerfile}' '#{buildfile}' '#{container_path}'",
      # Would speed up requirements to build package on docker, but depends on custom repos ... How could we add custom repos via docker?
      # "grep ^BuildRequires #{repo_root_path}/*.spec | sed 's/^BuildRequires:/RUN yum install -y /' >> #{container_path}/#{File.basename(dockerfile)}",
      "cd '#{container_path}' && docker build -t #{app_name}.rpmbuild .",
      [
        "docker run --rm=true -ti",
        "-v #{repo_root_path}:/code",
        "-v #{bundler_cache_dir}:/bundler_cache_dir",
        "-v #{maven_cache_dir}:/root/.m2",
        "-v #{yum_cache_dir}:/var/cache/yum/",
        "-v #{container_path}:/container_path",
        "-e 'EXTRA_REPOS=#{repository.extra_repo(gepeto_root).join(' ')}'",
        "#{app_name}.rpmbuild"
      ].join(' '),
      "find #{container_path} # Arquivos gerados:"
    ]
  end
end

desc "<REPO_DIR> Build RPM package just like KOJI would do".green
command :rpmbuild do |c|
  c.action do |global_options,options,args|
    help_now!("Extra arguments found: '#{args.inspect}'".red.on_yellow) if args.size > 1
    help_now!("Requirement arguments not found: '#{args.inspect}'".red.on_yellow) if args.size < 1
    params = [args.shift]
    cmd = RpmBuildCommand.new
    begin
      cmd.validate(*params)
    rescue
      help_now!($!.message.red.on_yellow)
    end
    cmd.call(*params)
  end
end

