class AddSubscriptionToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :subscription, :boolean, default: false
  end
end
