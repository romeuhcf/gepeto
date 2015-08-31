require 'colorize'
module RunCommands

  def gepeto_root
    @_gepeto_root ||= File.expand_path(File.join( File.dirname(__FILE__), '../../'))
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
