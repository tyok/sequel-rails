require 'rubygems'
require 'bundler'

Bundler.require :default, :development

Combustion.initialize! 'sequel_rails'
run Combustion::Application
