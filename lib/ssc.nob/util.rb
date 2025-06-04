# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of SSC.Nob.
# Copyright (c) 2020-2021 Bradley Whited
#
# SPDX-License-Identifier: GPL-3.0-or-later
#++

module SSCNob
  ###
  # @author Bradley Whited
  # @since  0.1.0
  ###
  module Util
    def self.blank?(str)
      return str.nil? || strip(str).empty?
    end

    def self.lstrip(str)
      return nil if str.nil?

      return str.gsub(/\A[[:space:]]+/,'')
    end

    def self.rstrip(str)
      return nil if str.nil?

      return str.gsub(/[[:space:]]+\z/,'')
    end

    def self.strip(str)
      return nil if str.nil?

      return str.gsub(/(\A[[:space:]]+)|([[:space:]]+\z)/,'')
    end
  end
end
