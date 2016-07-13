class User < ActiveRecord::Base

  has_many :participants
  has_many :rooms, :through => :participants
  has_many :submissions, :through => :participants
  has_many :pseudonyms
  has_many :lti_tool_consumer_tokens

  # Other Devise modules available:
  # :omniauthable, :confirmable, :recoverable, :registerable, :rememberable, :trackable, :timeoutable, :lockable
  devise :database_authenticatable, :validatable

  before_validation :assign_password, on: :create

  def assign_password
    self.password = SecureRandom.base64(20)
  end

  def self.login_to_email(login)
    # NOTE: This SFU-specific code needs to be rewritten to make this application generic.
    login =~ /.*@.*/ ? login : "#{login}@sfu.ca"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def token_for_tool_consumer(tool_consumer)
    lti_tool_consumer_tokens.find_by(lti_tool_consumer: tool_consumer)
  end

end
