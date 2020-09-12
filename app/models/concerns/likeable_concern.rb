# frozen_string_literal: true

module LikeableConcern
  extend ActiveSupport::Concern

  class_methods do
    def can_like_as(name)
      has_many(:reactions, -> { enabled }, class_name: 'Users::Like', inverse_of: name)
      has_many(:disabled_reactions, -> { disabled }, class_name: 'Users::Like', inverse_of: name)
      has_many(:all_reactions, class_name: 'Users::Like', inverse_of: name)
      has_many(:likes, -> { likes }, class_name: 'Users::Like', inverse_of: name )
      has_many(:dislikes, -> { dislikes }, class_name: 'Users::Like', inverse_of: name )

      send(:define_method, :like!) do |show|
        create_or_update_reaction_to(show, positive: true)
      end

      send(:define_method, :dislike!) do |show|
        create_or_update_reaction_to(show, positive: false)
      end

      send(:define_method, :liked?) do |show|
        has_reaction_to?(show, positive: true)
      end

      send(:define_method, :disliked?) do |show|
        has_reaction_to?(show, positive: false)
      end

      send(:define_method, :unreact_to!) do |show|
        return if unreacted_to?(show)

        reaction_to(show).disable!
      end
    end

    def can_be_liked_as(name)
      has_many(:reactions, -> { enabled }, class_name: 'Users::Like', inverse_of: name)
      has_many(:likes, -> { likes }, class_name: 'Users::Like', inverse_of: name )
      has_many(:dislikes, -> { dislikes }, class_name: 'Users::Like', inverse_of: name )

      send(:define_method, :liked_by?) do |user|
        likes.where(user: user).exists?
      end

      send(:define_method, :disliked_by?) do |user|
        dislikes.where(user: user).exists?
      end
    end
  end

  private

  def create_or_update_reaction_to(show, positive:)
    if has_already_reacted_to?(show)
      reaction_to(show).update(value: positive, is_disabled: false)
    else
      likes.create!(show: show, value: positive)
    end
  end

  def has_already_reacted_to?(show)
    reaction_to(show).present?
  end

  def has_reaction_to?(show, positive:)
    reactions.where(show: show, value: positive).exists?
  end

  def reaction_to(show)
    all_reactions.where(show: show).first
  end

  def unreacted_to?(show)
    disabled_reactions.where(show: show).exists?
  end
end
