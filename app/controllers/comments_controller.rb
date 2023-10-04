class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show edit update destroy]
  def create
    @comment = @commentable.comments.build(comment_params)

    if @comment.save
      redirect_to @commentable, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      @comments = @commentable.comments.where.not(id: nil)
      render_commentable
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :user_id)
  end
end
