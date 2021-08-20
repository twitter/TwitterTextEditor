#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2021 Twitter, Inc.
# SPDX-License-Identifier: Apache-2.0

require 'json'

# See `/lib/jazzy/doc_builder.rb` for `undocumentd.json` structure.
undocumented = JSON.parse(ARGF.read)
warnings = undocumented['warnings'] || []

unless warnings.empty?
  warnings.each do |warning|
    warn "#{warning['file']}:#{warning['line']} #{warning['warning']}: #{warning['symbol']}"
  end
  exit 1
end
