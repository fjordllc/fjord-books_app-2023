# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[edit update destroy]

  def index
    @reports = Report.includes(:user).order(id: :desc).page(params[:page])
  end

  def show
    @report = Report.find(params[:id])
    @mentioned_reports = @report.mentioned_reports.order(created_at: :desc).order(id: :desc).includes(:user)
  end

  # GET /reports/new
  def new
    @report = current_user.reports.new
  end

  def edit; end

  def create
    all_save = true
    Report.transaction do
      @report = current_user.reports.new(report_params)
      all_save &= @report.save
      if contains_mentions?
        mentioned_params = @report.content.scan(/http:\/\/localhost:3000\/reports\/(\d+)/).uniq
        after_flattens = mentioned_params.flatten
        after_flattens.each do |r|
          @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: r)#"テスト")#r)#.to_i)
          all_save &= @mention.save
        end
      end
      raise ActiveRecord::Rollback unless all_save
    end
    if all_save
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      flash.now[:notice] = t('controllers.common.failed_post')
      render :new, status: :unprocessable_entity
    end
    # ActiveRecord::Base.transaction do # 追記
    #   @report = current_user.reports.new(report_params)

    #   if @report.save!
    #     if contains_mentions?
    #       mentioned_params = @report.content.scan(/http:\/\/localhost:3000\/reports\/(\d+)/).uniq
    #       after_flattens = mentioned_params.flatten
    #       after_flattens.each do |r|
    #         @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: "テスト")#r)#.to_i)
    #         @mention.save!
    #     end
    #   end
    #     redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    #   else
    #     render :new, status: :unprocessable_entity
    #   end
    # end
  end

  def update
    # 1.更新前に言及している日報を確認
    mentioning_before_update = @report.mentioning_reports.map {|r| r.id }

    if @report.update(report_params)
      # 2.更新する日報の言及先を確認
      mentioning_after_update = @report.content.scan(/http:\/\/localhost:3000\/reports\/(\d+)/).uniq.flatten.map{ |r| r.to_i }
      
      #消えた言及先と追加された言及を調べる
      missing = missing_mentions(mentioning_before_update, mentioning_after_update)
      added = added_mentions(mentioning_after_update, mentioning_before_update)
      
      #消えた言及先があれば削除
      if missing.any?
        missing.each do |m|
          destroy_target = Mention.find_by(mentioning_report_id: @report.id, mentioned_report_id: m.to_i)
          destroy_target.destroy
        end
      end

      #追加された言及先があれば追加
      if added.any?
        added.each do |a|
          @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: a.to_i)
          @mention.save
        end
      end
      redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy

    redirect_to reports_url, notice: t('controllers.common.notice_destroy', name: Report.model_name.human)
  end

  private

  def set_report
    @report = current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:title, :content)
  end

  def contains_mentions?
    host = "http://localhost:3000/" # 定数にするか要検討
    @report.content.include?(host)
  end

  def missing_mentions(before, after)
    before - after
  end

  def added_mentions(after, before)
    after - before
  end
end
