class <%= class_name %> < ActiveRecord::Migration
  def self.up
    create_table :audits, :force => true do |t|
      t.column :auditable_id, :integer
      t.column :auditable_type, :string
      t.column :user_id, :integer
      t.column :user_type, :string
      t.column :username, :string
      t.column :action, :string
      t.column :version, :integer, :default => 0
      t.column :created_at, :datetime
    end
    
    create_table :audit_changes, :force => true do |t|
      t.column :audit_id, :integer
      t.column :association_type, :string
      t.column :association_id, :integer
      t.column :action, :string
      t.column :field, :string
      t.column :old_value, :text
      t.column :new_value, :text
    end
    
    add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
    add_index :audits, [:user_id, :user_type], :name => 'user_index'
    add_index :audits, :created_at  
    
    add_index :audit_changes, [:audit_id, :association_type, :association_id], :name => 'audit_association_index'
    add_index :audit_changes, [:audit_id], :name => 'audit_index'
  end

  def self.down
    drop_table :audits
    drop_table :audit_changes
  end
end
