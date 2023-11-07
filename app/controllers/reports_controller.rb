class ReportsController < ApplicationController

  def index
    @reports = Report.order(:id).page(params[:page])
  end

	def new
    @report = Report.new
  end

	def create
    @user = current_user
    @report = @user.reports.create(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to report_url(@report), notice: t('controllers.common.notice_create', name: Report.model_name.human) }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
		end
  end

  def show
    @report = Report.find(params[:id])
  end

	private

  def report_params
    params.require(:report).permit(:title, :content)
  end

end
