#!/usr/bin/env ruby
# ~ encoding: utf-8 ~
require 'thor'
require 'pp'
require 'colorize'

$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'gepeto/env'
require 'gepeto/commands/lint_command'
require 'gepeto/commands/rpmbuild_command'
require 'gepeto/commands/rpminstall_command'
require 'gepeto/commands/puppet_command'

class Cli < Thor
  include LintCommand
  include RpmBuildCommand
  include RpmInstallCommand
  include PuppetCommand

  protected
  def gepeto_root
    File.expand_path( File.join( File.dirname(__FILE__), '..'))
  end

  def run_cmds(cmds)
    cmds.each do |cmd|
      puts "\e[34m", "=" * 100, cmd , "=" * 100, "\e[0m"
      system cmd
      unless $?.success?
        puts ('-' * 100).yellow
        puts "Falha executando '#{cmd}' #{$?}".red
        exit 1
      end
    end
  end
end

Cli.start(ARGV)
