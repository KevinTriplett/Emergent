class ApplicationMailbox < ActionMailbox::Base
  routing /.*@emergentcommons.app/i => :notifications
end
