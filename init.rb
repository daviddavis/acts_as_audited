require 'acts_as_audited/audit'
require 'acts_as_audited/audit_change'
require 'acts_as_audited'

ActiveRecord::Base.send :include, ZenLang::Acts::Audited

if defined?(ActionController) and defined?(ActionController::Base)
  require 'acts_as_audited/audit_sweeper'
  ActionController::Base.send :include, ZenLang::ActionController::Audited
end
