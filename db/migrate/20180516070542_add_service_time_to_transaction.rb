class AddServiceTimeToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :service_time, :string
  end
end
