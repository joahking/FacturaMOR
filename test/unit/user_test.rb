# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  account_id                :integer(4)      not null
#  first_name                :string(255)
#  first_name_for_sorting    :string(255)
#  last_name                 :string(255)
#  last_name_for_sorting     :string(255)
#  created_at                :datetime
#  updated_at                :datetime
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  is_blocked                :boolean(1)
#  last_seen_at              :datetime
#

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper
  fixtures :users

    # Replace this with your real tests.
  def test_truth
    assert true
  end
end
