require 'hammer_cli_foreman/openid_connect'

module HammerCLIForeman
  module Api
    module Oauth
      class PasswordGrant < ApipieBindings::Authenticators::TokenAuth
        attr_accessor :oidc_token_endpoint, :oidc_client_id, :user, :password, :token

        def initialize(oidc_token_endpoint, oidc_client_id, user, password)
          @oidc_token_endpoint = oidc_token_endpoint
          @oidc_client_id = oidc_client_id
          @user = user
          @password = password
          super set_token(oidc_token_endpoint, oidc_client_id, user, password)
        end

        def authenticate(request, token)
          if HammerCLI.interactive?
            set_token_interactively
          end
          super
        end

        def set_token_interactively
          @token ||= set_token(get_oidc_token_endpoint, get_oidc_client_id, get_user, get_password)
        end

        def set_token(input_oidc_token_endpoint, input_oidc_client_id, input_user, input_password)
          @oidc_token_endpoint = input_oidc_token_endpoint if input_oidc_token_endpoint
          @user = input_user
          @password = input_password
          @oidc_client_id = input_oidc_client_id if input_oidc_client_id
          if @user && @password && @oidc_token_endpoint && @oidc_client_id
            @token = HammerCLIForeman::OpenidConnect.new(
              @oidc_token_endpoint, @oidc_client_id).get_token(@user, @password)
          else
            @token = nil
          end
        end

        def error(ex)
          if ex.is_a?(RestClient::InternalServerError)
            self.clear
            message = _('Invalid credentials or oidc-client-id or oidc-token-endpoint.')
            begin
              message = JSON.parse(ex.response.body)['error']['message']
            rescue
            end
            UnauthorizedError.new(message)
          end
        end

        private

        def get_user
          @user ||= ask_user(_("Username:%s") % " ")
        end

        def get_password
          @password ||= ask_user(_("Password:%{wsp}") % {:wsp => " "}, true)
        end

        def get_oidc_token_endpoint
          @oidc_token_endpoint ||= ask_user(_("Openidc Provider Token Endpoint:%s") % " ")
        end

        def get_oidc_client_id
          @oidc_client_id ||= ask_user(_("Client ID:%s") % " ")
        end

        def ask_user(prompt, silent=false)
          if silent
            HammerCLI.interactive_output.ask(prompt) { |q| q.echo = false }
          else
            HammerCLI.interactive_output.ask(prompt)
          end
        end
      end
    end
  end
end
