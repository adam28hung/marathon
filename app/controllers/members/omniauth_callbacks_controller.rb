class Members::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # You need to implement the method below in your model (e.g. app/models/member.rb)
    @member = Member.from_omniauth(request.env["omniauth.auth"])

    if @member.persisted?

      update_token(@member, request.env["omniauth.auth"])

      sign_in_and_redirect @member, :event => :authentication #this will throw if @member is not activated
      set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_member_registration_url
    end
  end

  def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/member.rb)
      @member = Member.from_google_omniauth(request.env["omniauth.auth"])
      
      if @member.persisted?
        # update_token(@member, request.env["omniauth.auth"])
        auth = request.env["omniauth.auth"]
        @member.access_token = auth.extra.id_token
        @member.token_expires_at = Time.at(auth.credentials.expires_at)
        @member.save
        sign_in_and_redirect @member, :event => :authentication
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_member_registration_url
      end
  end

  private

  def update_token(member, omniauth)
    auth = omniauth  
    member.access_token = auth.credentials.token
    member.token_expires_at = Time.at(auth.credentials.expires_at)
    member.save
  end

end