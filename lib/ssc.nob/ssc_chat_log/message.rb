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


module SSCNob
class SSCChatLog
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
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
