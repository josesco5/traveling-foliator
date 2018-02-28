#!/usr/bin/env ruby
require 'faker'
require 'sqlite3'
require 'json'

puts JSON.parse('{ "we" : "love", "using" : "Lambda" }')
db = SQLite3::Database.new("hello.sqlite3")
db.execute("create table if not exists foo (name varchar(255))")
db.execute("insert into foo values ('hello world')")
db.close
puts "Hello #{Faker::Name.name}, database file modified."
