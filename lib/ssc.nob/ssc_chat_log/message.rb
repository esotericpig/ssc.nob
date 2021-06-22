#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++


module SSCNob
class SSCChatLog
  ###
  # @author Jonathan Bradley Whited
  # @since  0.1.0
  ###
  class Message
    TYPES = [
      :unknown,
      :chat,:freq,:kill,:private,:pub,:team,
      :q_chat,:q_kill,:q_namelen,:q_log,
    ]

    attr_reader :lines
    attr_reader :meta
    attr_reader :type

    TYPES.each() do |type|
      define_method(:"#{type}?") do
        return @type == type
      end
    end

    def initialize(lines,meta: {},type: :unknown)
      super()

      @lines = Array(lines)
      @meta = meta
      @type = type
    end

    def [](key)
      return @meta[key]
    end
  end
end
end
