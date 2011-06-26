require 'open-uri'
require 'active_record/fixtures'

puts "> Deleting brands"
Brand.delete_all

puts "> Inserting brands from file"
open(File.expand_path('../seeds/brands.txt', __FILE__)) do |brands|
#open("seeds/brands.txt") do |brands|
  brands.read.each_line do |brand|
    name = brand
    Brand.create!(:name => name)
  end
end

puts "> Done"