# == Schema Information
#
# Table name: logos
#
#  id           :integer(4)      not null, primary key
#  parent_id    :integer(4)
#  content_type :string(255)
#  filename     :string(255)
#  db_file_id   :integer(4)
#  thumbnail    :string(255)
#  size         :integer(4)
#  width        :integer(4)
#  height       :integer(4)
#

require File.dirname(__FILE__) + '/../test_helper'

class LogoTest < ActiveSupport::TestCase
  fixtures :logos

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
