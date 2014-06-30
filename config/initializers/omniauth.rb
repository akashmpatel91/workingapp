OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '768223386561707','48e088ee35b5f605318afb1e0efe265d', :setup => true ,:scope => 'offline_access,user_activities'
end