# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rake/clean'
require 'rake/testtask'
require 'ssc.nob/version'

# If PKG_DIR or JAR_FILE are changed,
#   then 'config/warble.rb' also needs to be changed.
PKG_DIR = 'pkg'
JAR_FILE = File.join(PKG_DIR,'ssc.nob.jar')

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

task default: [:test]

Rake::TestTask.new do |t|
  t.libs = ['lib','test']
  t.pattern = File.join('test','**','*_test.rb')
  t.description += ": '#{t.pattern}'"
  t.options = '--pride'
  t.verbose = true
  t.warning = true
end

desc 'Create a runnable Jar using Warbler for release'
task :jar do |_t|
  puts <<~HELP

    ============================================
    Make sure Warbler is installed:
      [jruby]$ bundler install
      [jruby]$ bundler update
    Or if the above doesn't work:
      [jruby]$ gem install warbler

    If this task fails, try using Bundler:
      [jruby]$ bundler exec rake jar
    Or try using Warbler directly:
      $ warble

    Check 'config/warble.rb' for configuration.
    ============================================

  HELP

  mkdir(PKG_DIR,verbose: true) unless Dir.exist?(PKG_DIR)
  sh('warble')
end

# This doesn't depend on ':jar' task
#   because Warbler naively deletes and creates a new Jar every time.
desc 'Run the Jar created by Warbler'
task :runjar do |_t|
  # Manually create the Jar only if it doesn't exist.
  if !File.exist?(JAR_FILE)
    jar_task = Rake::Task[:jar]

    jar_task.reenable
    jar_task.invoke
  end

  sh('java','-jar',JAR_FILE)
end
