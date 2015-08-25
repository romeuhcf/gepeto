class PuppetSrtucturePlugin < Gepeto::LintPlugin
  def call(env, puppet, repo)
    modulename = File.basename(puppet)

    files = ['manifests/init.pp', 'manifests/install.pp', "../../manifests/#{modulename}.pp", "../../hiera/#{modulename}.yaml"]
    dirs = ['.', 'manifests']

    files.each do |entry|
      entry = File.expand_path(File.join(puppet, entry))
      env.errors.add(:puppet, entry, nil,nil, "Deveria existir arquivo '#{entry}'") unless File.exists?(entry) and File.file?(entry)
    end

    dirs.each do |entry|
      entry = File.expand_path(File.join(puppet, entry))
      env.errors.add(:puppet, entry, nil,nil, "Deveria existir diretório '#{entry}'") unless File.exists?(entry) and  File.directory?(entry)
    end

    initpp = File.expand_path(File.join(puppet, 'manifests/init.pp'))
    if File.exists?(initpp)
      content = IO.read(initpp)
      lines = content.lines
      classline = (lines.grep( /^\s*class /) - lines.grep('::')).first
      env.errors.add(:puppet, initpp, classline, 2, "Puppet class deveria ser '#{modulename.red}'") unless classline =~ /class\s+#{modulename}/
      env.errors.add(:puppet, initpp, classline, 2, "Puppet init deveria conter '#{modulename}_begin'") unless content =~/#{modulename}_begin/
      env.errors.add(:puppet, initpp, classline, 2, "Puppet init deveria conter '#{modulename}_end'") unless content =~/#{modulename}_end/
    end
  end
end

