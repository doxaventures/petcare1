class AddCustomerIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :stripe_customer_id, :string
    add_column :transactions, :subscription_type, :string
    add_column :transactions, :subscription_offers, :string
  end
end
