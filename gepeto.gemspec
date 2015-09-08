# -*- encoding: utf-8 -*-
# stub: gepeto 0.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "gepeto"
  s.version = "0.0.2"
  s.authors = ["Romeu Fonseca", "Artur Prado", "Jorge Silveira"]
  s.date = "2015-08-31"
  s.summary = "Docker assisted automation tools for package building"
  s.description = "Uma ferramenta de validação de regras de puppet para os projetos da Abril com o intuito de facilitar a padronização de regras e agilizar a busca e correção de erros."
  s.email = ["romeu.fonseca@abril.com,br"]
  s.homepage = "http://lvh.me"
  s.licenses = ["MIT"]

  s.executables = ["gepeto"]
  s.require_paths = ["lib"]
  s.files         = `git ls-files`.split($/)

  s.add_dependency "gli"
  s.add_dependency "colorize"

end
