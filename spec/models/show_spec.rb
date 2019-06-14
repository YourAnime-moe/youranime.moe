require 'rails_helper'

RSpec.describe Show, type: :model do

  describe 'validation' do
    it 'is invalid when no titles are present'
    it 'is invalid when no descriptions are present'
    it 'is invalid when no roman title is present'
    it 'is valid when title and description are present'
  end

  describe 'sub dub' do
    it 'is subbed by default'
    it 'is dubbed'
    it 'is subbed'
    it 'is subbed and dubbed'
  end

  describe 'title and description' do
    it 'returns an English title when :en'
    it 'returns a French title when :fr'
    it 'returns a Japanese title when :jp'
    it 'returns the roman title by default'

    it 'returns an English description when :en'
    it 'returns a French description when :fr'
    it 'returns a Japanese description when :jp'
    it 'returns "no description" by default'
  end

  describe 'title' do
    it 'returns a default title if no title'
    it 'returns the alternate title if no title or default'
    it 'returns no title in html format if no title'
    it 'returns the title'
  end

  describe 'tags' do
    it 'is an array by default'
    it 'returns the saved tags'
  end

  describe 'add_tag' do
    it 'adds a tag specified in the Utils'
    it 'does not add a tag if not specified'
    it 'is null if the tag is blank'
  end

  describe 'is_published?' do
    it 'is not published by default'
    it 'is published'
    it 'is not published'
  end

end
