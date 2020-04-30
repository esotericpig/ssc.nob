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
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  0.1.0
  ###
  module Util
    def self.blank?(str)
      return str.nil?() || strip(str).empty?()
    end
    
    def self.lstrip(str)
      return nil if str.nil?()
      
      return str.gsub(/\A[[:space:]]+/,'')
    end
    
    def self.rstrip(str)
      return nil if str.nil?()
      
      return str.gsub(/[[:space:]]+\z/,'')
    end
    
    def self.strip(str)
      return nil if str.nil?()
      
      return str.gsub(/(\A[[:space:]]+)|([[:space:]]+\z)/,'')
    end
  end
end
