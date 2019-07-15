module TransactionService::Gateway
  class StripeAdapter < GatewayAdapter

    PaymentModel = ::StripePayment

    TransactionStore = TransactionService::Store::Transaction

    def create_payment(tx:, gateway_fields:, force_sync: nil)
      payment_gateway_id = StripePaymentGateway.where(community_id: tx[:community_id]).pluck(:id).first
      
      shipping_price = if tx[:shipping_price].present?
        tx[:shipping_price]
      else
        Money.new(0, tx[:unit_price_currency])
      end

      payment = StripePayment.create({
        transaction_id: tx[:id],
        community_id: tx[:community_id],
        status: :pending,
        payer_id: tx[:starter_id],
        recipient_id: tx[:listing_author_id],
        currency: tx[:unit_price_currency],
        sum_cents: ((tx[:unit_price] * tx[:listing_quantity]) + shipping_price) * 100
      })

     if gateway_fields[:shipping_address].present?
        TransactionStore.upsert_shipping_address(
          community_id: tx[:community_id],
          transaction_id: tx[:id],
          addr: gateway_fields[:shipping_address])
      end

      if gateway_fields[:billing_address].present?
        TransactionStore.upsert_billing_address(
          community_id: tx[:community_id],
          transaction_id: tx[:id],
          addr: gateway_fields[:billing_address])
      end

      result, error = StripeSaleService.new(payment, gateway_fields).pay(false)
      
      if result and result.status == "succeeded"
        SyncCompletion.new(Result::Success.new({result: true}))
      else
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def reject_payment(tx:, reason: nil)
      result, error = StripeService::Payments::Command.void_transaction(tx[:id], tx[:community_id])
      if result and result.status == "succeeded"
        SyncCompletion.new(Result::Success.new({result: true}))
      else
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def complete_preauthorization(tx:)
      result, error = StripeService::Payments::Command.capture_charge(tx[:id], tx[:community_id])
      if result and result.status == "succeeded"
        SyncCompletion.new(Result::Success.new({result: true}))
      else
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def get_payment_details(tx:)
      shipping_price = if tx[:shipping_price].present?
        tx[:shipping_price]
      else
        Money.new(0, tx[:unit_price_currency])
      end
      total_price = (tx[:unit_price] * tx[:listing_quantity]) + shipping_price
      { payment_total: total_price,
        total_price: total_price,
        charged_commission: nil,
        payment_gateway_fee: nil }
    end

  end
end