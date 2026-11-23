class Public::ChildController < ApplicationController
  def new
    @child = Child.new
  end

  def create
    @child = Child.new(child_params)
    @child.customer_id = current_customer.id
    if @child.save
      redirect_to customers_show_path, notice: "お子さんの情報を登録しました。"
    else
      flash[:alert] = "お子さん情報の登録に失敗しました: #{@child.errors.full_messages.join(', ')}"
      render :new
    end
  end

  def edit
    @child = current_customer.children.find(params[:id])
    Rails.logger.debug("契約曜日1: #{@child.contact_dey1}, 曜日2: #{@child.contact_dey2}, 時間1: #{@child.contact_time1}, 時間2: #{@child.contact_time2}")
  end

  def update
    @child = current_customer.children.find(params[:id])
    if @child.update(child_params)
      redirect_to customers_show_path, notice: "お子さんの情報を更新しました。"
    else
      flash[:alert] = "情報の更新に失敗しました: #{@child.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @child = current_customer.children.find(params[:id])
    if @child.destroy
      flash[:notice] = "お子さん情報を削除しました。"
    else
      flash[:alert] = "お子さん情報を削除できませんでした。"
    end
    redirect_to customers_show_path
  end

  private

  def child_params
  params.require(:child).permit( :last_name, :first_name, :last_name_kana, :first_name_kana, :contact_dey1, :contact_dey2, :level,  :contact_time1, :contact_time2, :telephone_number )
  end

end
