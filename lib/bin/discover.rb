#!/usr/bin/env ruby

DEFAULT_ID = 'sou.myopenid.com'

$:.unshift File.dirname(__FILE__) + '/../'
require "rubygems"
require "openid_engine/rp"

rp = OpenidEngine::Rp.new
services = rp.discover_services(rp.normalize(ARGV[0] || DEFAULT_ID))

raise "no service found" if services.empty?
puts "Services Found::"
puts services

# puts dump(services)
# 
# def dump(services)
#   buf = ""
#   puts services.each{|s| s.each{ |k,v| k.kind_of?(Enumerable) ? dump :  }}
# end
