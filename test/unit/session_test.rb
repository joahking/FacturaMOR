# == Schema Information
#
# Table name: sessions
#
#  id         :integer(4)      not null, primary key
#  session_id :string(255)
#  data       :text
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class SessionTest < ActiveSupport::TestCase
  fixtures :sessions

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
