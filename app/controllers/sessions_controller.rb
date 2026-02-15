class SessionsController < ApplicationController
  layout "login", only: [:new]

  # GET /login
  def new
    auth = Rails.application.config.hanzo_auth
    if auth.enabled
      # Redirect to Hanzo IAM login
      redirect_uri = CGI.escape(auth_callback_url)
      redirect_to "https://#{auth.iam_domain}/login?client_id=#{auth.client_id}&redirect_uri=#{redirect_uri}", allow_other_host: true
      return
    end
    # Otherwise render the local login form
  end

  # POST /login (local email/password auth)
  def create
    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to "/"
    else
      redirect_to "/login", notice: "Log in failed. Please check your email and password."
    end
  end

  # GET /auth/callback?code=<authorization_code>
  def callback
    auth = Rails.application.config.hanzo_auth
    code = params[:code]

    if code.blank?
      error = params[:error] || "missing authorization code"
      Rails.logger.warn "Auth callback error: #{error} - #{params[:error_description]}"
      redirect_to "/login", notice: "Authentication failed: #{error}"
      return
    end

    # Exchange authorization code for token
    token = exchange_code(auth, code)
    if token.nil?
      redirect_to "/login", notice: "Authentication failed. Please try again."
      return
    end

    # Parse JWT to get user info
    claims = parse_jwt(token["access_token"])
    if claims.nil?
      redirect_to "/login", notice: "Invalid authentication token."
      return
    end

    # Find or create user from IAM claims
    user = find_or_create_user(claims)
    session[:user_id] = user.id

    redirect_to "/"
  end

  # GET /logout
  def destroy
    auth = Rails.application.config.hanzo_auth
    session[:user_id] = nil

    if auth.enabled
      redirect_uri = CGI.escape(root_url)
      redirect_to "https://#{auth.iam_domain}/logout?redirect_uri=#{redirect_uri}", allow_other_host: true
    else
      redirect_to "/login"
    end
  end

  private

  def auth_callback_url
    "#{request.protocol}#{request.host_with_port}/auth/callback"
  end

  def exchange_code(auth, code)
    uri = URI("https://#{auth.iam_domain}/oauth/token")
    response = Net::HTTP.post_form(uri, {
      "grant_type"    => "authorization_code",
      "code"          => code,
      "client_id"     => auth.client_id,
      "client_secret" => auth.client_secret,
      "redirect_uri"  => auth_callback_url
    })

    if response.code.to_i == 200
      JSON.parse(response.body)
    else
      Rails.logger.error "Token exchange failed (#{response.code}): #{response.body}"
      nil
    end
  rescue StandardError => e
    Rails.logger.error "Token exchange error: #{e.message}"
    nil
  end

  def parse_jwt(token_str)
    return nil if token_str.blank?

    parts = token_str.split(".")
    return nil unless parts.length == 3

    # Verify HMAC-SHA256 signature if secret is configured
    jwt_secret = Rails.application.config.hanzo_auth.jwt_secret
    if jwt_secret.present?
      signing_input = "#{parts[0]}.#{parts[1]}"
      expected_sig = Base64.urlsafe_encode64(
        OpenSSL::HMAC.digest("SHA256", jwt_secret, signing_input),
        padding: false
      )
      unless ActiveSupport::SecurityUtils.secure_compare(parts[2], expected_sig)
        Rails.logger.warn "JWT signature verification failed"
        return nil
      end
    end

    # Decode payload
    payload = Base64.urlsafe_decode64(parts[1] + "=" * (4 - parts[1].length % 4))
    claims = JSON.parse(payload)

    # Check expiration
    if claims["exp"] && Time.now.to_i > claims["exp"].to_i
      Rails.logger.warn "JWT expired"
      return nil
    end

    claims
  rescue StandardError => e
    Rails.logger.error "JWT parse error: #{e.message}"
    nil
  end

  def find_or_create_user(claims)
    email = claims["email"]
    user = User.find_by(email: email)

    unless user
      user = User.new(
        email: email,
        name: claims["name"] || email.split("@").first,
        password: SecureRandom.hex(32),
        password_confirmation: SecureRandom.hex(32)
      )
      # Set random password since OAuth users don't use password auth
      random_pass = SecureRandom.hex(32)
      user.password = random_pass
      user.password_confirmation = random_pass
      user.save!
      Rails.logger.info "Created OAuth user: #{email} (IAM sub: #{claims['sub']})"
    end

    user
  end
end
