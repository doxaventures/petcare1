module StripeService
  module Payments
    CommunityModel = ::Community

    module Command
      module_function

      def capture_charge(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)
        stripe_charge_id = transaction.payment.stripe_transaction_id

        Stripe.api_key = transaction.payment.payment_gateway.stripe_secret_key
        result, error = nil, nil
        begin
          charge = Stripe::Charge.retrieve(stripe_charge_id)
          result = charge.capture

        rescue Stripe::InvalidRequestError => e
          error = e.message
        rescue Exception => e
          error = e.message
        end

        if result and result.status == "succeeded"
          StripeLog.info("=================================================================================")
          StripeLog.info("Submitted authorized payment #{transaction_id} to settlement")
          StripeLog.info("=================================================================================")
        else
          StripeLog.error("=================================================================================")
          StripeLog.error("Could not submit authorized payment #{transaction_id} to settlement (#{error})")
          StripeLog.error("=================================================================================")
        end

        return result, error
      end

      def void_transaction(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)

        stripe_charge_id = transaction.payment.stripe_transaction_id

        Stripe.api_key = transaction.payment.payment_gateway.stripe_secret_key
        result, error = nil, nil
        begin
          ch = Stripe::Charge.retrieve(stripe_charge_id)
          result = ch.refunds.create(:reverse_transfer => true)
          # result = Stripe::Refund.create(charge: stripe_charge_id, :reverse_transfer => true)
        rescue Stripe::InvalidRequestError => e
          error = e.message
        rescue Exception => e
          error = e.message
        end

        if result and result.status == "succeeded"
          StripeLog.info("=================================================================================")
          StripeLog.info("Voided transaction #{transaction_id}")
          StripeLog.info("=================================================================================")
        else
          StripeLog.error("=================================================================================")
          StripeLog.error("Could not void transaction #{transaction_id}. #{error}")
          StripeLog.error("=================================================================================")
        end

        return result, error
      end

      def auto_charge(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)
        #stripe_charge_id = transaction.payment.stripe_transaction_id
        stripe_customer_id = transaction.stripe_customer_id
        #@service_fee = transaction.payment.total_commission.cents.to_f / 100

        Stripe.api_key = transaction.payment.payment_gateway.stripe_secret_key 

        result, error = nil, nil
        begin
           charge_attrs = {
          :amount => transaction.payment.sum_cents.to_i, # amount in cents
          :currency => transaction.unit_price_currency,
          # :source => token,
          :customer => transaction.stripe_customer_id,
          :description => "Listing subscription charge deducted",
          :application_fee => (transaction.payment.sum_cents*0.10).to_i, # amount in cents
          :destination => transaction.author.stripe_account.stripe_user_id,
          #:capture => capture,
          :receipt_email => transaction.author.emails.first.address,
          #:metadata => {'listing_id' => @payment.tx.listing_id, 'seller_id' => @recipient.id, 'buyer_id' =>  @payer.id}
        }
          charge = Stripe::Charge.create(charge_attrs)
          result = charge

        rescue Stripe::InvalidRequestError => e
          error = e.message
        rescue Exception => e
          error = e.message
        end

        if result and result.status == "succeeded"
          
          tx = Transaction.new({
            community_id: transaction[:community_id],
            listing_id: transaction[:listing_id],
            starter_id: transaction[:starter_id],
            starter_uuid: transaction[:starter_uuid],
            listing_uuid: transaction[:listing_uuid],
            automatic_confirmation_after_days: transaction[:automatic_confirmation_after_days],
            community_uuid: transaction[:community_uuid],
            listing_author_id: transaction[:listing_author_id],
            listing_author_uuid: transaction[:listing_author_uuid],
            listing_title: transaction[:listing_title],
            current_state: "paid",
            delivery_method: transaction[:delivery_method],
            unit_price_currency: transaction[:unit_price_currency],
            payment_process: transaction[:payment_process],
            commission_from_seller: transaction[:commission_from_seller],
            subscription_type: transaction[:subscription_type],
            subscription: transaction[:subscription],
            stripe_customer_id: transaction[:stripe_customer_id],
            last_transition_at: Time.current,
            payment_gateway: transaction[:payment_gateway],
            listing_price_cents: transaction[:listing_price_cents],
            unit_price_cents: transaction[:unit_price_cents],
            service_time: transaction[:service_time]
            })

            conversation = tx.build_conversation(
              community_id: transaction[:community_id],
              listing_id: transaction[:listing_id])

            conversation.participations.build({
                person_id: transaction[:listing_author_id],
                is_starter: false,
                is_read: false})

            conversation.participations.build({
                person_id: transaction[:starter_id],
                is_starter: true,
                is_read: true})

            tx.transaction_transitions.build({
              to_state: "paid"
              })

            tx.save!


          end

        if result and result.status == "succeeded"
          StripeLog.info("=================================================================================")
          StripeLog.info("Submitted authorized payment #{transaction_id} to settlement")
          StripeLog.info("=================================================================================")
        else
          StripeLog.error("=================================================================================")
          StripeLog.error("Could not submit authorized payment #{transaction_id} to settlement (#{error})")
          StripeLog.error("=================================================================================")
        end

        return result, error
      end

    end

  end
end