class AdminArea::ChildController < ApplicationController
  before_action :authenticate_admin!

  def edit
    @child = Child.find(params[:id])
    Rails.logger.debug("契約曜日: #{@child.contact_dey1}・#{@child.contact_dey2}, 契約時間: #{@child.contact_time1}・#{@child.contact_time2}")
  end

  def update
    @child = Child.find(params[:id])
    if @child.update(child_params)
      redirect_to admin_area_customer_path(@child.customer_id), notice: "お子さんの情報を更新しました。"
    else
      Rails.logger.error(@child.errors.full_messages)
      flash[:alert] = "情報の更新に失敗しました。"
      render :edit
    end
  end

  # ADMIN_CHILD_DELETE_20261123
  def destroy
    child = Child.find(params[:id])

    unless params[:confirm_child_id].to_s == child.id.to_s
      return redirect_to admin_area_customer_path(child.customer_id),
        alert: "削除確認情報が一致しません。"
    end

    customer_id = child.customer_id

    ActiveRecord::Base.transaction do
      child.lock!

      offs = Off.where(child_id: child.id).lock.to_a
      transfers = Transfer.where(child_id: child.id).lock.to_a
      off_ids = offs.map(&:id)

      # 他のお子さんの履歴を巻き込まないための確認
      if Transfer.where(off_id: off_ids).where.not(child_id: child.id).exists? ||
         transfers.any? { |t| !off_ids.include?(t.off_id) }
        raise "お休みと振替の関連付けが不一致"
      end

      # 振替 → お休み → お子さんの順番で削除
      transfers.each(&:destroy!)
      offs.each(&:destroy!)
      child.destroy!
    end

    redirect_to admin_area_customer_path(customer_id),
      notice: "お子さんの情報と関連履歴を削除しました。"

  rescue ActiveRecord::RecordNotFound
    redirect_to admin_area_customers_path,
      alert: "対象のお子さんが見つかりません。"

  rescue StandardError => e
    Rails.logger.error(
      "[admin child delete] id=#{params[:id]} #{e.class}: #{e.message}"
    )
    redirect_to admin_area_customers_path,
      alert: "削除に失敗しました。データを確認してください。"
  end

  private

  def child_params
    params.require(:child).permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :level, :contact_dey1, :contact_dey2, :contact_time1, :contact_time2)
  end
end
