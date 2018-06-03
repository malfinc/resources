class CreateVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :versions, id: :bigint do |table|
      table.string :item_type, null: false
      table.string :item_id, null: false
      table.string :event, null: false
      table.string :whodunnit, null: false
      table.uuid :actor_id
      table.text :request_id
      table.text :session_id
      table.jsonb :transitions
      table.jsonb :object, null: false, default: {}
      table.jsonb :object_changes, null: false, default: {}
      table.timestamp :created_at, null: false

      table.index [:item_id, :item_type]
      table.index :actor_id, where: %("versions"."actor_id" IS NOT NULL)
      table.index :event
    end
  end
end