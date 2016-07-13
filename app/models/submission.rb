class Submission < ActiveRecord::Base

  belongs_to :participant
  has_one :user, :through => :participant
  has_one :room, :through => :participant

  has_attached_file :image, :styles => { :medium => '300x300>', :thumb => '100x100>' }
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def has_rating?
    # Negative ratings are interpreted as nil
    rating.present? && rating >= 0
  end

  def normalized_rating
    has_rating? ? rating.to_f / room.max_rating : nil
  end

end
