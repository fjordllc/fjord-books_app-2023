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
    @report = current_user.reports.new(report_params)
    #host = "http://localhost:3000/"

    if @report.save
      # if @report.content.include?(host)
      if contains_mentions?
        mentioned_params = @report.content.scan(/http:\/\/localhost:3000\/reports\/(\d+)/).uniq
        after_flatten = mentioned_params.flatten#.uniq
        after_flatten.each do |r|
          @mention = Mention.new(mentioning_report_id: @report.id, mentioned_report_id: r.to_i)
          @mention.save
        end
      end
      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
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
end
