module Blank
  class Railtie < ::Rails::Railtie
    initializer 'blank.assets' do |app|
      app.paths['vendor/assets'] << File.dirname(__FILE__) + '/app/assets/'
    end
  end
end
