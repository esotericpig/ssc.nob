# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++


require 'forwardable'
require 'highline'
require 'rainbow'
require 'singleton'
require 'tty-spinner'


module SSCNob
  ###
  # @author Jonathan Bradley Whited
  # @since  0.1.0
  ###
  class Userface
    extend Forwardable
    include Singleton

    attr_reader :line
    attr_reader :rain

    def_delegators :@line,:agree,:ask,:choose,:indent,:say
    def_delegator :@rain,:wrap,:color

    def initialize
      super()

      @line = HighLine.new
      @rain = Rainbow.new

      @line.use_color = true
      @rain.enabled = true
    end

    def cmd(cmd)
      return color(cmd).yellow.bold
    end

    def coffee
      return color('C\_/').saddlebrown.bold
    end

    def error(msg)
      return "#{color('Error:').red.bold} #{msg}"
    end

    def gt(msg=nil)
      return "#{color('>').yellow.bold} #{msg}"
    end

    def love(msg)
      return color(msg).red.bold
    end

    def spin(msg,&block)
      spinner = TTY::Spinner.new("[:spinner] #{msg}...",
        interval: 4,frames: ['o_O','O_o']
      )

      if block_given?
        spinner.run(&block)
      else
        spinner.auto_spin
      end

      return spinner
    end

    def ssc
      return color('Subspace Continuum').purple.bold
    end

    def title(title)
      return color(title).blue.bold
    end

    # Types each char, including ANSI escape codes.
    def type_raw(msg)
      msg.each_char do |c|
        print c
        sleep(0.05)
      end
    end

    # Types each char, except for ANSI color escape codes.
    def type(msg)
      break_num = msg.length
      offset = 0

      while offset < msg.length
        # Regex taken from Rainbow::StringUtils.uncolor().
        m = msg.match(/\e\[[0-9;]*m/ui,offset)

        if m
          type_raw(msg[offset...m.begin(0)])
          print m[0] # Don't type ANSI color escape codes.

          # Next index after last, not last index,
          #   so no need for +1.
          offset = m.end(0)
        else
          type_raw(msg[offset...msg.length])
          break
        end

        # Try to prevent an accidental infinite loop
        #   due to a bad regex and/or logic.
        break if (break_num -= 1) < 0
      end
    end

    def types(msg)
      type(msg)
      puts
    end

    def user(user)
      return color(user).limegreen.bold
    end
  end

  ###
  # @author Jonathan Bradley Whited
  # @since  0.1.0
  ###
  module Uface
    def uface
      return Userface.instance
    end
  end
end
