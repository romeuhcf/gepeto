#!/bin/env ruby
# ~ encoding: utf-8 ~
require 'thor'
require 'pp'
require 'colorize'

class Error
  attr_accessor :scope, :file, :content, :lineno, :message
  def initialize(scope, file, content, lineno, message)
    @scope   = scope
    @file    = file
    @content = content
    @lineno  = lineno
    @message = message
  end
end

class ErrorList < Array
  def add(*args)
    self << Error.new(*args)
  end
end

class LintPlugins
  @@plugins = []

  def self.register(implementation)
    @@plugins << implementation
  end

  def self.inherited(base)
    register(base)
  end

  def self.all
    @@plugins.map do |plugin|
      if plugin.respond_to? :call
        plugin
      elsif plugin.is_a?(Class)
        plugin.new
      end
    end
  end
end

def all_lines_from_dir(dir)
  all = Dir[File.join(dir, '**/*')]
  files =all.select{|e| File.file?(e) }
  files.each do |file|
    File.foreach(file).with_index do |line, lineno|
      line.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
      yield file, line, lineno
    end
  end
end


class Env
  attr_accessor :plugins, :app, :puppet, :repo, :errors

  def initialize(plugins, app, puppet, repo)
    @plugins = plugins
    @app     = app
    @puppet  = puppet
    @repo    = repo
    @errors  = ErrorList.new
  end
end

class Cli < Thor
  desc "lint PUPPET REPO", "Valida conteudo do modulo puppet e do repo do projeto"
  def lint(puppet , repo)
    env = Env.new(plugins, self, puppet, repo)
    plugins.each do |plugin|
      plugin.call(env, puppet, repo)
    end

    print_result(env)
  end


  protected
  def print_result(env)
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
                   LintPlugins.all
                 end
  end
end
Cli.start(ARGV)
