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
  class Error < ::StandardError; end

  class UserError < Error; end
end
