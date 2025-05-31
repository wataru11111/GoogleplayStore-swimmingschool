  class Admin::ChildController < ApplicationController
    before_action :authenticate_admin!

    def edit
      @child = Child.find(params[:id])
      Rails.logger.debug("契約曜日: #{@child.contact_dey1}・#{@child.contact_dey2}, 契約時間: #{@child.contact_time1}・#{@child.contact_time2}")
    end

    def update
      @child = Child.find(params[:id])
      if @child.update(child_params)
        redirect_to admin_customer_path(@child.customer_id), notice: "お子さんの情報を更新しました。"
      else
        Rails.logger.error(@child.errors.full_messages)
        flash[:alert] = "情報の更新に失敗しました。"
        render :edit
      end
    end

    private

    def child_params
      params.require(:child).permit(:last_name, :first_name, :last_name_kana, :first_name_kana, :level, :contact_dey1, :contact_dey2, :contact_time1, :contact_time2)
    end
  end
