#!/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'byebug'
require_relative 'session'

loginHoursPerMonth = []

sessionDataPath = ARGV[0]

if sessionDataPath.nil?
    puts "You must specify a data path"
    exit 1
end

if ! Dir.exist?(File.expand_path(sessionDataPath))
        puts "#{ARGV[0]} does not seem to be a path to a directory"
        exit 1
end


logonSessions = Session.readDir(sessionDataPath)

logonSessions.each { |s|
    puts s.getInterval
}
