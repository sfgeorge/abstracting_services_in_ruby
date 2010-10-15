#
# !SLIDE :capture_code_output true
# One-way, asynchronous subprocess service

require 'example_helper'
begin
  Email.client.transport = 
    ASIR::Transport::Subprocess.new

  pr Email.client.send_email(:giant_pdf_invoice,
                             :to => "user@email.com",
                             :customer => @customer)
end

