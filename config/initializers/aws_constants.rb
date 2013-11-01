
# The is the example file
ef = File.join(Rails.root, "config/aws.yml.example")

# Only load AWS data if there is an example file
if File.exists?(ef)

  # This is the tailored file, not under source control.
  f = File.join(Rails.root, "config/aws.yml")
  # If the tailored file doesn't exist, and we're running in production mode
  # (which is the case under TeamCity), use the example file as-is.
  f = File.exists?(f) && f || Rails.env != 'development' && ef

  # If there is a file to process, do so
  if f
    AWS.config YAML.load(File.read(f))[Rails.env]
  else
    # Otherwise print an error message and abort.
    puts
    puts "-----------------------------------------------------------------------"
    puts "AWS config file missing. Please copy config/aws.yml.example"
    puts "to config/aws.yml and tailor its contents to suit your dev setup."
    puts
    puts "NB: aws.yml is excluded from git version control as it will contain"
    puts "    data private to your Ocean system."
    puts "-----------------------------------------------------------------------"
    puts
    abort
  end

end
