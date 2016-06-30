module WrittenDevApplication
  class Application < Rails::Application
    config.eager_load = false
    secrets.secret_key_base = "Something not so secret :)"
    #config.logger = ActiveSupport::Logger.new('/dev/null')
    config.assets.debug = true

    if Rails.env.test?
      paths['app/assets'] << '../browser'
    end

    Specter::Engine.paths['test/javascript'] = Pathname.new(Rails.root) + '../javascript'
  end
end
