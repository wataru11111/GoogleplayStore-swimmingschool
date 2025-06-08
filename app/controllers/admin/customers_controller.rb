class Admin::CustomersController < ApplicationController
  before_action :authenticate_admin!

  def index
    if params[:q].present?
      query = params[:q].strip
      katakana_query = query.tr('ぁ-ん', 'ァ-ン') # ひらがな → カタカナ

      # 子どもにマッチする保護者IDを検索
      matching_child_customer_ids = Child.where("last_name_kana LIKE ? OR first_name_kana LIKE ?", "#{katakana_query}%", "#{katakana_query}%")
                                         .pluck(:customer_id)

      # 保護者自身またはその子が検索にマッチする顧客を取得
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
      redirect_to admin_customer_path(@customer.id), notice: "会員情報が更新されました。"
    else
      render :edit
    end
  end

  # ✅ パスワードリセット（メール送信を削除し、画面に表示）
  def password_reset
    @customer = Customer.find(params[:id])
    new_password = SecureRandom.hex(8)

    if @customer.update(password: new_password)
      flash[:notice] = "新しいパスワードは「#{new_password}」です。お客様に直接お伝えください。"
    else
      flash[:alert] = "パスワードのリセットに失敗しました。"
    end

    redirect_to admin_customer_path(@customer)
  end


  def history
    @customer = Customer.find(params[:id])
    @offs = Off.where(child_id: @customer.children.pluck(:id))
    @transfers = Transfer.where(child_id: @customer.children.pluck(:id))
  end

  def change_status
    @customer = Customer.find(params[:id])
    if @customer.update(status: params[:status])
      flash[:notice] = "ステータスが更新されました。"
    else
      flash[:alert] = "ステータスの更新に失敗しました。"
    end
    redirect_to admin_customer_path(@customer)
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
