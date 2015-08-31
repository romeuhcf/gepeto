require 'gepeto/lint_plugin'
require 'gepeto/line_scanner_plugin'
require 'gepeto/subcommand'
include Gepeto::LintEventManager

class LintCommand
  def validate(puppet, repo)
    any_dir = false
    if puppet
      if File.directory?(puppet)
        any_dir = true
      else
        fail "Puppet path not found'#{puppet}'"
      end
    end

    if repo
      if File.directory?(repo)
        any_dir = true
      else
        fail "Project path not found '#{repo}'"
      end
    end

    if !any_dir
      fail "No paths given, check parameters!"
    end
  end

  def call(puppet, repo)
    env = Gepeto::Env.new(plugins, self, puppet, repo)
    plugins.each do |plugin|
      plugin.call(env, puppet, repo)
    end
    print_results(env)
  end

  protected

  def print_results(env)
    env.errors.each { |error| print_result(error, '[ERROR]'.red) }
    env.warnings.each { |warning| print_result(warning, '[WARNING]'.yellow) }
  end

  def print_result(error, log_type)
    puts [
      log_type,
      error.message,
      error.scope.to_s.blue,
      error.file.red,
      error.lineno.to_s.cyan
    ].join(' ')
  end

  def print_compressed_result(env)
    message_map = {}
    env.errors.each do |error|
      message_map[error.message] ||= {} # file hash
      message_map[error.message][error.file] ||= []
      message_map[error.message][error.file] << error
    end

    message_map.each do |k, file_map|
      puts k.red
      file_map.each do |file, errors|
        $stdout.print "  "
        puts [file.yellow , errors.map(&:lineno).join(', ')].join(' @ lines: ')
      end
    end

    exit 2 if env.errors.any?
  end

  def load_plugins
    Dir[File.join(File.dirname(__FILE__), "../../plugins/lint/*.rb")].each do |plugin_file|
      load plugin_file
    end
  end

  def plugins
    @plugins ||= begin
                   load_plugins
                   Gepeto::LintPlugin.all
                 end
  end
end

desc 'Validates structure of puppet and/or project spec / rpm and lots of cool stuff'.green
command :lint do |c|
  c.flag [:p,:puppet_dir], :type => String
  c.flag [:r,:repo_dir], :type => String
  c.action do |global_options,options,args|
    help_now!("Extra arguments found: '#{args.inspect}'".red.on_yellow) if args.any?
    params = [options[:puppet_dir], options[:repo_dir]]
    cmd = LintCommand.new
    begin
      cmd.validate(*params)
    rescue
      help_now!($!.message.red.on_yellow)
    end
    cmd.call(*params)
  end
end
