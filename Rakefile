$:.push File.expand_path("../lib", __FILE__)

require "rake/testtask"

task default: %w[test]


namespace :test do
  desc 'Run Javascript tests'
  task :javascript do
    require 'rails'
    require 'blank'
    require 'sprockets'
    require 'tempfile'
    environment = Sprockets::Environment.new
    Blank::Railtie.instance.paths['app/assets'].existent.each do |path|
      environment.append_path path
    end

    environment.append_path 'test/javascript'

    test = Tempfile.new 'test.js'
    test.write environment['test.js']
    test.rewind

    runner = Tempfile.new 'runner.js'
    runner.write environment['runner.js']
    runner.rewind

    # Use system so it's possible to know if the tests were successful
    # based on the return value
    system("phantomjs #{runner.path} #{test.path}")
    test.close
    runner.close
  end

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
