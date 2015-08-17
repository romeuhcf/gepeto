LintPlugins.register ->(env, puppet, repo) do
  all_lines_from_dir(puppet) { |file, line, lineno|
    env.errors.add(:puppet, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
    env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar usuários - mover para spec") if line =~ /useradd|adduser/
    env.errors.add(:puppet, file, line, lineno, "Não deveria gerenciar grupos - mover para spec") if line =~ /groupadd|addgroup/
  }

  all_lines_from_dir(repo) { |file, line, lineno|
    env.errors.add(:repo, file, line, lineno, "Não deveria referenciar /var/abd - usar /opt/abril") if line.include?('/abd/')
  }
end

