# == Schema Information
#
# Table name: chpass_tokens
#
#  id         :integer(4)      not null, primary key
#  token      :string(255)     not null
#  account_id :integer(4)
#  created_at :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class ChpassTokenTest < ActiveSupport::TestCase
  fixtures :chpass_tokens

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
