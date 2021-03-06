#
# Do Stripe payment
#
class StripeSaleService
  def initialize(payment, payment_params)
    subunit_to_unit = Money::Currency.new(payment.currency).subunit_to_unit
    @payment = payment
    @community = payment.community
    @payer = payment.payer
    @recipient = payment.recipient
    @amount = payment.sum_cents.to_f / subunit_to_unit
    @service_fee = payment.total_commission.cents.to_f / subunit_to_unit
    @params = payment_params || {}
    # @hold_amount = @payment.tx.listing.security_amount_cents
  end

  def pay(capture)
    response, error = call_stripe_api(capture)
    if response.present?
      save_transaction_id!(response)
      change_payment_status_to_paid!
    end

    # if hold_response.present?
    #   save_hold_amount_transaction_id!(hold_response)
    # end

    log_result(response, error)

    return response, error
  end

  private

  def call_stripe_api(capture)
    with_expection_logging do
      StripeLog.warn("Sending sale transaction from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}")
      charge, error = nil, nil
      token = @params[:stripeToken]
      # Get the credit card details submitted by the form

      Stripe.api_key = @community.payment_gateway.stripe_secret_key

      begin

        customer = Stripe::Customer.create(
          :description => "Customer for #{@payer.emails.first.address}",
          :source => token # obtained with Stripe.js
        )

        #@payer.update_attribute(:stripe_customer_id, customer.id)
        @payment.tx.update_attribute(:stripe_customer_id, customer.id)

        charge_attrs = {
          :amount => (@amount * 100).to_i, # amount in cents
          :currency => @payment.currency,
          # :source => token,
          :customer => @payment.tx.stripe_customer_id,
          :description => "Listing fee charge to #{@recipient.full_name} from #{@payer.full_name}",
          :application_fee => (@service_fee * 100).to_i, # amount in cents
          :destination => @recipient.stripe_account.stripe_user_id,
          :capture => capture,
          :receipt_email => @recipient.emails.first.address,
          :metadata => {'listing_id' => @payment.tx.listing_id, 'seller_id' => @recipient.id, 'buyer_id' =>  @payer.id}
        }

        # Create the charge on Stripe's servers - this will charge the user's card
        charge = Stripe::Charge.create(charge_attrs)

        #charge = Stripe::Charge.create(charge_attrs1)
        # hold_charge = Stripe::Charge.create(hold_amount_attrs)
      rescue Stripe::CardError => e
        error = e.json_body[:error][:message]
      rescue Exception => e
        error = e.message
      end

      return charge, error
    end
  end

  def save_transaction_id!(response)
    @payment.update_attributes(stripe_transaction_id: response.id)
  end

  def change_payment_status_to_paid!
    @payment.paid!
  end

  def log_result(response, error)
    if response.present?
      transaction_id = response.id
      StripeLog.warn("Successful sale transaction #{transaction_id} from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}")
    else
      StripeLog.error("Unsuccessful sale transaction from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}: #{error}")
    end
  end

  def with_expection_logging(&block)
    begin
      block.call
    rescue Exception => e
      StripeLog.error("Expection #{e}")
      raise e
    end
  end
end
