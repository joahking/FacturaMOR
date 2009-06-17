# == Schema Information
#
# Table name: db_files
#
#  id   :integer(4)      not null, primary key
#  data :binary
#

# == Schema Information
# Schema version: 7
#
# Table name: db_files
#
#  id   :integer(11)   not null, primary key
#  data :binary        
#

class DbFile < ActiveRecord::Base
end
