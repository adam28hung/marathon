#encoding: utf-8
module AwsCognito
  
  def sync
    begin
      if self.provider == 'facebook'
        cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_COGNITO_REGION'])
        resp = cognitoidentity.get_id(
          # required
          identity_pool_id: ENV['AWS_COGNITO_POOLID'],
          logins: { "graph.facebook.com" => self.access_token },
        )
      elsif self.provider == 'google_oauth2'
        cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_COGNITO_REGION'])
        resp = cognitoidentity.get_id(
          # required
          identity_pool_id: ENV['AWS_COGNITO_POOLID'],
          logins: { "accounts.google.com" => self.access_token },
        )
        # p resp['identity_id']
        cognitosync = Aws::CognitoSync::Client.new(region: ENV['AWS_COGNITO_REGION'])
        resp = cognitosync.list_datasets(
                # required
                identity_pool_id: ENV['AWS_COGNITO_POOLID'],
                # required
                identity_id: resp['identity_id'],
                # next_token: "String",
                max_results: 1,
              )
        # sync
        # resp = cognitosync.list_records(
        #         # required
        #         identity_pool_id: ENV['AWS_COGNITO_POOLID'],
        #         # required
        #         identity_id: resp['identity_id'],
        #         # required
        #         dataset_name: "MARATHON",
        #         last_sync_count: 1,
        #         next_token: "String",
        #         max_results: 2,
        #         sync_session_token: "",
        #       )
        p resp
      end
    rescue Aws::CognitoIdentity::Errors::ServiceError => e
      # rescues all errors returned by Amazon Cognito Identity
      p e
    end
  end

  # def member_getid(provider)
  #   if provider == 'facebook'
  #     cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_COGNITO_REGION'])
  #     resp = cognitoidentity.get_id(
  #       # required
  #       identity_pool_id: ENV['AWS_COGNITO_POOLID'],
  #       logins: { "graph.facebook.com" => self.access_token },
  #     )
  #     p resp
  #   elsif provider == 'google_oauth2'
  #     cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_COGNITO_REGION'])
  #     resp = cognitoidentity.get_id(
  #       # required
  #       identity_pool_id: ENV['AWS_COGNITO_POOLID'],
  #       logins: { "accounts.google.com" => self.access_token },
  #     )
  #     p resp
  #   end
  # end

  # def member_get_openid_token(provider)
  #   if provider == 'facebook'
  #     cognitoidentity = Aws::CognitoIdentity::Client.new(region: ENV['AWS_COGNITO_REGION'])
  #     resp = cognitoidentity.get_id(
  #       # required
  #       identity_pool_id: ENV['AWS_COGNITO_POOLID'],
  #       # logins: { "graph.facebook.com" => self.access_token },
  #     )
  #     p resp
  #   elsif provider == 'google_oauth2'
  #   end
  # end

  # def member_assum_role_with_web_identity
    
  # end

end