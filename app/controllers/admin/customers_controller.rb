class Admin::CustomersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @customers = Customer.includes(:children).order(:last_name_kana)
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def update
    @customer = Customer.find(params[:id])
    if @customer.update(customer_params)
      redirect_to admin_customer_path(@customer.id), notice: "会員情報が更新されました。"
    else
      render :edit
    end
  end

  def password_reset
    @customer = Customer.find(params[:id])
    new_password = SecureRandom.hex(8)

    if @customer.update(password: new_password)
      begin
        CustomerMailer.password_reset(@customer, new_password).deliver_now
        flash[:notice] = "新しいパスワードがメールで送信されました。"
      rescue => e
        Rails.logger.error("メール送信エラー: #{e.message}")
        flash[:alert] = "パスワードは更新されましたが、メール送信に失敗しました。"
      end
    else
      flash[:alert] = "パスワードのリセットに失敗しました。"
    end

    redirect_to admin_customer_path(@customer)
  end


  def history
    @customer = Customer.find(params[:id])
    @offs = Off.where(child_id: @customer.children.pluck(:id)) # その会員のお休みデータ
    @transfers = Transfer.where(child_id: @customer.children.pluck(:id)) # その会員の振替データ
  end


  def change_status
    @customer = Customer.find(params[:id])
    if @customer.update(status: params[:status]) # 修正: params[:status]を使用
      flash[:notice] = "ステータスが更新されました。"
    else
      flash[:alert] = "ステータスの更新に失敗しました。"
    end
    redirect_to admin_customer_path(@customer)
  end  


  private

  def customer_params
    params.require(:customer).permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :postal_code, :address, :telephone_number, :email)
  end
end
