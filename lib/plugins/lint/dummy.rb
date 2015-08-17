class WelcomePlugin < LintPlugins
  def call(env, puppet, repo)
    puts ['Validando modulo', puppet.red, 'e repo', repo.red, 'com', env.plugins.count.to_s.blue, 'plugins'].join(' ')
  end
end

