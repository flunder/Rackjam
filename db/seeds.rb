require 'open-uri'
require 'active_record/fixtures'

# BRANDS
puts "> Deleting brands"
Brand.delete_all

puts "> Inserting brands from file"
open(File.expand_path('../seeds/brands.txt', __FILE__)) do |brands|
  brands.read.each_line do |brand|
    Brand.create!(:name => brand)
  end
end

puts "> Done"

# SKIPS
puts "> Deleting skipwords"
Skipword.delete_all

puts "> Inserting skipwords from file"
open(File.expand_path('../seeds/skips.txt', __FILE__)) do |skipwords|
  skipwords.read.each_line do |skipword|
    Skipword.create!(:keyword => skipword)
  end
end

puts "> Done"

# Create a user
u = User.new(
  :display_name => "subzcat",
  :email => "hi@larsattacks.co.uk",
  :password => 'rackjam',
  :confirmed_at => "2011-07-21 11:31:59.979597"
)
u.save!(:validate => false)
