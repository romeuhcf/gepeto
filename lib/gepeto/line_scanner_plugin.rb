require 'gepeto/lint_plugin'
require 'gepeto/lint_event_manager'
module Gepeto
  class LineScannerPlugin < LintPlugin
    def call(env, puppet, repo)

      all_lines_from_dir(puppet) { |file, line, lineno|
        emit_event(:any_line, env, :puppet, file, line, lineno)
        emit_event(:puppet_line, env, :puppet, file, line, lineno)
      }

      all_lines_from_dir(repo) { |file, line, lineno|
        emit_event(:line, env, :repo, file, line, lineno)
        emit_event(:repo_line, env, :repo, file, line, lineno)
      }
    end

    protected
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
  end
end
