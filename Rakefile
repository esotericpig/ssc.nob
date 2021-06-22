# encoding: UTF-8
# frozen_string_literal: true


require 'bundler/gem_tasks'

require 'rake/clean'
require 'rake/testtask'
require 'ssc.nob/version'


CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

task default: [:test]

Rake::TestTask.new() do |task|
  task.libs = ['lib','test']
  task.pattern = File.join('test','**','*_test.rb')
  task.description += ": '#{task.pattern}'"
  task.verbose = false
  task.warning = true
end
