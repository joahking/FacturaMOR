if RAILS_ENV == 'production'
  #Change to true to work with SSL and uncomment lines in controllers
  #containing this_controller_only_responds_to_https
  USE_SSL = false
  # Trigger controller class loading to execute SSL-related
  # declarations, this way we have the correct links right away.
  require 'application'
  ActionController::Routing.possible_controllers.each do |c|
     # known to work without directories
    "#{c.camelize}Controller".constantize
  end
  XSendFile::Plugin.replace_send_file!
else
  USE_SSL = false
end
