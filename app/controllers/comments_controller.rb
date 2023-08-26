# frozen_string_literal: true

class CommentsController < ApplicationController
  def destroy
    comment = current_user.comments.find(params[:id])
    commentable = comment.commentable
    comment.destroy
    redirect_to commentable, notice: t('controllers.common.notice_destroy', name: Comment.model_name.human)
  end
end
