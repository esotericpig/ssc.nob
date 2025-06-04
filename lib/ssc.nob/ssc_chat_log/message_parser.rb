# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++

require 'ssc.nob/util'

require 'ssc.nob/ssc_chat_log/message'

module SSCNob
class SSCChatLog
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  class MessageParser
    attr_reader :config
    attr_reader :fin
    attr_accessor :namelen

    def initialize(config: nil,fin: nil,namelen: nil)
      @config = config
      @fin = fin
      @namelen = namelen
    end

    def parse(line)
      line = line.sub(/[\r\n]+\z/,'')

      msg = nil

      case line[0]
      when 'C'
        msg = parse_chat(line)
      when 'E'
        msg = parse_freq(line)
      when 'P'
        msg = parse_private(line)
      when 'T'
        msg = parse_team(line)
      else
        case line
        when /\A  .+> .*\z/ # '  Name> Msg'
          msg = parse_pub(line)
        when /\(\d+\) killed by: / # '  Name(100) killed by: Name'
          msg = parse_kill(line)
        when /\A  Message Name Length: \d+\z/ # '  Message Name Length: 24'
          msg = parse_q_namelen(line)
        end
      end

      msg = Message.new(line) if msg.nil?

      return msg
    end

    # 'T Name> Msg'
    def parse_basic(line,type:)
      i = @namelen.nil? ? line.index('> ',2) : (@namelen + 2)

      username = line[2...i]
      username = Util.strip(username.to_s)
      message = line[i + 1..-1]
      message = Util.strip(message.to_s)

      return Message.new(line,type: type,meta: {
        username: username,
        message: message,
      })
    end

    # 'C 1:Name> Msg'
    # - Not affected by namelen, always full name.
    def parse_chat(line)
      i = line.index(':',2)
      j = line.index('> ',i)

      channel = line[2...i]
      channel = Util.strip(channel.to_s).to_i
      username = line[i + 1...j]
      username = Util.strip(username.to_s)
      message = line[j + 1..-1]
      message = Util.strip(message.to_s)

      return Message.new(line,type: :chat,meta: {
        channel: channel,
        username: username,
        message: message,
      })
    end

    def parse_freq(line)
      return parse_basic(line,type: :freq)
    end

    # '  Name(100) killed by: Name'
    def parse_kill(line)
      i = line.index(/\(\d+\)/,2)
      j = line.index(')',i)
      k = line.index(':',j)

      killed = line[2...i]
      killed = Util.strip(killed.to_s)
      bounty = line[i + 1...j]
      bounty = Util.strip(bounty.to_s).to_i
      killer = line[k + 1..-1]
      killer = Util.strip(killer.to_s)

      return Message.new(line,type: :kill,meta: {
        killed: killed,
        bounty: bounty,
        killer: killer,
      })
    end

    def parse_private(line)
      return parse_basic(line,type: :private)
    end

    def parse_pub(line)
      return parse_basic(line,type: :pub)
    end

    # '  Message Name Length: 24'
    def parse_q_namelen(line)
      i = line.index(':')

      namelen = line[i + 1..-1]
      namelen = Util.strip(namelen.to_s).to_i

      @namelen = namelen

      return Message.new(line,type: :q_namelen,meta: {
        namelen: namelen,
      })
    end

    def parse_team(line)
      return parse_basic(line,type: :team)
    end
  end
end
end
