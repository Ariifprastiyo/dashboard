# frozen_string_literal: true

class PublicationAssociation < ApplicationRecord
  belongs_to :social_media_publication
  belongs_to :associable, polymorphic: true
end
