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
    ActiveRecord::Base.transaction do
      @report = current_user.reports.new(report_params)
      saveable_report = @report.save
      unless saveable_report
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      if contains_mentions?
        contained_report_id.each do |r|
          @mention = create_mention(r)
          saveable_mention = @mention.save
          unless saveable_mention
            render 'public/500.ja.html', status: :internal_server_error
            raise ActiveRecord::Rollback
          end
        end
      end

      redirect_to @report, notice: t('controllers.common.notice_create', name: Report.model_name.human) if saveable_report || saveable_mention
    end
  end

  def update
    mentions_before_update = @report.mentioning_reports

    ActiveRecord::Base.transaction do
      updatable_report = @report.update(report_params)
      unless updatable_report
        render :edit, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      destroy_lost_mentions(mentions_before_update, contained_report_id, @report)
      create_added_mentions(contained_report_id, mentions_before_update)

      if updatable_report || destroy_lost_mentions || create_added_mentions
        redirect_to @report, notice: t('controllers.common.notice_update', name: Report.model_name.human)
      end
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
    @report.content.include?('http://localhost:3000/')
  end

  def contained_report_id
    @report.content.scan(Report::HOST_REGEXP).uniq.flatten
  end

  def create_mention(id)
    Mention.new(mentioning_report_id: @report.id, mentioned_report_id: id)
  end

  def lost_mentions(before, after)
    before - after
  end

  def added_mentions(after, before)
    after - before
  end

  def destroy_lost_mentions(mentions_before_update, contained_report_id, report)
    lost = lost_mentions(mentions_before_update, contained_report_id)
    return unless lost.any?

    lost.each do |l|
      destruction_target = Mention.find_by(mentioning_report_id: report.id, mentioned_report_id: l)
      destroyable_mention = destruction_target.destroy
      unless destroyable_mention
        render 'public/500.ja.html', status: :internal_server_error
        raise ActiveRecord::Rollback
      end
    end
  end

  def create_added_mentions(contained_report_id, mentions_before_update)
    added = added_mentions(contained_report_id, mentions_before_update)
    return unless added.any?

    added.each do |a|
      additional_mention = create_mention(a)
      updatable_mention = additional_mention.save
      unless updatable_mention
        render 'public/500.ja.html', status: :internal_server_error
        raise ActiveRecord::Rollback
      end
    end
  end
end
