# To ease development local configuration is not in SVN.
# A file config/local_config.rb is expected with configuration,
# see config/local_config.rb.example.
local_config_rb = File.join(RAILS_ROOT, 'config', 'local_config.rb')
if not File.exists?(local_config_rb)
  puts "Missing config/local_config.rb, aborting"
  exit 1
end
require local_config_rb

facturagem_yml = File.join(RAILS_ROOT, 'config', 'facturagem.yml')
if not File.exists?(facturagem_yml)
  puts "Missing config/facturagem.yml, aborting"
  exit 1
end

CONFIG = YAML::load(File.open(facturagem_yml))

mailer_rb = File.join(RAILS_ROOT, 'config', 'mailer.rb')
if not File.exists?(mailer_rb)
  puts "Missing config/mailer.rb, aborting"
  exit 1
end
require mailer_rb
