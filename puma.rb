# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do |index|
  require 'leafy/core/console_reporter'
  # global $registry is set by the master process when preloading app
  reporter = Leafy::Core::ConsoleReporter::Builder.for_registry($registry) do
    output_to STDERR
    shutdown_executor_on_stop true
  end
  offset = 10 / @options[:workers]
  reporter.start((index + 1) * offset, 10) # report every 10 seconds
  puts("started: #{reporter}\n")
end
