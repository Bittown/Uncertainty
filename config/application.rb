require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GuessingGame
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.autoload_paths << Rails.root.join('lib')

    config.time_zone = 'Beijing'
    config.i18n.load_path += Dir[Rails.root.join(
        'config', 'locales', '**', '*.{rb,yml}')]
    I18n.available_locales = [:cn]
    I18n.default_locale = :cn

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
