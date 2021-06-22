# encoding: UTF-8
# frozen_string_literal: true


require_relative 'lib/ssc.nob/version'


Gem::Specification.new do |spec|
  spec.name        = 'ssc.nob'
  spec.version     = SSCNob::VERSION
  spec.authors     = ['Jonathan Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['GPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/ssc.nob'
  spec.summary     = 'Subspace Continuum Nob (Noble One Bot).'
  spec.description = 'Subspace Continuum Nob (Noble One Bot). Simple chat-log-reading bot in JRuby.'

  spec.metadata = {
    'homepage_uri'    => 'https://github.com/esotericpig/ssc.nob',
    'source_code_uri' => 'https://github.com/esotericpig/ssc.nob',
    'bug_tracker_uri' => 'https://github.com/esotericpig/ssc.nob/issues',
    'changelog_uri'   => 'https://github.com/esotericpig/ssc.nob/blob/master/CHANGELOG.md',
  }

  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = [spec.name]

  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')),
    %W[ Gemfile Gemfile.lock #{spec.name}.gemspec Rakefile ],
    %w[ CHANGELOG.md LICENSE.txt README.md ],
  ].flatten

  spec.platform              = 'java'
  spec.required_ruby_version = '>= 2.5'
  spec.requirements          = ['JRuby']

  spec.add_runtime_dependency 'attr_bool'  ,'~> 0.2'
  spec.add_runtime_dependency 'highline'   ,'~> 2.0'
  spec.add_runtime_dependency 'rainbow'    ,'~> 3.0'
  spec.add_runtime_dependency 'ssc.bot'    ,'~> 0.2'
  spec.add_runtime_dependency 'tty-spinner','~> 0.9'

  spec.add_development_dependency 'bundler' ,'~> 2.2'
  spec.add_development_dependency 'minitest','~> 5.14'
  spec.add_development_dependency 'rake'    ,'~> 13.0'
  spec.add_development_dependency 'warbler' ,'~> 2.0'

  #spec.post_install_message = ''
end
