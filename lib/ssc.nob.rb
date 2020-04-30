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


TESTING = ($0 == __FILE__)

if TESTING
  require 'rubygems'
  require 'bundler/setup'
end

require 'attr_bool'
require 'time'

require 'ssc.nob/config'
require 'ssc.nob/error'
require 'ssc.nob/ssc_bot'
require 'ssc.nob/ssc_chat_log'
require 'ssc.nob/userface'
require 'ssc.nob/util'
require 'ssc.nob/version'

require 'ssc.nob/ssc_chat_log/message'
require 'ssc.nob/ssc_chat_log/message_parser'


# TODO: run options
# run:
# - Specify time limit (in seconds?).
# - Specify money donation for winner.
# - Specify who starts as Nob.
# - Specify if testing, so do chat channel messages instead of pub.

###
# @author Jonathan Bradley Whited (@esotericpig)
# @since  0.1.0
###
module SSCNob
  def self.run()
    nober = SSCNober.new()
    
    nober.run()
  end
  
  def self.uface()
    return Userface.instance
  end
  
  class SSCNober
    include Uface
    
    attr_reader :bot
    attr_reader :chat_log
    attr_reader :config
    attr_reader :nob
    attr_reader :nob_time
    attr_reader :nobing
    attr_reader :players
    attr_accessor? :testing
    attr_reader :thread
    
    def initialize(testing: false)
      super()
      
      @bot = SSCBot.new()
      @chat_log = nil
      @config = Config.new()
      @nob = nil
      @nob_time = Time.now()
      @nobing = false
      @players = {}
      @testing = testing
      @thread = nil
    end
    
    def run()
      begin
        puts
        @config.user_init!()
        puts
      rescue UserError => e
        puts
        puts uface.error(e)
        
        return
      end
      
      @chat_log = SSCChatLog.new(@config)
      
      @chat_log.add_listener(&method(:kill_message))
      @chat_log.add_listener(&method(:private_message))
      @chat_log.add_listener(&method(:pub_message))
      @chat_log.add_listener(&method(:q_namelen_message))
      
      puts <<~EOH
        #{uface.title('COMMANDS')}
        #{uface.cmd('run')}           runs Nob
        #{uface.cmd('stop')}          stops Nob
        #{uface.cmd('exit, quit')}    goodbye, user
      EOH
      puts
      
      while true
        cmd = uface.ask(uface.gt())
        cmd = Util.strip(cmd.to_s()).downcase()
        
        case cmd
        when 'exit','quit'
          @chat_log.stop()
          
          puts
          uface.types("You don't #{uface.love('love')} me? #{uface.love('<3')}")
          puts
          
          return
        when 'run'
          if @chat_log.running?()
            puts
            puts uface.error('stop the current Nob first, user.')
            puts
          else
            @chat_log.run()
          end
        when 'stop'
          @chat_log.stop()
        else
          puts
          puts uface.error("that's an invalid command, user.")
          puts
        end
      end
    end
    
    def kill_message(chat_log,msg)
      return unless @nobing
      return unless msg.kill?()
      
      if msg[:killed] == @nob
        old_nob = @players[@nob]
        old_nob[:time] += (Time.now() - @nob_time)
        
        killer = msg[:killer]
        new_nob = @players[killer]
        
        if new_nob.nil?()
          new_nob = {nobs: 0,time: 0,username: killer}
          @players[killer] = new_nob
        end
        
        new_nob[:nobs] += 1
        
        @nob = killer
        @nob_time = Time.now()
        
        @bot.pub_message("Nob} {#{killer}} is now the Nob!")
      end
    end
    
    def private_message(chat_log,msg)
      return unless msg.private?()
      
      if msg[:username] == @config.username
        case msg[:message]
        when '!nob.start'
          return if @nobing # Already nobing
          
          @nob = @config.username
          
          @players = {
            @nob => {nobs: 1,time: 0,username: @nob}
          }
          
          if !@thread.nil?()
            @thread.kill() if @thread.alive?()
            
            @thread = nil
          end
          
          @bot.pub_message('Nob} Nob bot loaded (Noble One) for 5 min!')
          @bot.pub_message("Nob} Kill {#{@nob}} to become the Nob!")
          
          @nobing = true
          @nob_time = Time.now()
          
          @thread = Thread.new() do
            sleep(5 * 60)
            
            @nobing = false
            
            nobler = @players[@nob]
            nobler[:time] += (Time.now() - @nob_time)
            
            tops = @players.values.sort() do |p1,p2|
              p2[:time] <=> p1[:time]
            end
            tops = tops[0..2]
            
            @bot.pub_message('Nob} Nob bot ended!')
            @bot.pub_message(sprintf('Nob}    | %-24s | # of Nobs | Time','Nobler'))
            @bot.pub_message("Nob}    | #{'-' * 24} | #{'-' * 9} | #{'-' * 8}")
            
            tops.each_with_index() do |top,i|
              msg = sprintf("Nob} ##{i + 1} | %-24s | %-9s | %s secs",
                top[:username],top[:nobs],top[:time].round(2))
              
              @bot.pub_message(msg)
            end
            
            top = tops[0]
            
            @bot.pub_message("Nob} {#{top[:username]}} is the top Nob! Congrats!")
          end
        when '!nob.stop'
          @nobing = false
          @players = {}
          
          if !@thread.nil?()
            @thread.kill() if @thread.alive?()
            
            @thread = nil
          end
        end
      end
    end
    
    def pub_message(chat_log,msg)
      return unless @nobing
      return unless msg.pub?()
      
      if msg[:username] == @config.username
        @bot.prevent_flooding()
      end
    end
    
    def q_namelen_message(chat_log,msg)
      return unless msg.q_namelen?()
      
      puts
      puts "Using namelen{#{msg[:namelen]}}."
      print uface.gt()
    end
  end
end

if TESTING
  SSCNob.run()
end
