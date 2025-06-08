class CustomerMailer < ApplicationMailer
  def password_reset(customer, new_password)
    @customer = customer
    @new_password = new_password
    mail(to: @customer.email, subject: "【重要】パスワードの再設定について")
  end
end
