class SendSubscriptionPaymentReceipts < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def before(job)
    # Set the correct service name to thread for I18n to pick it
    tx = Transaction.find(transaction_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(tx[:community_id])
  end

  def perform
    transaction = Transaction.find(transaction_id)
    receipt_to_seller = seller_should_receive_receipt(transaction[:listing_author_id])
    community = Community.find(transaction[:community_id])
    MailCarrier.deliver_now(TransactionMailer.subscription_auto_charge_receipt(transaction, community))
  end

  private

  def seller_should_receive_receipt(seller_id)
    Person.find(seller_id).should_receive?("email_about_new_payments")
  end
end