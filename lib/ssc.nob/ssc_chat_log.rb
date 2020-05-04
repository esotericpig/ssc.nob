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


require 'attr_bool'

require 'ssc.nob/ssc_chat_log/message'
require 'ssc.nob/ssc_chat_log/message_parser'


module SSCNob
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class SSCChatLog
    attr_reader :config
    attr_reader :listeners
    attr_reader :log_file
    attr_reader :logname
    attr_reader :messages
    attr_reader? :running
    attr_accessor :sleep_time
    attr_reader :thread
    
    def initialize(config,logname: 'nob.log',sleep_time: 0.2)
      @config = config
      @listeners = []
      @log_file = File.join(config.build_ssc_log_dir(),logname)
      @logname = logname
      @messages = []
      @running = false
      @sleep_time = sleep_time
      @thread = nil
    end
    
    def add_listener(proc=nil,&block)
      @listeners.push(block) if block
      @listeners.push(proc) if proc
      
      return self
    end
    
    def run()
      return if @running # Already running
      
      stop() # Justin Case
      
      if !File.exist?(@log_file)
        # Create the file.
        File.open(@log_file,'at') do |fout|
        end
      end
      
      @thread = Thread.new() do
        File.open(@log_file,'rt',encoding: 'Windows-1252:UTF-8') do |fin|
          fin.seek(0,:END)
          fin.gets() # Ignore most recent line
          
          parser = MessageParser.new(config: @config,fin: fin)
          
          @running = true
          
          while @running
            while !(line = fin.gets()).nil?()
              msg = parser.parse(line)
              
              @messages.push(msg)
              
              @listeners.each() do |l|
                l.call(self,msg)
              end
            end
            
            sleep(@sleep_time)
          end
        end
      end
    end
    
    def stop()
      @running = false
      
      if !@thread.nil?()
        if @thread.alive?()
          @thread.join(5)
          @thread.kill() if @thread.alive?()
        end
        
        @thread = nil
      end
      
      @messages = []
    end
  end
end
