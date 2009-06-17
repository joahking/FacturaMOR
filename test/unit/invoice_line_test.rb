# == Schema Information
#
# Table name: invoice_lines
#
#  id                      :integer(4)      not null, primary key
#  invoice_id              :integer(4)      not null
#  amount                  :decimal(10, 2)
#  description             :string(1024)
#  price                   :decimal(10, 2)
#  total                   :decimal(10, 2)
#  description_for_sorting :string(1024)
#

require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLineTest < ActiveSupport::TestCase
  fixtures :invoices, :invoice_lines

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
