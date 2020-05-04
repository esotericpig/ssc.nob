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
    nober = Nober.new()
    
    nober.run()
  end
  
  def self.uface()
    return Userface.instance
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.1
  ###
  class Nober
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
    
    def initialize()
      super()
      
      @bot = SSCBot.new()
      @chat_log = nil
      @config = Config.new()
      @nob = nil
      @nob_time = Time.now()
      @nobing = false
      @players = {}
      @testing = false
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
      
      @chat_log.add_listener(&method(:handle_kill_msg))
      @chat_log.add_listener(&method(:handle_private_msg))
      @chat_log.add_listener(&method(:handle_pub_msg))
      @chat_log.add_listener(&method(:handle_q_namelen_msg))
      
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
    
    def handle_kill_msg(chat_log,msg)
      return unless @nobing
      return unless msg.kill?()
      
      killed_username = msg[:killed]
      killer_username = msg[:killer]
      
      killed = @players[killed_username]
      killer = @players[killer_username]
      
      if !killed.nil?()
        if killed.username == @nob
          killed.time += (Time.now() - @nob_time)
          @nob_time = Time.now()
          
          if killer.nil?()
            killer = Player.new(killer_username)
            @players[killer.username] = killer
          end
          
          killer.nobs += 1
          @nob = killer.username
          
          send_nob_msg("{#{killer.username}} is now the Nob!")
        end
        
        # Only increment for people playing.
        if !killer.nil?()
          killed.deaths += 1
          killer.kills += 1
        end
      end
    end
    
    def handle_private_msg(chat_log,msg)
      return unless msg.private?()
      
      if msg[:username] == @config.username
        case msg[:message]
        when '!nob.start'
          return if @nobing # Already nobing
          
          @nob = @config.username
          
          @players = {
            @nob => Player.new(@nob,nobs: 1)
          }
          
          if !@thread.nil?()
            @thread.kill() if @thread.alive?()
            
            @thread = nil
          end
          
          mins = 5
          
          send_nob_msg("Nob bot loaded (Noble One) for #{mins} min!")
          send_nob_msg("Kill {#{@nob}} to become the Nob!")
          
          @nobing = true
          @nob_time = Time.now()
          
          @thread = Thread.new() do
            sleep(mins * 60)
            
            @nobing = false
            
            nobler = @players[@nob]
            nobler.time += (Time.now() - @nob_time)
            
            tops = @players.values.sort() do |p1,p2|
              p2.time <=> p1.time
            end
            tops = tops[0..4]
            
            send_nob_msg('Nob bot ended!')
            send_nob_msg(sprintf('   | %-24s | # of Nobs | Kills-Deaths | Time','Nobler'))
            send_nob_msg("   | #{'-' * 24} | #{'-' * 9} | #{'-' * 12} | #{'-' * 8}")
            
            tops.each_with_index() do |top,i|
              msg = sprintf("##{i + 1} | %-24s | %-9s | %-12s | %.2f secs",
                top.username,top.nobs,top.rec,top.time.round(2),
              )
              
              send_nob_msg(msg)
            end
            
            top = tops[0]
            
            send_nob_msg("{#{top.username}} is the top Nob! Congrats!")
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
    
    def handle_pub_msg(chat_log,msg)
      return unless msg.pub?()
      
      if msg[:username] == @config.username
        @bot.prevent_flooding()
      end
    end
    
    def handle_q_namelen_msg(chat_log,msg)
      return unless msg.q_namelen?()
      
      puts
      puts "Using namelen{#{msg[:namelen]}}."
      print uface.gt()
    end
    
    def send_chat_msg(channel,msg)
      send_pub_msg(";#{channel};#{msg}")
    end
    
    def send_nob_msg(msg)
      if @testing
        send_chat_msg(0,msg)
      else
        send_pub_msg("nob} #{msg}")
      end
    end
    
    def send_pub_msg(msg)
      # TODO: use config msg key
      
      @bot.type_key(KeyEvent::VK_TAB).paste(msg).enter()
    end
  end
  
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.1
  ###
  class Player
    attr_accessor :deaths
    attr_accessor :kills
    attr_accessor :nobs
    attr_accessor :time
    attr_accessor :username
    
    def initialize(username,deaths: 0,kills: 0,nobs: 0,time: 0)
      @deaths = deaths
      @kills = kills
      @nobs = nobs
      @time = time
      @username = username
    end
    
    def rec()
      return "#{@kills}-#{@deaths}"
    end
  end
end

if TESTING
  SSCNob.run()
end
