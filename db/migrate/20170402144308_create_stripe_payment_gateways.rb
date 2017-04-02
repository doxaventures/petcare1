class CreateStripePaymentGateways < ActiveRecord::Migration
  def change
    create_table :stripe_payment_gateways do |t|
      t.belongs_to :community, index: true, foreign_key: true
      t.string :stripe_publishable_key
      t.string :stripe_secret_key
      t.string :stripe_client_id
      t.integer :commission_from_seller

      t.timestamps null: false
    end
  end
end
