class ShippingInformation < ApplicationRecord
  has_many :carts
  belongs_to :account

  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :postal
  validates_presence_of :city
  validates_presence_of :state
end
