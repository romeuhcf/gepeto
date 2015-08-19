require 'gepeto/lint_plugin'
require 'gepeto/line_scanner_plugin'
include Gepeto::LintEventManager

module LintCommand
  def self.included(base)
    base.class_eval do
      desc "lint PUPPET_MODULE_DIR REPO_DIR", "Valida conteudo do modulo puppet e do repo do projeto"
      def lint(puppet , repo)
        env = Gepeto::Env.new(plugins, self, puppet, repo)
        plugins.each do |plugin|
          plugin.call(env, puppet, repo)
        end
        print_result(env)
      end
    end
  end

  protected
  def print_result(env)
    env.errors.each do |error|
      puts [
        'ERROR:'.red,
        error.message.yellow,
        error.scope.to_s.blue,
        error.file.red,
        error.lineno.to_s.cyan
      ].join(' ')
    end
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
    Dir[File.join(File.dirname(__FILE__),"../lib/plugins/lint/*.rb")].each do |plugin_file|
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
