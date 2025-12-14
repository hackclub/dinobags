class ApplicationMailbox < ActionMailbox::Base
  routing (/^hcb@/i => :hcb)
  routing all: :incinerate
end
