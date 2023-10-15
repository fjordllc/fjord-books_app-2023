# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment, only: %i[edit update destroy]
  before_action :set_commentable, only: :edit

  def create
    @comment = @commentable.comments.build(comment_params)

    if @comment.save
      flash.now.notice = t('controllers.common.notice_create', name: Comment.model_name.human)
    else
      @comments = @commentable.comments.where.not(id: nil)
      render_commentable
    end
  end

  def edit; end

  def destroy
    @comment.destroy
    flash.now.notice = t('controllers.common.notice_destroy', name: Comment.model_name.human)
  end

  def update
    if @comment.update(comment_params)
      flash.now.notice = t('controllers.common.notice_update', name: Comment.model_name.human)
    else
      render :edit, status, unprocessable_eintity
    end
  end

  private

  def set_commentable
    @commentable = @comment.commentable
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content, :user_id)
  end
end
