module Gepeto
  class Repository
    attr_accessor :repo_root_path

    def initialize(repo_root_path)
      self.repo_root_path = File.expand_path(repo_root_path)
    end

    def app_name
      File.basename(repo_root_path)
    end

    def root_path
      self.repo_root_path
    end

    def extra_repo(gepeto_root)
      read_extra_repos("#{self.repo_root_path}/.extra_repos")
    rescue
      puts 'Usando repositório padrão'
      read_extra_repos("#{gepeto_root}/config/extra_repo")
    end

    private

    def read_extra_repos(file)
      repos = []
      File.open(file, 'rb').read.split("\n").each do |repo|
        repo.strip!
        repos << repo unless repo.empty?
      end

      repos
    end
  end
end
