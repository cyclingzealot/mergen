#!/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'pathname'
require 'byebug'
require_relative 'session'

loginHoursPerMonth = []

sessionDataPath = ARGV[0]

if ! File.exist?(File.expand_path(sessionDataPath))
        puts "#{ARGV[0]} does not seem to be a path"
        exit 1
end


doc = Nokogiri::HTML(File.expand_path(File.read(sessionDataPath)))

rows = doc.xpath('//tr')


rows.each { |r|
    s = Session.new
    interval = s.setDateTimes(r.children[0], r.children[1])

    if interval === FALSE
        next
    else
        puts interval
        puts s.getMonth
    end
}


