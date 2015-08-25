on(:any_line) do |env, scope, file, line, lineno|
  env.errors.add(scope, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
end

on(:puppet_line) do |env, scope, file, line, lineno|
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar usuários - mover para spec") if line =~ /useradd|adduser/
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar grupos - mover para spec") if line =~ /groupadd|addgroup/
end

on(:repo_line) do |env, scope, file, line, lineno|
  if file =~ /\.spec\z/ and line =~ /%.*attr/ and line.include?('-')
    env.errors.add(:repo, file, line, lineno, "Não deveria usar '-' para definir permissoes. Sugestão, 0640 para arquivos e 0750 para dir")
  end
end
