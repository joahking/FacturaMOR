# == Schema Information
#
# Table name: invoice_pdfs
#
#  id         :integer(4)      not null, primary key
#  invoice_id :integer(4)      not null
#  data       :binary          default(""), not null
#

require File.dirname(__FILE__) + '/../test_helper'

class InvoicePdfTest < ActiveSupport::TestCase
  fixtures :accounts, :users, :chpass_tokens, :customers, :countries, :invoices, :invoice_lines, :addresses

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
