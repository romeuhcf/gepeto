Abril Gepeto é uma ferramenta de validação de regras de puppet para os projetos da Abril com o intuito de facilitar a padronização de regras e agilizar a busca e correção de erros.


Como usar
=========

    ruby bin/cli PUPPET_DIRECTORY REPOSITORY

Onde:

* PUPPET_DIRECTORY: caminho do módulo do puppet a ser validado.
* REPOSITORY: caminho do projeto onde está o arquivo .spec.

Exemplo:

    ruby bin/cli.rb lint ~/projects/puppet/modules/cmsveja ~/projets/cmsveja


Estrutura
=========

As regras de validação são plugins armazenados em arquivos .rb dentro da pasta `lib/plugins/lint`. Cada arquivo é dividido em duas partes, uma para validar as regras do puppet e a outra para validar o .spec do repositório.

```ruby
LintPlugins.register ->(env, puppet, repo) do
  all_lines_from_dir(puppet) { |file, line, lineno|
    # Puppet rules
  }

  all_lines_from_dir(repo) { |file, line, lineno|
    # Spec rules
  }
end
```

Exemplo de regra:

    env.errors.add(:puppet, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
