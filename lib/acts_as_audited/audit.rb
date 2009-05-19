require 'set'

# Audit saves a change to ActiveRecord models.  It has the following attributes:
#
# * <tt>auditable</tt>: the ActiveRecord model that was changed
# * <tt>user</tt>: the user that performed the change; a string or an ActiveRecord model
# * <tt>action</tt>: one of create, update, or delete
# * <tt>changes</tt>: a serialized hash of all the changes
# * <tt>created_at</tt>: Time that the change was performed
#
class Audit < ActiveRecord::Base
  belongs_to :auditable, :polymorphic => true
  belongs_to :user, :polymorphic => true
  has_many :audit_changes
  
  before_create :set_version_number
  
  serialize :changes
  
  cattr_accessor :audited_class_names
  self.audited_class_names = Set.new

  def self.audited_classes
    self.audited_class_names.map(&:constantize)
  end
  
  # Allows user to be set to either a string or an ActiveRecord object
  def user_as_string=(user) #:nodoc:
    # reset both either way
    self.user_as_model = self.username = nil
    user.is_a?(ActiveRecord::Base) ?
      self.user_as_model = user :
      self.username = user
  end
  alias_method :user_as_model=, :user=
  alias_method :user=, :user_as_string=

  def user_as_string #:nodoc:
    self.user_as_model || self.username
  end
  alias_method :user_as_model, :user
  alias_method :user, :user_as_string
  
  def revision
    attributes = self.class.reconstruct_attributes(ancestors).merge({:version => version})
    clazz = auditable_type.constantize
    returning clazz.find_by_id(auditable_id) || clazz.new do |m|
      m.attributes = attributes
    end
  end
  
  def ancestors
    self.class.find(:all, :order => 'version',
      :conditions => ['auditable_id = ? and auditable_type = ? and version <= ?',
      auditable_id, auditable_type, version])
  end
  
  # Returns a hash of the changed attributes with the new values
  def new_attributes
    (changes || {}).inject({}.with_indifferent_access) do |attrs,(attr,values)|
      attrs[attr] = Array(values).last
      attrs
    end
  end

  # Returns a hash of the changed attributes with the old values
  def old_attributes
    (changes || {}).inject({}.with_indifferent_access) do |attrs,(attr,values)|
      attrs[attr] = Array(values).first
      attrs
    end
  end
  
  def self.reconstruct_attributes(audits)
    attributes = {}
    result = audits.collect do |audit|
      attributes.merge!(audit.new_attributes).merge!(:version => audit.version)
      yield attributes if block_given?
    end
    block_given? ? result : attributes
  end
  
private

  def set_version_number
    max = self.class.maximum(:version,
      :conditions => {
        :auditable_id => auditable_id,
        :auditable_type => auditable_type
      }) || 0
    self.version = max + 1
  end
  
end
