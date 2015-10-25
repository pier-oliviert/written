$:.push File.expand_path("../lib", __FILE__)

require "rake/testtask"

task default: %w[test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/ruby/*_test.rb']
  t.verbose = true
end

desc 'Start a rails server for testing and development'
task :server do
  require 'bundler/setup'
  ENV['RAILS_ENV'] ||= 'development'
  Bundler.require(:default, ENV['RAILS_ENV'])

  Dir.chdir 'test/rails' do
    require "rails"
    require 'blank'

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
    require_relative 'test/rails/application'

    server = Rails::Server.new
    server.options[:Port] ||= 3000
    server.options[:Host] ||= '0.0.0.0'
    server.options[:server] = 'thin'

    server.start
  end
end
