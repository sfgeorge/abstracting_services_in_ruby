=begin
# !SLIDE
# Stuff Gets Complicated
#
# Systems become:
# * bigger ->
# * complex ->
# * slower ->
# * distributed ->
# * hard to test
#
# !SLIDE END

# !SLIDE
# Sample Service
#
module Email
  def send_email template_name, options
    $stderr.puts "*** #{$$}: Email.send_mail #{template_name.inspect} #{options.inspect}"
    :ok
  end

  def do_raise msg
    raise msg
  end

  extend self
end
# !SLIDE END

# !SLIDE
# Back when things were simple...
#
class CustomersController < ApplicationController
  def send_invoice
    @customer = Customer.find(params[:id])
    Email.send_email(:pdf_invoice,
                     :to => @customer.email,
                     :customer => @customer)
  end
end
# !SLIDE END

# !SLIDE
# Trying to improve user's experience...
#
class CustomersController < ApplicationController
  def send_invoice
    @customer = Customer.find(params[:id])
    Process.fork do 
      Email.send_email(:pdf_invoice,
                       :to = @customer.email,
                       :customer => @customer)
    end
  end
end
# !SLIDE END

# !SLIDE
# Use other machines to poll a work table...
#
class CustomersController < ApplicationController
  def send_invoice
    @customer = Customer.find(params[:id])
    EmailWork.create(:template_name => :pdf_invoice, 
                     :options => { 
                       :to => @customer.email,
                       :customer => @customer,
                     })
  end
end
# !SLIDE END

# !SLIDE
# Use queue infrastructure
#
class CustomersController < ApplicationController
  def send_invoice
    @customer = Customer.find(params[:id])
    queue_service.put(:queue => :Email, 
                      :action => :send_email,
                      :template_name => :pdf_invoice, 
                      :options => { 
                        :to => @customer.email,
                        :customer => @customer,
                      })
  end
end
# !SLIDE END
=end


# !SLIDE
# Example Request
#
# @@@ ruby
# Email.client.send_email(:pdf_invoice, 
#                         :to => "user@email.com",
#                         :customer => @customer)
# @@@
# ->
# @@@ ruby  
# request = Request.new(...)
# request.receiver_class == ::Module
# request.receiver == ::Email
# request.selector == :send_email
# request.arguments == [ :pdf_invoice,
#                        { :to => "user@email.com", :customer => ... } ]
# @@@
#
# !SLIDE END

# !SLIDE
# Using a Client Proxy
#
# @@@ ruby
# Email.send_email(:pdf_invoice, 
#                  :to => "user@email.com",
#                  :customer => @customer)
# @@@
# ->
# @@@ ruby   
# Email.client.send_email(:pdf_invoice, 
#                         :to => "user@email.com",
#                         :customer => @customer)
#
# @@@
# !SLIDE END

# !SLIDE
# Example Exception
#
# @@@ ruby
# Email.do_raise("DOH!")
# @@@
# ->
# @@@ ruby
# response.exception = ee = EncapsulatedException.new(...)
# ee.exception_class = "::RuntimeError"
# ee.exception_message = "DOH!"
# ee.exception_backtrace = [ ... ]
# @@@ ruby
#
# !SLIDE END

# !SLIDE
# Sample Service with Client Support
# 

require 'asir'

# Added .client support.
module Email
  include ASIR::Client # Email.client

  def send_email template_name, options
    $stderr.puts "*** #{$$}: Email.send_mail #{template_name.inspect} #{options.inspect}"
    :ok
  end

  def do_raise msg
    raise msg
  end

  extend self
end
# !SLIDE END

