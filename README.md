# Abril Gepeto
uma ferramenta de validação de regras de puppet para os projetos da Abril com o intuito de facilitar a padronização de regras e agilizar a busca e correção de erros.


## Como usar

    ruby bin/cli.rb <comando> [parametros]

## Commandos Principais

### Rpm build
Geração do RPM da do repositorio indicado

    ruby bin/cli.rb rpmbuild <REPOSITORY_DIR>

Onde:

* REPOSITORY_DIR: caminho do repositorio do projeto a ser construido

Exemplo:

    ruby  bin/cli.rb rpmbuild ~/meu-querido-projeto/

Dependências:

* É necessário ter serviço docker rodando na localhost

### Puppet
Provisionamento de teste de puppet em docker
    ruby bin/cli.rb puppet <PUPPET_DIR> <PUPPET_MODULE> [app_environment]

Onde:

* PUPPET_DIR: caminho da raiz do puppet repository clonado.
* PUPPET_MODULE: nome do modulo do puppet a ser provisonado.

Exemplo:

    ruby bin/cli.rb puppet ~/puppet-manifests/ meuprojeto production

Dependências:

* É necessário ter serviço docker rodando na localhost

### Lint 

Validação de estrutura / conteúdo de módulo puppet e projeto

    ruby bin/cli.rb lint <PUPPET_MODULE_DIR> <REPOSITORY_DIR>

Onde:

* PUPPET_MODULE_DIR: caminho do módulo do puppet a ser validado.
* REPOSITORY_DIR: caminho do projeto onde está o arquivo .spec.

Exemplo:

    ruby bin/cli.rb lint ~/projects/puppet/modules/cmsveja ~/projets/cmsveja


#### Estrutura

As regras de validação são plugins armazenados em arquivos .rb dentro da pasta `lib/plugins/lint`. Existem dois tipos de plugin.

* Plugin como classe que recebe os diretórios como parâmetro e pode fazer tratamento cruzando informações, por exemplo, dos puppets, spec e Makefile

```ruby
class WelcomePlugin < Gepeto::LintPlugin
  def call(env, puppet, repo)
    puts ['Validando modulo', puppet.red, 'e repo', repo.red, 'com', env.plugins.count.to_s.blue, 'plugins'].join(' ')
  end
end
```

* Plugin para tratar linhas - Na verdade há um plugin como o acima que varre linha a linha emitindo eventos para que plugins se registrem tratando-as. 
Exemplo de regra:

```ruby
on(:any_line) do |env, scope, file, line, lineno|
  env.errors.add(scope, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
end

on(:puppet_line) do |env, scope, file, line, lineno|
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar usuários - mover para spec") if line =~ /useradd|adduser/
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar grupos - mover para spec") if line =~ /groupadd|addgroup/
end
``` 

#### Emitindo Validações

Os plugins devem registrar os erros encontrados utilizando a chamada:

```ruby
env.errors.add(escopo, file, linecontent, line_no, message)
```

## TODO

* [ ] Validar estrutura do modulo puppet (manifests/init.pp, manifests/config.pp, ...)
* [ ] Validar estrutura do projeto (Makefile, .spec)
* [ ] Identificar tipo de projeto (rails, node, sinatra, java) e verificar dependências no RPM
* [ ] Identificar pacotes requisitados no puppet que deveriam ser movidos para o spec
* [ ] Identificar criação de diretorios no puppet que deveriam estar no spec
* [ ] Identificar arquivos de log em diretorios invalids (http -> /var/log/httpd, aplicação -> /var/log/<aplicacao>
* [ ] Plugin para puppet lint
* [ ] Verificar endereço ip hardcoded no codigo do projeto (ao menos no config)
* [ ] Verificar nome de dominio hardcoded nas configurações do projeto
* [v] Comando para criacao de rpm via docker
* [ ] Comando para instalacao de rpm gerado via docker
* [v] Comando para provisionamento de imagem docker via puppet
