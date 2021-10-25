class VerifyWebhookSignature
  def self.call(signature:, body:, secret: ENV.fetch("CODY_GITHUB_WEBHOOK_SECRET"))
    new(signature: signature, body: body, secret: secret).call
  end

  def initialize(signature:, body:, secret:)
    if signature.blank?
      raise ArgumentError, "`signature` must not be blank"
    end

    if secret.blank?
      raise ArgumentError, "`secret` must not be blank"
    end

    @signature = signature
    @body = body
    @secret = secret
  end

  def call
    expected_signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret, body)}"
    ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
  end

  private

  attr_reader :signature
  attr_reader :body
  attr_reader :secret
end
