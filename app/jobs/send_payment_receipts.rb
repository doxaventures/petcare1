class SendPaymentReceipts < Struct.new(:transaction_id)

  include DelayedAirbrakeNotification

  def perform
    transaction = TransactionService::Transaction.query(transaction_id)
    set_service_name!(transaction[:community_id])
    receipt_to_seller = seller_should_receive_receipt(transaction[:listing_author_id])

    receipts =
      case transaction[:payment_gateway]

      when :paypal
        community = Community.find(transaction[:community_id])

        receipts = []
        receipts << TransactionMailer.paypal_new_payment(transaction) if receipt_to_seller
        receipts << TransactionMailer.paypal_receipt_to_payer(transaction)
        receipts
      when :stripe
        community = Community.find(transaction[:community_id])
        payment = stripe_payment_for(transaction_id)

        receipts = []
        receipts << TransactionMailer.stripe_new_payment(payment, community) if receipt_to_seller
        receipts << TransactionMailer.stripe_receipt_to_payer(payment, community)
        receipts
      else
        []
      end

    receipts.each { |receipt_mail| MailCarrier.deliver_now(receipt_mail) }
  end

  private

  def seller_should_receive_receipt(seller_id)
    Person.find(seller_id).should_receive?("email_about_new_payments")
  end

  def set_service_name!(community_id)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def stripe_payment_for(transaction_id)
    StripePayment.where(transaction_id: transaction_id).first
  end

end
