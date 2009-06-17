# == Schema Information
#
# Table name: db_files
#
#  id   :integer(4)      not null, primary key
#  data :binary
#

require File.dirname(__FILE__) + '/../test_helper'

class DbFileTest < ActiveSupport::TestCase
  fixtures :db_files

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
