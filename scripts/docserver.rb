#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2021 Twitter, Inc.
# SPDX-License-Identifier: Apache-2.0

require 'rubygems'
require 'listen'
require 'optparse'
require 'pathname'
require 'webrick'

class Watcher
  def initialize(watch_paths, &block)
    @watch_paths = Set.new
    @listen_paths = Set.new
    watch_paths.each do |watch_path|
      Pathname.glob(watch_path).each do |pathname|
        pathname = pathname.realpath

        @watch_paths.add(pathname.to_s)

        if pathname.directory?
          @listen_paths.add(pathname.to_s)
        else
          @listen_paths.add(pathname.dirname.to_s)
        end
      end
    end

    @block = block
  end

  def watch_paths
    @watch_paths.to_a
  end

  def start_non_blocking
    return if @listener

    options = {
      latency: 1.0,
      wait_for_delay: 1.0
    }
    @listener = Listen.to(*@listen_paths.to_a, options) do |modified, added, removed|
      changed = modified + added + removed

      changed.each do |path|
        pathname = Pathname.new(path).realpath

        loop do
          if @watch_paths.include?(pathname.to_s)
            @block.call
            break
          end

          break if pathname.root?

          pathname = pathname.parent
        end
      end
    end
    @listener.start
  end

  def stop
    return unless @listener

    @listener.stop
    @listener = nil
  end
end

class LocalWebServer
  attr_reader :port, :documents_path

  def initialize(documents_path, port)
    @documents_path = documents_path
    @port = port
  end

  def start_blocking
    server = WEBrick::HTTPServer.new(
      Port: port,
      DocumentRoot: documents_path,
      AccessLog: []
    )
    trap(:INT) do
      server.shutdown
    end
    server.start
  end
end

options = {
  documents_path: Dir.pwd,
  port: 3000
}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] [watch path, ...]"

  opts.on('-d PATH', '--documents', 'Path to the documents.') do |value|
    options[:documents_path] = File.expand_path(value)
  end
  opts.on('-c COMMAND', '--command', 'A command to update the documents when watch path is modified') do |value|
    options[:update_command] = value
  end
  opts.on('-p PORT', '--port', Integer, 'A port to the web server listen.') do |value|
    options[:port] = value
  end
end.parse!

if options[:update_command]
  watcher = Watcher.new(ARGV) do
    puts 'Watched file change'
    system(options[:update_command])
  end

  puts "Watching #{watcher.watch_paths.join(', ')} ..."
  watcher.start_non_blocking
end

local_web_server = LocalWebServer.new(options[:documents_path], options[:port])

puts "Running a web server at http://localhost:#{local_web_server.port} ..."
local_web_server.start_blocking
