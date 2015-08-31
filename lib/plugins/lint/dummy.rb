class WelcomePlugin < Gepeto::LintPlugin
  def call(env, puppet, repo)
    puts ['Validando modulo', puppet, 'e repo', repo, 'com', env.plugins.count.to_s.blue, 'plugins'].join(' ')
  end
end

