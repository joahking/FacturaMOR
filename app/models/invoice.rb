# == Schema Information
#
# Table name: invoices
#
#  id                    :integer(4)      not null, primary key
#  url_id                :string(255)     not null
#  account_id            :integer(4)      not null
#  customer_id           :integer(4)      not null
#  number                :string(255)     not null
#  date                  :date
#  year                  :integer(4)
#  account_name          :string(255)     not null
#  account_cif           :string(255)     not null
#  account_street1       :string(255)
#  account_street2       :string(255)
#  account_city          :string(255)
#  account_province      :string(255)
#  account_postal_code   :string(255)
#  account_country_id    :integer(4)
#  account_country_name  :string(255)
#  customer_name         :string(255)     not null
#  customer_cif          :string(255)     not null
#  customer_street1      :string(255)
#  customer_street2      :string(255)
#  customer_city         :string(255)
#  customer_province     :string(255)
#  customer_postal_code  :string(255)
#  customer_country_id   :integer(4)
#  customer_country_name :string(255)
#  irpf_percent          :decimal(10, 2)
#  irpf                  :decimal(10, 2)
#  iva_percent           :decimal(10, 2)
#  iva                   :decimal(10, 2)
#  discount_percent      :decimal(10, 2)
#  discount              :decimal(10, 2)
#  total                 :decimal(10, 2)
#  paid                  :boolean(1)      not null
#  notes                 :text
#  footer                :text
#  logo_id               :integer(4)
#  created_at            :datetime
#  updated_at            :datetime
#  tax_base              :decimal(10, 2)
#

require 'set'

