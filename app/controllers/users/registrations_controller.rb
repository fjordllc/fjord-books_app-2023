# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # Override
  def update_resource(resource, params)
    if params[:password].blank?
      # パスワード変更を伴わない場合はオーバーライドする
      # current_passwordが残っていると、これを更新しようとしてエラーになるのでparamsから削除
      params.delete(:current_password)
      resource.update_without_password(params)
    else
      # パスワード変更を伴う場合はデフォルトの実装を使う
      super
    end
  end
end
