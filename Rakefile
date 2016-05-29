$:.push File.expand_path("../lib", __FILE__)

require "rake/testtask"

task default: %w[test]


namespace :test do

  Rake::TestTask.new do |t|
    t.name = 'ruby'
    t.description = 'Run Ruby tests'
    t.verbose = true

    t.test_files = FileList['test/ruby/*_test.rb']

    t.libs << "test"
  end
end

desc 'Run all tests'
task test: ['test:ruby', 'test:javascript']

desc 'Start a rails server for testing and development'
task :server do
  require 'bundler/setup'
  ENV['RAILS_ENV'] ||= 'development'
  Bundler.require(:default, ENV['RAILS_ENV'])

  Dir.chdir 'test/server' do
    require "rails"
    require 'written'

    %w(
      action_controller
      action_view
      sprockets
    ).each do |framework|
      begin
        require "#{framework}/railtie"
      rescue LoadError
      end
    end

    Rails.env = ENV['RAILS_ENV']
    require 'rails/commands/server'
    require_relative 'test/server/application'

    server = Rails::Server.new
    server.options[:Port] ||= 3000
    server.options[:Host] ||= '0.0.0.0'
    server.options[:server] = 'thin'

    server.start
  end
end

desc 'Compile assets for release'
task :compile do
  require 'bundler/setup'
  ENV['RAILS_ENV'] ||= 'development'
  Bundler.require(:default, ENV['RAILS_ENV'])
  
  environment = Sprockets::Environment.new
  environment.js_compressor = :uglifier

  environment.append_path 'lib/written/app/assets/javascripts'
  environment.append_path 'lib/written/app/assets/stylesheets'

  manifest = Sprockets::Manifest.new(environment, 'build/manifest.json')
  manifest.compile('written.*')


end
