# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)
# 
# SSC.Nob is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# SSC.Nob is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with SSC.Nob.  If not, see <https://www.gnu.org/licenses/>.
#++


lib = File.expand_path(File.join('..','lib'),__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ssc.nob/version'


Gem::Specification.new() do |spec|
  spec.name        = 'ssc.nob'
  spec.version     = SSCNob::VERSION
  spec.authors     = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email       = ['bradley@esotericpig.com']
  spec.licenses    = ['GPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/ssc.nob'
  spec.summary     = 'Subspace Continuum Nob (Noble One Bot).'
  spec.description = spec.summary
  
  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/esotericpig/ssc.nob/issues',
    'changelog_uri'   => 'https://github.com/esotericpig/ssc.nob/blob/master/CHANGELOG.md',
    'homepage_uri'    => 'https://github.com/esotericpig/ssc.nob',
    'source_code_uri' => 'https://github.com/esotericpig/ssc.nob',
  }
  
  spec.require_paths = ['lib']
  spec.bindir        = 'bin'
  spec.executables   = [spec.name]
  
  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{test,yard}','**','*.{erb,rb}')),
    %W( Gemfile #{spec.name}.gemspec Rakefile ),
    %w( CHANGELOG.md LICENSE.txt README.md ),
  ].flatten()
  
  spec.platform = 'java'
  spec.required_ruby_version = '>= 2.4'
  #spec.requirements = []
  
  spec.add_runtime_dependency 'attr_bool'  ,'~> 0.1'
  spec.add_runtime_dependency 'highline'   ,'~> 2.0'
  spec.add_runtime_dependency 'rainbow'    ,'~> 3.0'
  spec.add_runtime_dependency 'tty-spinner','~> 0.9'
  
  spec.add_development_dependency 'bundler' ,'~> 2.1'
  spec.add_development_dependency 'minitest','~> 5.14'
  spec.add_development_dependency 'rake'    ,'~> 13.0'
  
  #spec.post_install_message = ''
end
