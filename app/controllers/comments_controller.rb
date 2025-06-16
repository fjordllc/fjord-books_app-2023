# frozen_string_literal: true

class CommentsController < ApplicationController
  before_action :set_comment

  def show; end

  def edit; end

  def update
    # NOTE: 実装を複雑にしないよう、あえて保存失敗時の処理を考慮しないことにした（失敗時はシステムエラーとする）
    @comment.update!(comment_params)
  end

  def destroy
    @commentable = @comment.commentable
    @comment.destroy
  end

  private

  def set_comment
    @comment = current_user.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