class Invoice < ActiveRecord::Base

  include NumberGuesser

  # We convert "F10-2007" into ["F", 10, "-", 2007] to get a mix of
  # lexicographic/numeric ordering per components delegating to Array#<=>
  attr_accessor :number_for_sorting

  # these fields are always computed server-side
  attr_protected :discount, :iva, :tax_base, :total, :logo

  belongs_to :account
  belongs_to :customer
  belongs_to :logo

  has_one :pdf, :class_name => 'InvoicePdf', :dependent => :destroy

  has_many :lines, :class_name => 'InvoiceLine', :dependent => :destroy

  # We need to run this setter before validation so that year is set when we
  # check uniqueness of number. Otherwise the validator is not effective
  # because year IS NOT NULL ends up (correctly) in the query.
  before_validation :set_year

  before_save :ensure_percents_are_not_nil
  before_save :compute_totals

  validates_presence_of   :number
  validates_uniqueness_of :number, :scope => [:account_id, :year], :message => "existe ya una factura con este número"

  validates_presence_of   :date, :message => "fecha inválida"
  validates_presence_of   :account
  validates_presence_of   :customer

  def set_year
    self.year = date.year
  end

  def before_create
    compute_and_set_url_id
  end

  def before_update
    self_in_db = Invoice.find(id, :select => 'id, number')
    compute_and_set_url_id if number != self_in_db.number
  end

  def after_find
    self.number_for_sorting = number.scan(INVOICE_NUMBER_REGEXP).map {|c| c =~ /\d/ ? c.to_i : c}
  end

  def to_param
    url_id
  end

  def self.sort_by_number_asc(invoices)
    is = Set.new(invoices)
    is_per_year = is.classify(&:year).sort_by {|k, v| k}.map {|y| y[1]}
    is_per_year.map {|y| y.sort_by {|i| i.number_for_sorting}}.flatten
  rescue
    invoices.sort_by {|i| i.date}
  end

  def <=>(another_invoice)
    i = (another_invoice.date <=> date rescue 0)
    if i == 0
      begin
        i = another_invoice.number_for_sorting <=> number_for_sorting
        i = another_invoice.number <=> number if i.nil?
      rescue Exception => e
        # If the user is in the middle of changing his invoice number pattern, as Agustin
        # did while using the application, perhaps the number_for_sorting are not comparable.
        # For instance "07_0003" with "Serv_07_0004", where the first components are a number
        # and a string respectively. That's why we put a rescue block with lexicographic
        # ordering as fallback.
        i = another_invoice.number <=> number
      end
    end
    return i
  end

  def logo_needs_update?
    logo != account.logo
  end

  alias_method :original_account=, :account=
  def account=(account)
    self.account_name         = account.fiscal_data.name
    self.account_cif          = account.fiscal_data.cif
    self.account_street1      = account.fiscal_data.address.street1
    self.account_street2      = account.fiscal_data.address.street2
    self.account_city         = account.fiscal_data.address.city
    self.account_province     = account.fiscal_data.address.province
    self.account_postal_code  = account.fiscal_data.address.postal_code
    self.account_country_id   = account.fiscal_data.address.country.id
    self.account_country_name = account.fiscal_data.address.country.name
    self.original_account     = account
  end

  def account_needs_update?
    account_name        != account.fiscal_data.name                ||
    account_cif         != account.fiscal_data.cif                 ||
    account_street1     != account.fiscal_data.address.street1     ||
    account_street2     != account.fiscal_data.address.street2     ||
    account_city        != account.fiscal_data.address.city        ||
    account_province    != account.fiscal_data.address.province    ||
    account_postal_code != account.fiscal_data.address.postal_code ||
    account_country_id  != account.fiscal_data.address.country.id
  end

  alias_method :original_customer=, :customer=
  def customer=(customer)
    self.customer_name         = customer.name
    self.customer_cif          = customer.cif
    self.customer_street1      = customer.address.street1
    self.customer_street2      = customer.address.street2
    self.customer_city         = customer.address.city
    self.customer_province     = customer.address.province
    self.customer_postal_code  = customer.address.postal_code
    self.customer_country_id   = customer.address.country.id
    self.customer_country_name = customer.address.country.name
    self.original_customer     = customer
  end

  def customer_needs_update?
    customer_name        != customer.name                ||
    customer_cif         != customer.cif                 ||
    customer_street1     != customer.address.street1     ||
    customer_street2     != customer.address.street2     ||
    customer_city        != customer.address.city        ||
    customer_province    != customer.address.province    ||
    customer_postal_code != customer.address.postal_code ||
    customer_country_id  != customer.address.country.id
  end

  # nils are not coerced to BigDecimal, we do it by hand to
  # ensure compute_totals has everything defined
  def ensure_percents_are_not_nil
    self.discount_percent = 0 if discount_percent.nil?
    self.iva_percent      = 0 if iva_percent.nil?
    self.irpf_percent     = 0 if irpf_percent.nil?
  end

  def compute_totals
    if self.lines.size > 0
      taxable = 0.0.to_d
      self.lines.each do |line|
        taxable += line.total
      end
      self.discount = (taxable*discount_percent/100.0.to_d rescue 0.0.to_d).round(2)
      self.tax_base = taxable - discount
      self.iva      = (tax_base*iva_percent/100.0.to_d rescue 0.0.to_d).round(2)
      self.irpf     = (tax_base*irpf_percent/100.0.to_d rescue 0.0.to_d).round(2)
      self.total    = tax_base - irpf + iva
    else
      self.discount = 0.0.to_d
      self.tax_base = 0.0.to_d
      self.irpf     = 0.0.to_d
      self.iva      = 0.0.to_d
      self.total    = 0.0.to_d
    end
  end

  def has_logo?
    logo
  end

  private

  def compute_and_set_url_id
    candidate = FacturagemUtils.normalize_for_url_id(number)
    invoice = Invoice.find_by_account_id_and_url_id(account_id, candidate)
    return if self == invoice # unlikely
    # invoice numbers are guaranteed to be unique within a year, but
    # not across years, if there's a clash we add the year
    candidate += "-#{date.year}" if invoice
    self.url_id = candidate
  end
end
