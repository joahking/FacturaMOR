# == Schema Information
#
# Table name: sessions
#
#  id         :integer(4)      not null, primary key
#  session_id :string(255)
#  data       :text
#  updated_at :datetime
#

# == Schema Information
# Schema version: 7
#
# Table name: sessions
#
#  id         :integer(11)   not null, primary key
#  session_id :string(255)   
#  data       :text          
#  updated_at :datetime      
#

class Session < ActiveRecord::Base
end
