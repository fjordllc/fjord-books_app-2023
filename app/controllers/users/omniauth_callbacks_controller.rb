# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'GitHub') if is_navigational_format?
    else
      alert = t('devise.omniauth_callbacks.failure', kind: 'GitHub', reason: @user.errors.full_messages.join(', '))
      redirect_to new_user_session_url, alert:
    end
  end

  def failure
    redirect_to new_user_session_url
  end
end
