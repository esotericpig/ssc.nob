#!/usr/bin/env ruby
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


require 'java'
require 'psych'

require 'ssc.nob/error'
require 'ssc.nob/userface'
require 'ssc.nob/util'

java_import 'java.awt.event.KeyEvent'


module SSCNob
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class Config
    include Uface
    
    attr_reader :file
    attr_accessor :msg_key
    attr_accessor :ssc_dir
    attr_accessor :username
    
    def initialize(file='ssc.nob.yml')
      super()
      
      @file = File.expand_path(file)
      @msg_key = nil
      @ssc_dir = nil
      @username = nil
    end
    
    def build_msg_key()
      # Can be a single space ' '.
      return @msg_key if @msg_key.nil?() || @msg_key.length == 1
      
      fuzzy_key = Util.strip(@msg_key).downcase()
      
      if fuzzy_key.empty?()
        @msg_key = nil
        
        return @msg_key
      end
      
      KeyEvent.constants.each() do |c|
        name = c.to_s().downcase()
        
        if name.start_with?('vk_') && name.include?(fuzzy_key)
          return KeyEvent.const_get(c)
        end
      end
      
      raise UserError,"that's an invalid msg key{#{@msg_key}}, user."
    end
    
    def build_ssc_log_dir()
      return File.join(@ssc_dir,'logs')
    end
    
    def check_msg_key()
      build_msg_key()
    end
    
    def check_ssc_dir()
      @ssc_dir = Util.strip(@ssc_dir)
      
      if @ssc_dir.nil?() || @ssc_dir.empty?()
        raise UserError,"that's a blank folder name, user."
      end
      
      @ssc_dir = File.expand_path(@ssc_dir)
      
      if !Dir.exist?(@ssc_dir)
        raise UserError,"that folder{#{@ssc_dir}} doesn't exist, user."
      end
      if !File.directory?(@ssc_dir)
        raise UserError,"that's a file{#{@ssc_dir}}, not a folder, user."
      end
      
      ssc_log_dir = build_ssc_log_dir()
      
      if !Dir.exist?(ssc_log_dir) || !File.directory?(ssc_log_dir)
        raise UserError,"why's there no 'logs' folder{#{ssc_log_dir}}, user?"
      end
    end
    
    def check_username()
      raise UserError,"that's a blank username, user." if Util.blank?(@username)
    end
    
    def load_file!(mode: 'rt:BOM|UTF-8',**kargs)
      data = File.read(@file,mode: mode,**kargs)
      
      yaml = Psych.safe_load(data,
        aliases: false,
        filename: @file,
        permitted_classes: [Symbol],
        symbolize_names: true,
        **kargs,
      )
      
      @msg_key = yaml[:msg_key]
      @ssc_dir = Util.strip(yaml[:ssc_dir])
      @ssc_dir = File.expand_path(@ssc_dir) if !@ssc_dir.nil?() && !@ssc_dir.empty?()
      @username = yaml[:username]
    end
    
    def save_file(mode: 'wt',**kargs)
      File.open(@file,mode: mode,**kargs) do |fout|
        fout.write(to_s())
      end
    end
    
    def user_init!()
      if File.exist?(@file)
        load_file!()
      end
      
      if valid?()
        uface.type("Welcome back, ")
        puts "#{uface.user(@username)}."
        uface.type("Here's a hot cup of coffee: ")
        puts uface.coffee
      else
        uface.types('Welcome, new user.')
        puts
        
        @username = uface.ask("What's your #{uface.user('username')}? ")
        check_username()
        
        @ssc_dir = uface.ask("Where's your #{uface.ssc} folder? ")
        check_ssc_dir()
        
        puts <<~EOM
          What's your #{uface.color('Message Key').aqua.bold}?
          - Can input a letter, like 'm'
          - Can input a key code, like 'VK_TAB' or 'TAB'
          - Can input nothing
        EOM
        #'
        @msg_key = uface.ask('> ')
        check_msg_key()
        
        puts
        puts uface.gt(@file)
        if uface.agree('Save this configuration (y/n)? ')
          save_file()
        end
      end
    end
    
    def valid?()
      begin
        check_msg_key()
        check_ssc_dir()
        check_username()
      rescue UserError
        return false
      end
      
      return true
    end
    
    def to_s()
      yaml = {
        'msg_key' => @msg_key,
        'username' => @username,
        'ssc_dir' => @ssc_dir,
      }
      
      return Psych.dump(yaml,header: true)
    end
  end
end
