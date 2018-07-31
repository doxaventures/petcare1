class AutomaticTransactionJob < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def before(job)
    # Set the correct service name to thread for I18n to pick it
    tx = Transaction.find(transaction_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(tx[:community_id])
  end

  def perform
    tx = Transaction.find(transaction_id)
    if tx.subscription? && tx.listing.open? && tx.listing.recurring_payment.present? && tx.listing.recurring_payment.include?(tx.subscription_type)
      result, error = StripeService::Payments::Command.auto_charge(tx[:id], tx[:community_id])
        if result and result.status == "succeeded"
          Delayed::Job.enqueue(SendSubscriptionPaymentReceipts.new(tx[:id]))
          if tx.subscription? && tx.listing.open? && tx.listing.recurring_payment.present?
            if tx.subscription_type? && tx.subscription_type == "weekly" && tx.listing.recurring_payment["weekly"].present?
              date = Time.current + 7.days
            elsif tx.subscription_type? && tx.subscription_type == "bi-weekly" && tx.listing.recurring_payment["bi-weekly"].present?
              date = Time.current + 14.days
            elsif tx.subscription_type? && tx.subscription_type == "monthly" && tx.listing.recurring_payment["monthly"].present? 
              date = Time.current + 30.days
            elsif tx.subscription_type? && tx.subscription_type == "quaterly" && tx.listing.recurring_payment["quaterly"].present?
              date = Time.current + 90.days
            end
            if date.present?
              Delayed::Job.enqueue(AutomaticTransactionJob.new(tx[:id]), :run_at => date)
            end
          end
        else
          SyncCompletion.new(Result::Error.new(error))
        end
    end
  end

end