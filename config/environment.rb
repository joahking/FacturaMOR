# -*- coding: utf-8 -*-
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  config.action_controller.session = {
    :key => "_facturagem_session",
    :secret => "ooHinEnIrijyesDekjonpharotNisItHewpozfoitDebcugNotvocgerphyiabNi"
  }

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Madrid'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

# Hack to prototype in Spanish, we'll add l10n-simplified when dates etc. are localized.
# ActiveRecord::Errors.default_error_messages = {
#   :inclusion           => "no está incluido en la lista",
#   :exclusion           => "está reservado",
#   :invalid             => "no es válido",
#   :confirmation        => "no coincide con la confirmación",
#   :accepted            => "debe ser aceptado",
#   :empty               => "no puede estar vacío",
#   :blank               => "no puede estar en blanco",# alternate, formulation: "is required"
#   :too_long            => "es demasiado largo (el máximo es %d caracteres)",
#   :too_short           => "es demasiado corto (el mínimo es %d caracteres)",
#   :wrong_length        => "no tiene la longitud requerida (debería ser de %d caracteres)",
#   :taken               => "ya está ocupado",
#   :not_a_number        => "no es un número",
#   :error_translation   => "error",
#   :error_header        => "%s no permite guardar %s",
#   :error_subheader     => "Ha habido problemas con los siguientes campos:"
# }

class Logger
  def format_message(severity, timestamp, progname, msg)
    "[#{timestamp.strftime('%Y/%m/%d %H:%M:%S')}] (#{$$}) [#{severity}]: #{msg}\n"
  end
end

class ActiveRecord::ConnectionAdapters::Column
  class << self
    alias :original_value_to_decimal :value_to_decimal
    def value_to_decimal(v)
      if v.is_a?(String)
        # We try first our parsing because the original method always
        # returns a BigDecimal and there's no way AFAIK to know whether
        # the constructor ignored part of the string. For example "1,3"
        # gives 1, whereas we want 1.3.
        FacturagemUtils.parse_decimal(v)
      else
        original_value_to_decimal(v)
      end
    end

    # This method is called both when dates are set in the model, and
    # when dates are loaded from the database. So we let the original
    # parser do its job, and give a chance to ours if it fails.
    alias :original_string_to_date :string_to_date
    def string_to_date(v)
      if v.is_a?(String) && v =~ %r{^\d+/\d+/\d+$}
        FacturagemUtils.parse_date(v)
      else
        original_string_to_date(v)
      end
    end
  end
end

class String
  # It increases the leftmost integer found in the String. For example we get
  # "F10" as "F9".isucc, whereas standard "F9".succ gives "G0".
  def isucc
    self.dup.isucc!
  end

  def isucc!
    sub!(/\d+/) {|i| i.succ}
  end
end

class NilClass
  # When we negate a discount or IRPF we don't want to depend on whether it
  # is nil or not, we define minus nil to be nil.
  def -@
    nil
  end
end

# This hack prevents form helpers from puttin a fieldWithErrors DIV around
# field with errors. That introduced breaks if the field happened to have
# something to its right as a help icon.
ActionView::Base.field_error_proc = lambda {|html_tag, instance| html_tag}
