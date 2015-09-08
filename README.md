# Abril Gepeto
uma ferramenta de validação de regras de puppet para os projetos da Abril com o intuito de facilitar a padronização de regras e agilizar a busca e correção de erros.


## Como usar

    gepeto <comando> [parametros]

## Commandos Principais

### Rpm build
Geração do RPM do repositório indicado

    gepeto rpmbuild <REPOSITORY_DIR>

Onde:

* REPOSITORY_DIR: caminho do repositorio do projeto a ser construido

Exemplo:

    gepeto rpmbuild ~/meu-querido-projeto/

Dependências:

* É necessário ter serviço docker rodando na localhost


### Rpm install
Instalação do RPM

    gepeto rpminstall <RPM_PATH> -r <REPOSITORY_DIR>

Onde:

* RPM_PATH: caminho do arquivo RPM gerado com o comando rpmbuild
* REPOSITORY_DIR: caminho do repositorio do projeto a ser construido

Parâmetros:

-r: diretório do repositório


Extra Repos
===========

O projeto deve ter um arquivo .extra_repos com os repositórios extras a serem incluídos. Os projetos
com ruby 1.8, por exemplo, precisam desse arquivo com a linha `ruby18`.

Exemplo:

    gepeto rpminstall ./var/projeto/projeto-1.0.0.el6.rpm ~/projeto/

Dependências:

* É necessário ter serviço docker rodando na localhost


### Puppet
Provisionamento de teste de puppet em docker
    gepeto puppet <PUPPET_DIR> <PUPPET_MODULE> [app_environment] [rpm a ser instalado no fim]

Onde:

* PUPPET_DIR: caminho da raiz do puppet repository clonado.
* PUPPET_MODULE: nome do modulo do puppet a ser provisonado.

Parâmetros:

-e: environment
    ex.: `-e production` (`stage` é o padrão)

-r: role:
    ex.: `-e cms`

-p: rpm:
    Path do rpm gerado (ele é gerado, por padrão, dentro do projeto gepeto)
    ex.: `-p ./var/meuprojeto/projeto1.0.0.0-1.el6.abril.x86_64.rpm`

Exemplo:

    gepeto puppet ~/puppet-manifests/ meuprojeto -e production -r cron

Dependências:

* É necessário ter serviço docker rodando na localhost

### Lint

Validação de estrutura / conteúdo de módulo puppet e projeto

    gepeto lint -p <PUPPET_MODULE_DIR> -r <REPOSITORY_DIR>

Onde:

* PUPPET_MODULE_DIR: caminho do módulo do puppet a ser validado.
* REPOSITORY_DIR: caminho do projeto onde está o arquivo .spec.

Parâmetros:

-p: puppet

-r: repositório


Exemplo:

    gepeto lint ~/projects/puppet/modules/cmsveja ~/projets/cmsveja


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

Para registrar warnings, a chamada é parecida:

```ruby
env.warnings.add(escopo, file, linecontent, line_no, message)
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
