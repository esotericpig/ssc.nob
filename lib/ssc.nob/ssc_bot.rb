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
require 'time'

java_import 'java.awt.Robot'
java_import 'java.awt.Toolkit'

java_import 'java.awt.datatransfer.Clipboard'
java_import 'java.awt.datatransfer.ClipboardOwner'
java_import 'java.awt.datatransfer.StringSelection'

java_import 'java.awt.event.KeyEvent'


module SSCNob
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  class SSCBot
    MESSAGE_FLOOD_COUNT = 8
    MESSAGE_FLOOD_TIME = 5
    
    attr_accessor :auto_delay_time
    attr_reader :char_codes
    attr_reader :clipboard
    attr_reader :last_message_time
    attr_reader :message_count
    attr_accessor :message_key
    attr_reader :robot
    
    # TODO: save message_key in config
    def initialize(auto_delay_time: 0.2,message_key: KeyEvent::VK_TAB)
      super()
      
      @auto_delay_time = auto_delay_time
      @char_codes = {}
      @clipboard = Toolkit.getDefaultToolkit().getSystemClipboard()
      @last_message_time = Time.now()
      @message_count = 0
      @message_key = message_key
      @robot = Robot.new()
      
      @robot.setAutoDelay(0) # Don't use Java's, too slow
      
      build_char_codes()
    end
    
    def auto_delay()
      sleep(@auto_delay_time)
      
      return self
    end
    
    def chat_message(channel,msg)
      return pub_message(";#{channel};#{msg}")
    end
    
    def copy(str)
      @clipboard.setContents(StringSelection.new(str),nil);
      
      return self
    end
    
    def enter()
      return type_key(KeyEvent::VK_ENTER)
    end
    
    def paste(str=nil)
      copy(str) unless str.nil?()
      
      # FIXME: change to VK_META for macOS
      roll_keys(KeyEvent::VK_CONTROL,KeyEvent::VK_V)
      
      return self
    end
    
    def prevent_flooding()
      @message_count += 1
      
      if @message_count >= MESSAGE_FLOOD_COUNT
        time_diff = Time.now() - @last_message_time
        
        if time_diff <= MESSAGE_FLOOD_TIME
          sleep(MESSAGE_FLOOD_TIME - time_diff)
        end
        
        @message_count = 0
      end
      
      @last_message_time = Time.now()
      
      return self
    end
    
    def pub_message(msg)
      type_key(@message_key).paste(msg).enter()
      
      sleep(1.2)
      
      return self
    end
    
    def roll_keys(*key_codes)
      key_codes.each() do |key_code|
        @robot.keyPress(key_code)
        auto_delay()
      end
      
      (key_codes.length - 1).downto(0) do |i|
        @robot.keyRelease(key_codes[i])
        auto_delay()
      end
      
      return self
    end
    
    def type(str)
      str.each_char() do |c|
        key_codes = @char_codes[c]
        
        next if key_codes.nil?()
        
        roll_keys(*key_codes)
      end
      
      return self
    end
    
    def type_key(key_code)
      @robot.keyPress(key_code)
      auto_delay()
      @robot.keyRelease(key_code)
      auto_delay()
      
      return self
    end
    
    def build_char_codes()
      @char_codes.store("\b",[KeyEvent::VK_BACK_SPACE])
      @char_codes.store("\f",[KeyEvent::VK_PAGE_DOWN])
      @char_codes.store("\n",[KeyEvent::VK_ENTER])
      @char_codes.store("\r",[KeyEvent::VK_HOME])
      @char_codes.store("\t",[KeyEvent::VK_TAB])
      @char_codes.store(' ',[KeyEvent::VK_SPACE])
      @char_codes.store('!',[KeyEvent::VK_SHIFT,KeyEvent::VK_EXCLAMATION_MARK])
      @char_codes.store('"',[KeyEvent::VK_SHIFT,KeyEvent::VK_QUOTEDBL])
      @char_codes.store('#',[KeyEvent::VK_SHIFT,KeyEvent::VK_3])
      @char_codes.store('$',[KeyEvent::VK_SHIFT,KeyEvent::VK_4])
      @char_codes.store('%',[KeyEvent::VK_SHIFT,KeyEvent::VK_5])
      @char_codes.store('&',[KeyEvent::VK_SHIFT,KeyEvent::VK_7])
      @char_codes.store('\'',[KeyEvent::VK_QUOTE])
      @char_codes.store('(',[KeyEvent::VK_SHIFT,KeyEvent::VK_9])
      @char_codes.store(')',[KeyEvent::VK_SHIFT,KeyEvent::VK_0])
      @char_codes.store('*',[KeyEvent::VK_SHIFT,KeyEvent::VK_8])
      @char_codes.store('+',[KeyEvent::VK_SHIFT,KeyEvent::VK_EQUALS])
      @char_codes.store(',',[KeyEvent::VK_COMMA])
      @char_codes.store('-',[KeyEvent::VK_MINUS])
      @char_codes.store('.',[KeyEvent::VK_PERIOD])
      @char_codes.store('/',[KeyEvent::VK_SLASH])
      @char_codes.store('0',[KeyEvent::VK_0])
      @char_codes.store('1',[KeyEvent::VK_1])
      @char_codes.store('2',[KeyEvent::VK_2])
      @char_codes.store('3',[KeyEvent::VK_3])
      @char_codes.store('4',[KeyEvent::VK_4])
      @char_codes.store('5',[KeyEvent::VK_5])
      @char_codes.store('6',[KeyEvent::VK_6])
      @char_codes.store('7',[KeyEvent::VK_7])
      @char_codes.store('8',[KeyEvent::VK_8])
      @char_codes.store('9',[KeyEvent::VK_9])
      @char_codes.store(':',[KeyEvent::VK_SHIFT,KeyEvent::VK_COLON])
      @char_codes.store(';',[KeyEvent::VK_SEMICOLON])
      @char_codes.store('<',[KeyEvent::VK_LESS])
      @char_codes.store('=',[KeyEvent::VK_EQUALS])
      @char_codes.store('>',[KeyEvent::VK_SHIFT,KeyEvent::VK_GREATER])
      @char_codes.store('?',[KeyEvent::VK_SHIFT,KeyEvent::VK_SLASH])
      @char_codes.store('@',[KeyEvent::VK_SHIFT,KeyEvent::VK_AT])
      @char_codes.store('A',[KeyEvent::VK_SHIFT,KeyEvent::VK_A])
      @char_codes.store('B',[KeyEvent::VK_SHIFT,KeyEvent::VK_B])
      @char_codes.store('C',[KeyEvent::VK_SHIFT,KeyEvent::VK_C])
      @char_codes.store('D',[KeyEvent::VK_SHIFT,KeyEvent::VK_D])
      @char_codes.store('E',[KeyEvent::VK_SHIFT,KeyEvent::VK_E])
      @char_codes.store('F',[KeyEvent::VK_SHIFT,KeyEvent::VK_F])
      @char_codes.store('G',[KeyEvent::VK_SHIFT,KeyEvent::VK_G])
      @char_codes.store('H',[KeyEvent::VK_SHIFT,KeyEvent::VK_H])
      @char_codes.store('I',[KeyEvent::VK_SHIFT,KeyEvent::VK_I])
      @char_codes.store('J',[KeyEvent::VK_SHIFT,KeyEvent::VK_J])
      @char_codes.store('K',[KeyEvent::VK_SHIFT,KeyEvent::VK_K])
      @char_codes.store('L',[KeyEvent::VK_SHIFT,KeyEvent::VK_L])
      @char_codes.store('M',[KeyEvent::VK_SHIFT,KeyEvent::VK_M])
      @char_codes.store('N',[KeyEvent::VK_SHIFT,KeyEvent::VK_N])
      @char_codes.store('O',[KeyEvent::VK_SHIFT,KeyEvent::VK_O])
      @char_codes.store('P',[KeyEvent::VK_SHIFT,KeyEvent::VK_P])
      @char_codes.store('Q',[KeyEvent::VK_SHIFT,KeyEvent::VK_Q])
      @char_codes.store('R',[KeyEvent::VK_SHIFT,KeyEvent::VK_R])
      @char_codes.store('S',[KeyEvent::VK_SHIFT,KeyEvent::VK_S])
      @char_codes.store('T',[KeyEvent::VK_SHIFT,KeyEvent::VK_T])
      @char_codes.store('U',[KeyEvent::VK_SHIFT,KeyEvent::VK_U])
      @char_codes.store('V',[KeyEvent::VK_SHIFT,KeyEvent::VK_V])
      @char_codes.store('W',[KeyEvent::VK_SHIFT,KeyEvent::VK_W])
      @char_codes.store('X',[KeyEvent::VK_SHIFT,KeyEvent::VK_X])
      @char_codes.store('Y',[KeyEvent::VK_SHIFT,KeyEvent::VK_Y])
      @char_codes.store('Z',[KeyEvent::VK_SHIFT,KeyEvent::VK_Z])
      @char_codes.store('[',[KeyEvent::VK_OPEN_BRACKET])
      @char_codes.store('\\',[KeyEvent::VK_BACK_SLASH])
      @char_codes.store(']',[KeyEvent::VK_CLOSE_BRACKET])
      @char_codes.store('^',[KeyEvent::VK_SHIFT,KeyEvent::VK_CIRCUMFLEX])
      @char_codes.store('_',[KeyEvent::VK_SHIFT,KeyEvent::VK_UNDERSCORE])
      @char_codes.store('`',[KeyEvent::VK_BACK_QUOTE])
      @char_codes.store('a',[KeyEvent::VK_A])
      @char_codes.store('b',[KeyEvent::VK_B])
      @char_codes.store('c',[KeyEvent::VK_C])
      @char_codes.store('d',[KeyEvent::VK_D])
      @char_codes.store('e',[KeyEvent::VK_E])
      @char_codes.store('f',[KeyEvent::VK_F])
      @char_codes.store('g',[KeyEvent::VK_G])
      @char_codes.store('h',[KeyEvent::VK_H])
      @char_codes.store('i',[KeyEvent::VK_I])
      @char_codes.store('j',[KeyEvent::VK_J])
      @char_codes.store('k',[KeyEvent::VK_K])
      @char_codes.store('l',[KeyEvent::VK_L])
      @char_codes.store('m',[KeyEvent::VK_M])
      @char_codes.store('n',[KeyEvent::VK_N])
      @char_codes.store('o',[KeyEvent::VK_O])
      @char_codes.store('p',[KeyEvent::VK_P])
      @char_codes.store('q',[KeyEvent::VK_Q])
      @char_codes.store('r',[KeyEvent::VK_R])
      @char_codes.store('s',[KeyEvent::VK_S])
      @char_codes.store('t',[KeyEvent::VK_T])
      @char_codes.store('u',[KeyEvent::VK_U])
      @char_codes.store('v',[KeyEvent::VK_V])
      @char_codes.store('w',[KeyEvent::VK_W])
      @char_codes.store('x',[KeyEvent::VK_X])
      @char_codes.store('y',[KeyEvent::VK_Y])
      @char_codes.store('z',[KeyEvent::VK_Z])
      @char_codes.store('{',[KeyEvent::VK_SHIFT,KeyEvent::VK_BRACELEFT])
      @char_codes.store('|',[KeyEvent::VK_SHIFT,KeyEvent::VK_BACK_SLASH])
      @char_codes.store('}',[KeyEvent::VK_SHIFT,KeyEvent::VK_BRACERIGHT])
      @char_codes.store('~',[KeyEvent::VK_SHIFT,KeyEvent::VK_BACK_QUOTE])
    end
  end
end
