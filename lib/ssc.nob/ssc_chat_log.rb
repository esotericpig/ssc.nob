# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++


require 'attr_bool'

require 'ssc.nob/ssc_chat_log/message'
require 'ssc.nob/ssc_chat_log/message_parser'


module SSCNob
  ###
  # @author Jonathan Bradley Whited
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
      @log_file = File.join(config.build_ssc_log_dir,logname)
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

    def run
      return if @running # Already running

      stop # Justin Case

      if !File.exist?(@log_file)
        # Create the file.
        File.open(@log_file,'at') do |fout|
        end
      end

      @thread = Thread.new do
        File.open(@log_file,'rt',encoding: 'Windows-1252:UTF-8') do |fin|
          fin.seek(0,:END)
          fin.gets # Ignore most recent line

          parser = MessageParser.new(config: @config,fin: fin)

          @running = true

          while @running
            while !(line = fin.gets).nil?
              msg = parser.parse(line)

              @messages.push(msg)

              @listeners.each do |l|
                l.call(self,msg)
              end
            end

            sleep(@sleep_time)
          end
        end
      end
    end

    def stop
      @running = false

      if !@thread.nil?
        if @thread.alive?
          @thread.join(5)
          @thread.kill if @thread.alive?
        end

        @thread = nil
      end

      @messages = []
    end
  end
end
