module Blank
  class Railtie < ::Rails::Railtie
    initializer 'blank.assets' do |app|
       app.config.assets.paths.unshift(*paths["app/assets"].existent_directories)
    end

    def paths
      @paths ||= begin
        paths = Rails::Paths::Root.new(root)
        paths.add 'app/assets', glob: '*'
        paths
      end
    end

    def root
      File.dirname(__FILE__)
    end

  end
end
