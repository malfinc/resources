class Cart < ApplicationRecord
  include AuditedTransitions

  belongs_to :account
  belongs_to :shipping_information, required: false
  belongs_to :billing_information, required: false
  has_many :payments
  has_many :cart_items

  monetize :total_cents
  monetize :subtotal_cents
  monetize :discount_cents
  monetize :shipping_cents
  monetize :tax_cents

  validates_presence_of :checkout_state

  state_machine :checkout_state, initial: :needs_shipping do
    event :ready_for_shipping do
      transition to: :needs_shipping, unless: :has_shipping_information?
    end

    event :ready_for_billing do
      transition to: :needs_billing, unless: :has_billing_information?
    end

    event :ready_for_payments do
      transition to: :needs_payments, unless: :has_payments?
    end

    event :purchase do
      transition to: :purchased
    end
    before_transition to: :purchased do |record|
      record.assign_attributes(
        total: record.total,
        subtotal: record.subtotal,
        discount: record.discount,
        shipping: record.shipping,
        tax: record.tax
      )
    end

    schema :purchased do
      validates_presence_of :shipping_information
      validates_presence_of :shipping_information_id
      validates_presence_of :billing_information
      validates_presence_of :billing_information_id
      validates_presence_of :payments
    end

    before_transition do: :version_transition
  end

  def subtotal_cents
    return super if checkout_state?(:purchased)

    if cart_items.any?
      cart_items.sum(:price_cents) + cart_items.sum(:discount_cents)
    else
      0
    end
  end

  def discount_cents
    return super if checkout_state?(:purchased)

    read_attribute(:discount_cents) || 0
  end

  def tax_cents
    return super if checkout_state?(:purchased)

    if shipping_information.present?
      (subtotal_cents * TaxRate.new(address: shipping_information).percent).round
    else
      0
    end
  end

  def shipping_cents
    return super if checkout_state?(:purchased)

    if shipping_information.present?
      ShippingRate.new(address: shipping_information).amount_cents
    else
      0
    end
  end

  def total_cents
    return super if checkout_state?(:purchased)

    if cart_items.any?
      subtotal_cents + discount_cents + tax_cents + shipping_cents
    else
      0
    end
  end

  def has_shipping_information?
    shipping_information.present?
  end

  def has_billing_information?
    billing_information.present?
  end

  def has_payments?
    payments.any?
  end

  private def has_all_information?
    has_shipping_information? && has_billing_information? && has_payments?
  end
end
