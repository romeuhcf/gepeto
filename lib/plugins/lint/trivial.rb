on(:any_line) do |env, scope, file, line, lineno|
  env.errors.add(scope, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
end

on(:puppet_line) do |env, scope, file, line, lineno|
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar usuários - mover para spec") if line =~ /useradd|adduser/
  env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar grupos - mover para spec") if line =~ /groupadd|addgroup/
end
