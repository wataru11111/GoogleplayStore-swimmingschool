class AdminArea::CustomersController < ApplicationController
  before_action :authenticate_admin!

  def index
    if params[:q].present?
      query = params[:q].strip
      katakana_query = query.tr('ぁ-ん', 'ァ-ン')

      matching_child_customer_ids = Child.where("last_name_kana LIKE ? OR first_name_kana LIKE ?", "#{katakana_query}%", "#{katakana_query}%")
                                         .pluck(:customer_id)

      @customers = Customer.includes(:children)
                           .where(
                             "last_name_kana LIKE :q OR first_name_kana LIKE :q OR id IN (:child_ids)",
                             q: "#{katakana_query}%",
                             child_ids: matching_child_customer_ids
                           )
                           .order(:last_name_kana)
    else
      @customers = Customer.includes(:children).order(:last_name_kana)
    end
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
      redirect_to admin_area_customer_path(@customer.id), notice: "会員情報が更新されました。"
      else
      render :edit
    end
  end

  def destroy
    @customer = Customer.find(params[:id])
    
    # 関連するお子さんの情報も削除
    @customer.children.destroy_all
    
    # 会員を削除
    @customer.destroy
    
    redirect_to admin_area_customers_path, notice: "会員「#{@customer.last_name} #{@customer.first_name}」を削除しました。"
  end

  def password_reset
    @customer = Customer.find(params[:id])
    new_password = SecureRandom.hex(8)

    if @customer.update(password: new_password)
      flash[:notice] = "新しいパスワードは「#{new_password}」です。お客様に直接お伝えください 。"
    else
      flash[:alert] = "パスワードのリセットに失敗しました。"
    end

    redirect_to admin_area_customer_path(@customer)
  end

  def history
    @customer = Customer.find(params[:id])
    child_ids = @customer.children.pluck(:id)
    
    if child_ids.any?
      @offs = Off.where(child_id: child_ids).order(created_at: :desc)
      @transfers = Transfer.where(child_id: child_ids).order(created_at: :desc)
    else
      @offs = []
      @transfers = []
    end
    
    Rails.logger.info("History: customer=#{@customer.id}, children=#{child_ids.count}, transfers=#{@transfers.count}")
  end

  def destroy_transfer
    @transfer = Transfer.find(params[:id])
    @customer = @transfer.child.customer
    
    # off_flagをリセット（お休みを再度登録可能にする）
    @transfer.off.update(flag: 0) if @transfer.off.present?
    
    @transfer.destroy
    redirect_to history_admin_area_customer_path(@customer), notice: "振替申込みを削除しました。"
  end
  
  def change_status
    @customer = Customer.find(params[:id])
    if @customer.update(status: params[:status])
      flash[:notice] = "ステータスが更新されました。"
    else
      flash[:alert] = "ステータスの更新に失敗しました。"
    end
    redirect_to admin_area_customer_path(@customer)
  end

  private

  def customer_params
    params.require(:customer).permit(
      :last_name, :first_name,
      :last_name_kana, :first_name_kana,
      :postal_code, :address,
      :telephone_number, :email
    )
  end
end
