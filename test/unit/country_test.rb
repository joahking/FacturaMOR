# == Schema Information
#
# Table name: countries
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  name_for_sorting :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < ActiveSupport::TestCase
  fixtures :accounts, :users, :chpass_tokens, :customers, :countries, :invoices, :invoice_lines, :addresses

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
