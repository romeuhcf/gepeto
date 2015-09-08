#!/usr/bin/env ruby
# ~ encoding: utf-8 ~
require 'gli'
require 'pp'
require 'colorize'

$:.unshift File.join(File.dirname(__FILE__), '../lib')
require 'gepeto/env'
require 'gepeto/subcommand'

include GLI::App
program_desc 'Gepetooooooooooooo'

Gepeto::Subcommand.load_all


exit run(ARGV)
