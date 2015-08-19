#!/bin/env ruby
# ~ encoding: utf-8 ~
require 'thor'
require 'pp'
require 'colorize'
$:.unshift File.join(File.dirname(__FILE__), '../lib')

require 'gepeto/env'
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
    dockerfile     = File.join(gepeto_root, "config/dockerfiles/rpmbuild.dockerfile")
    run_cmds [
      "cd '#{repo_root_path}' && docker build -f #{dockerfile} -t #{app_name}.rpmbuild .",
      "mkdir -p #{cache_root}",
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

class Cli < Thor
  include LintCommand
  include RpmBuildCommand

  protected
  def gepeto_root
    File.expand_path( File.join( File.dirname(__FILE__), '..'))
  end
end
Cli.start(ARGV)
