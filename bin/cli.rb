#!/bin/env ruby
# ~ encoding: utf-8 ~
require 'thor'
require 'pp'
require 'colorize'

$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'gepeto/env'
require 'gepeto/commands/lint_command'
require 'gepeto/commands/rpmbuild_command'

class Cli < Thor
  include LintCommand
  include RpmBuildCommand

  protected
  def gepeto_root
    File.expand_path( File.join( File.dirname(__FILE__), '..'))
  end
end

Cli.start(ARGV)
