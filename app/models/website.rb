class Website < ActiveRecord::Base
  validates_inclusion_of :custom_view_resolver, in: %w{CustomView::DatabaseResolver CustomView::ThemeResolver}, allow_blank: true
  validates :email, presence: true
  validates_uniqueness_of :google_analytics_code, allow_blank: true
  validates_format_of :google_analytics_code, with: /\AUA-\d\d\d\d\d\d(\d)?(\d)?-\d\Z/, allow_blank: true
  validates_presence_of :name
  validates_numericality_of :port, greater_than: 0, less_than: 65536, only_integer: true
  validates_inclusion_of :private, in: [true, false]
  validates_inclusion_of :render_blog_before_content, in: [true, false]
  validates_inclusion_of :scheme, in: %w{http https}
  validates :subdomain, presence: true, uniqueness: true, format: /\A[a-z0-9]+[-a-z0-9]*\Z/i

  # UPG Atlas validations
  validates :upg_atlas_secuphrase, length: { in: 6..9, allow_blank: true }

  # WorldPay validations
  validates_inclusion_of :worldpay_active, in: [true, false]
  validates_inclusion_of :worldpay_test_mode, in: [true, false]
  # these details are required only if WorldPay is active
  validates_presence_of :worldpay_installation_id, if: Proc.new { |website| website.worldpay_active? }
  validates_presence_of :worldpay_payment_response_password, if: Proc.new { |website| website.worldpay_active? }

  validates :country_id, presence: true

  has_one :preferred_delivery_date_settings, dependent: :delete
  has_many :custom_views, dependent: :delete_all
  has_many :forums, dependent: :destroy
  has_many :enquiries, -> { order 'created_at DESC' }, dependent: :destroy
  has_many :webhooks, dependent: :delete_all
  belongs_to :blog, class_name: 'Forum'
  belongs_to :country

  def only_accept_payment_on_account?
    accept_payment_on_account and !(worldpay_active)
  end

  def image_uploader(image_params)
    ImageUploader.new(image_params) do |image|
      yield image if block_given?
    end
  end

  # Returns an initialized custom view resolver, or nil if there isn't one.
  def build_custom_view_resolver
    if custom_view_resolver.present?
      Kernel.const_get(custom_view_resolver).new(self)
    else
      nil
    end
  end

  # Constructs a URL from the website's scheme, domain and port.
  def url
    "#{scheme}://#{domain}" + ((port == 80) ? '' : ":#{port}")
  end

  def to_s
    subdomain
  end

  # Returns a hash of settings usable with ActionMailer.
  def smtp_settings
    {
      address: smtp_host,
      password: smtp_password,
      port: smtp_port,
      user_name: smtp_username
    }
  end
end
