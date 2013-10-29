f = File.join(Rails.root, "config/aws.yml")
ef = File.join(Rails.root, "config/aws.yml.example")

f = File.exists?(f) && f || 
    File.exists?(ef) && Rails.env == 'production' && ef

if f
  AWS.config YAML.load(File.read(f))[Rails.env]
else
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


