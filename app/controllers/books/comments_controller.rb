# frozen_string_literal: true

class Books::CommentsController < ApplicationController
  def create
    book = Book.find(params[:book_id])
    comment = book.comments.build(comment_params)
    comment.user = current_user
    # NOTE: 実装を複雑にしないよう、あえて保存失敗時の処理を考慮しないことにした（失敗時はシステムエラーとする）
    comment.save!
    redirect_to book, notice: t('controllers.common.notice_create', name: Comment.model_name.human)
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
