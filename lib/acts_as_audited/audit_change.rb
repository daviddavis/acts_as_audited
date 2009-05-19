require 'set'

# Audit saves the actual changes of an Audit change.  It has the following attributes:
#
# * <tt>audit</tt>: the audit this change belongs to
# * <tt>association</tt>: the ActiveRecord object that is described by the association (optional)
# * <tt>action</tt>: one of create, update, or delete
# * <tt>field</tt>: the field that was changed
# * <tt>old_value</tt>: the old value
# * <tt>new_value</tt>: the new value
#
class AuditChange < ActiveRecord::Base
  belongs_to :audit
  belongs_to :association, :polymorphic => true
end