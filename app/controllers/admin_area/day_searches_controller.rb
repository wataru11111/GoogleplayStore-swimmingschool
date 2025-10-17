module AdminArea
  class DaySearchesController < ApplicationController
    before_action :authenticate_admin!

    def index
      @search = ContractDaySearch.new(day: params[:day]) if params[:day].present?
      @search ||= ContractDaySearch.new
      @children = params[:day].present? ? @search.results : []
    end

    def broadcast_sms
      @search = ContractDaySearch.new(day: params[:day])
      unless @search.valid?
        redirect_to admin_area_day_searches_path(day: params[:day]), alert: @search.errors.full_messages.join(', ')
        return
      end

      body = params[:body].to_s.strip
      if body.blank?
        redirect_to admin_area_day_searches_path(day: @search.day), alert: 'メッセージ本文を入力してください'
        return
      end

      children = @search.results
      numbers = children.map { |c| c.customer&.telephone_number }.compact.uniq

      if numbers.empty?
        redirect_to admin_area_day_searches_path(day: @search.day), alert: '対象者の電話番号が見つかりません'
        return
      end

      results = SmsBroadcastService.new.broadcast(numbers, body)
      success = results.select { |r| r.status == 'queued' || r.status == 'sent' }

      if success.any?
        redirect_to admin_area_day_searches_path(day: @search.day), notice: "SMS送信完了: #{success.size}件"
      else
        redirect_to admin_area_day_searches_path(day: @search.day), alert: 'SMS送信に失敗しました'
      end
    end
  end
end
