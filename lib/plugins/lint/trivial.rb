on(:any_line) do |env, scope, file, line, lineno|
  env.errors.add(scope, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
end

on(:puppet_line) do |env, scope, file, line, lineno|
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar usuários - mover para spec") if line =~ /useradd|adduser/
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar grupos - mover para spec") if line =~ /groupadd|addgroup/
  env.errors.add(:puppet, file, line, lineno, "Não deveria referenciar ec2_tag_environment, utilizar $::environment ou via hiera") if line.include?('ec2_tag_environment')
  env.errors.add(:puppet, file, line, lineno, "Não deveria referenciar interface de rede. Quem sabe utilizar * ou 0.0.0.0") if line.include?('ipaddress_eth0')
end

on(:repo_line) do |env, scope, file, line, lineno|
  if file =~ /\.spec\z/ and line =~ /%.*attr/ and line.include?('-')
    env.errors.add(:repo, file, line, lineno, "Não deveria usar '-' para definir permissoes. Sugestão, 0640 para arquivos e 0750 para dir")
  end
  env.errors.add(scope, file, line, lineno, "Não deveria usar o oboe") if line.include?('liboboe')
end
