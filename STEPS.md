# Passo a passo
Passos a serem executados para se criar um pacote rpm, rodar o puppet e instalar o pacote numa máquina virtual docker
* É necessário ter serviço docker rodando na localhost
* Projeto para referência: git clone git@bitbucket.org:abrilmdia/exame-api.git
* puppet 3 novo: git@bitbucket.org:abrilmdia/puppet-manifests.git (CRIE SEU FORK E FAÇA PULL REQUEST)

## Passo 1

### Criar Makefile
Criar o arquivo Makefile na raiz do projeto em questão se não existir, baseado no projeto exame-api

- SUGESTÃO:
Colocar a linha no prepare-spec logo antes de escrever o changelog (isto faz com que nao tenha mais erro de changelog quando for gerar o build)
echo '%changelog' >> $(WORKDIR)/$(SPECFILE)

### Criar arquivo .spec
Criar arquivo .spec (spec file) na raiz do projeto tendo como modelo base o do exame-api ou alterar o existente para o modelo novo (/opt/abril)

### Para usar ruby 1.8
Criar um arquivo .extra_repos com `ruby18` na primeira linha. Isso irá adicionar o repositório correto para a construção e instalação do pacote.


## Passo 2

### Verificar puppet antigo
$ git clone ssh://ec2-user@git.puppetmaster-desenv.abrilcloud.com.br:5022/opt/puppet

- Analisar repos necessários para a instalação do pacote em questão


## Passo 3

### GEPETO: Rpm build
Geração do RPM apartir do repositorio indicado

    ruby bin/cli.rb rpmbuild <REPOSITORY_DIR>

- O pacote é salvo na sua pasta var do projeto gepeto
- Se algum pacote (BuildRequire) da sua .spec não for encontrado, editar o arquivo extra_repo.repo neste projeto e adicionar seu repo conforme exemplos.
- Se der erro de changelog, apagar tudo abaixo de %changelog na sua spec (manter uma linha vazia abaixo).
- Continuar executando o rpmbuild até que o pacote seja gerado sem problemas. (O pacote é gerado na raiz do projeto em questão).


### GEPETO: Rpm install
Geração e instalação do RPM apartir do repositorio indicado

    ruby bin/cli.rb rpminstall <RPM_FILE> <REPOSITORY_DIR>

- Neste ponto, se tudo correr bem, você acabará dentro da maquina virtual com o pacote instalado
- Testar: rpm -qa | grep NOME DO PROJETO e verificar se foi instalado conforme gerado.


## Passo 4

### Projeto puppet-manifests

## Criar o modulo no puppet referente a seu projeto tendo como modelo o modulo exameapi

## Passo 5

### GEPETO: puppet lint

## Rodar o lint e arrumar os erros apresentados
    ruby bin/cli.rb lint -p <MODULE_DIR> -r <REPOSITORY_DIR>

## rodar o puppet para instalar o ultimo package gerado e entrar na maquina
    ruby bin/cli.rb puppet <PUPPET_DIR> <PUPPET_MODULE> -e [app_environment] -p [rpm a ser instalado no fim]


