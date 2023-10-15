# frozen_string_literal: true

class Reports::CommentsController < CommentsController
  private

  def set_commentable
    @commentable = Report.find(params[:report_id])
  end

  def render_commentable
    @report = @commentable
    render 'reports/show', status: :unprocessable_entity
  end
end
