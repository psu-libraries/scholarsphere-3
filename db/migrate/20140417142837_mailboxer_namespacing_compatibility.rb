class MailboxerNamespacingCompatibility < ActiveRecord::Migration[4.2]

  def self.up
#    remove_index "receipts","notification_id"
#    remove_index "notifications","conversation_id"
    remove_foreign_key "receipts", name: "receipts_on_notification_id_#{Rails.env}"
    #Messages
    remove_foreign_key "notifications", name: "notifications_on_conversation_id_#{Rails.env}"

    rename_table :conversations, :mailboxer_conversations
    rename_table :notifications, :mailboxer_notifications
    rename_table :receipts,      :mailboxer_receipts

    add_foreign_key "mailboxer_receipts", "mailboxer_notifications", name:"mailboxer_receipts_on_notification_id_#{Rails.env}", column: :notification_id
    #Messages
    add_foreign_key "mailboxer_notifications", "mailboxer_conversations", {name:"notifications_on_conversation_id_#{Rails.env}",column:"conversation_id"}
#    add_index "mailboxer_receipts","notification_id"
#    add_index "mailboxer_notifications","conversation_id"
  end

  def self.down
    remove_foreign_key "mailboxer_receipts", name: "mailboxer_receipts_on_notification_id_#{Rails.env}"
    #Messages
    remove_foreign_key "mailboxer_notifications", name: "notifications_on_conversation_id_#{Rails.env}"

    rename_table :mailboxer_conversations, :conversations
    rename_table :mailboxer_notifications, :notifications
    rename_table :mailboxer_receipts,      :receipts

    add_foreign_key "receipts", "notifications", name:"receipts_on_notification_id_#{Rails.env}", column: :notification_id
    #Messages
    add_foreign_key "notifications", "conversations", name:"notifications_on_conversation_id_#{Rails.env}",column:"conversation_id"
    #

  end
end
