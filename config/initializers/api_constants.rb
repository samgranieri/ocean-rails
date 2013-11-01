# The is the example file
ef = File.join(Rails.root, "config/config.yml.example")

# Only load AWS data if there is an example file
if File.exists?(ef)

  # This is the tailored file, not under source control.
  f = File.join(Rails.root, "config/config.yml")

  puts
  puts "--- Rails.env = #{Rails.env}"
  puts "--- ef = #{ef}"
  puts "--- f = #{f}"

  # If the tailored file doesn't exist, and we're running in test mode
  # (which is the case under TeamCity), use the example file as-is.
  f = (File.exists?(f) && f) || ef # ((Rails.env == 'test') && ef)

  puts "--- LOADING #{f}"
  puts

  # If there is a file to process, do so
  if f
    cfg = YAML.load(File.read(f))
    cfg.merge! cfg.fetch(Rails.env, {}) if cfg.fetch(Rails.env, {})
    cfg.each do |k, v|
      next if k =~ /[a-z]/
      eval "#{k} = #{v.inspect}"
    end
  else
    # Otherwise print an error message and abort.
    puts
    puts "-----------------------------------------------------------------------"
    puts "Constant definition file missing. Please copy config/config.yml.example"
    puts "to config/config.yml and tailor its contents to suit your dev setup."
    puts
    puts "NB: config.yml is excluded from git version control as it will contain"
    puts "    data private to your Ocean system."
    puts "-----------------------------------------------------------------------"
    puts
    abort
  end

end
