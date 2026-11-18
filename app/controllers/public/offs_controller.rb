class Public::OffsController < ApplicationController
  before_action :authenticate_customer!
  before_action :load_registered_children, only: [:index, :create]
    def new
      unless params[:off_id].present?
        redirect_to offs_path,
          alert: "お休みはまだ登録されていません。お子さんとお休み日を入力してください。"
        return
      end

      @off = find_customer_off!(params[:off_id])
    end

    def create

    # お休み日の未入力チェック
    submitted = params[:off].is_a?(ActionController::Parameters) ?
      params[:off] : ActionController::Parameters.new

    messages = []

    if submitted[:child_id].blank?
      messages << "お子さんのお名前が未入力です。"
    elsif @children.none? { |child| child.id.to_s == submitted[:child_id].to_s }
      messages << "選択されたお子さんを確認できません。"
    end

    if submitted[:off_month].blank?
      messages << "お休み日が未入力です。"
    end

    if messages.any?
      @off = Off.new
      flash.now[:alert] = messages.join(" ")
      render :index, status: :unprocessable_entity
      return
    end

      # 休会中チェック
      if current_customer.status == "suspended"
        flash[:alert] = "休会中はお休みを取ることができません。"
        redirect_to customers_show_path and return
    end
    
      # ✅ カレンダー形式（date_field）から受け取った文字列を Date 型に変換
    begin
      off_date = Date.parse(params[:off][:off_month])

      # B_CONTRACT_WEEKDAY_FILTER_20261118
      selected_child = @children.find do |child|
        child.id.to_s == params.dig(:off, :child_id).to_s
      end

      if selected_child
        allowed_days = [
          selected_child.contact_dey1,
          selected_child.contact_dey2
        ].compact.map(&:strip).uniq

        weekday = %w[
          日曜日 月曜日 火曜日 水曜日
          木曜日 金曜日 土曜日
        ][off_date.wday]

        unless allowed_days.include?(weekday) || ScheduleOverrides.off_for?(off_date, selected_child) # ADMIN_ADDITIONAL_DAYS_20261118
          @off = Off.new(off_params)
          @off.child_id = selected_child.id

          flash.now[:alert] =
            "契約曜日（#{allowed_days.join('・')}）の日付を選択してください。"

          render :index, status: :unprocessable_entity
          return
        end
      end
      limit_day = Setting.find_by(key: 'available_off_day')&.value
     if limit_day.present? && off_date > Date.parse(limit_day)
      flash[:alert] = "まだスケジュールが未定です。"
      redirect_to offs_path and return
     end

     # ★ 追加：不可能日チェック（disabled_off_days）
    disabled = Setting.find_by(key: 'disabled_off_days')&.value.to_s
    disabled_list = disabled.split(/[,、，\s]+/).map(&:strip).reject(&:blank?)
    if disabled_list.include?(off_date.strftime('%Y-%m-%d'))
      flash[:alert] = "この日はスイミングがお休みのため、お休み登録できません。"
      redirect_to offs_path and return
    end

    # ★ 追加：不可能日時チェック（disabled_off_slots）
    if off_date_disabled_by_slots?(off_date)
      flash[:alert] = "この日はお休み登録不可能日に設定されているため、登録できません。"
      redirect_to offs_path and return
    end



    rescue ArgumentError, TypeError
      flash[:alert] = "無効なお休み日付が選択されました。"
      redirect_to offs_path and return
    end
    

    # ✅ 修正後：過去の日付だけ登録不可にする
    if off_date < Date.today
      flash[:alert] = "過去の日付には登録できません。お問い合わせしたい方は080-5011-9947までご連絡ください。"
      redirect_to offs_path and return
    end

    
      # 新しい Off オブジェクトを作成
      @off = Off.new(off_params)
      @off.off_month = off_date # off_month に Date 型の日付を設定
    
      # 子供データを検索
      child = current_customer.children.find_by(
       id: params.dig(:off, :child_id)
     )
    
      if child
        # 子供データが見つかった場合、必要な情報を設定
        @off.child_id = child.id
        @off.level = child.level
        @off.flag = 0
        @off.contact_time1 = child.contact_time1
        @off.contact_time2 = child.contact_time2
        @off.contact_dey1 = child.contact_dey1
        @off.contact_dey2 = child.contact_dey2
        @off.last_name = child.last_name # NOT NULL制約を満たすため
        @off.first_name = child.first_name # NOT NULL制約を満たすため
    
        # Off データの保存処理
        if @off.save(context: :public)
          flash[:notice] = 'お休みが登録されました。'
          redirect_to new_off_path(off_id: @off.id)
        else
          flash.now[:alert] = @off.errors.full_messages.join(", ")
          render :index
        end
      else
        flash.now[:alert] = @children.empty? ?
         "会員登録をお願いします" :
         "お子様を選択してください。"
       render :index, status: :unprocessable_entity
      end
    end

    def index
      @off = Off.new
    end

    def show
      @off = find_customer_off!(params[:id])
      redirect_to show_absences_off_path(id: @off.child_id)
    end

  def show_absences
    @child = current_customer.children.find(params[:id])

    # 既存の期限切れ判定を維持
    @child.offs.where(flag: 0)
      .where("off_month < ?", 3.months.ago.to_date)
      .find_each do |off|
        off.check_and_update_expiration
      end

    # お休み日の新しい順、1ページ10件
    @offs = @child.offs
      .where.not(off_month: nil)
      .order(off_month: :desc, id: :desc)
      .page(params[:page])
      .per(10)
  end

    def edit_absence
      @off = find_customer_off!(params[:id])
    if @off.flag != 0 || @off.transfer_registered? || @off.expired?
      redirect_to show_absences_off_path(id: @off.child_id),
        alert: "振替済み・期限切れのお休みは変更や削除ができません。"
      return
    end
      @off_date = @off.off_month # すでにdate型なので直接取得
    end

    def update_absence
      @off = find_customer_off!(params[:id])
    if @off.flag != 0 || @off.transfer_registered? || @off.expired?
      redirect_to show_absences_off_path(id: @off.child_id),
        alert: "振替済み・期限切れのお休みは変更や削除ができません。"
      return
    end
    
      begin
        # ユーザーが入力した日付をdate型として取得
        selected_date = Date.parse(params[:off][:off_month])

        weekday = %w[
          日曜日 月曜日 火曜日 水曜日
          木曜日 金曜日 土曜日
        ][selected_date.wday]

        allowed_days = [
          @off.child.contact_dey1,
          @off.child.contact_dey2
        ].compact.map(&:strip).uniq

        unless allowed_days.include?(weekday) || ScheduleOverrides.off_for?(selected_date, @off.child)
          flash.now[:alert] =
            "契約曜日（#{allowed_days.join('・')}）の日付を選択してください。"

          render :edit_absence, status: :unprocessable_entity
          return
        end
      rescue ArgumentError, TypeError
        flash[:alert] = "無効な日付が選択されました。"
        render :edit_absence and return
      end
    
      # 過去の日付に変更するのを防ぐ
      if selected_date < Date.today
        flash[:alert] = "過去の日付には変更できません。"
        render :edit_absence and return
      end

      # お休み登録不可能日の設定チェック
      if off_date_disabled_by_slots?(selected_date)
        flash[:alert] = "この日はお休み登録不可能日に設定されているため、変更できません。"
        render :edit_absence and return
      end
    
      # `off_month`を更新
      @off.assign_attributes(off_month: selected_date)
      if @off.save(context: :public)
        flash[:notice] = "お休み情報を更新しました。"
        redirect_to show_absences_off_path(id: @off.child_id)
      else
        flash.now[:alert] = @off.errors.full_messages.join("、")
        render :edit_absence
      end
    end

    def destroy
      @off = find_customer_off!(params[:id])
    if @off.flag != 0 || @off.transfer_registered? || @off.expired?
      redirect_to show_absences_off_path(id: @off.child_id),
        alert: "振替済み・期限切れのお休みは変更や削除ができません。"
      return
    end
      @off.destroy
      redirect_to show_absences_off_path(id: @off.child_id), notice: 'お休みがキャンセルされました'
    end

    private

  def find_customer_off!(id)
    Off.joins(:child)
      .where(children: { customer_id: current_customer.id })
      .find(id)
  end


  def load_registered_children
    @children = current_customer ?
      current_customer.children.order(:id).to_a : []
  end


    def off_params
      params.require(:off).permit(:off_month)
    end

    def off_date_disabled_by_slots?(date)
      slots_json = Setting.find_by(key: 'disabled_off_slots')&.value
      return false if slots_json.blank?

      begin
        slots = JSON.parse(slots_json)
      rescue JSON::ParserError
        return false
      end

      target_date = date.strftime('%Y-%m-%d')
      slots.any? { |slot| slot.is_a?(Hash) && slot['date'] == target_date }
    end
  end
