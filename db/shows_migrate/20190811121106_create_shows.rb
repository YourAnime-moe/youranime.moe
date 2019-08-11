# encoding: UTF-8

class CreateShows < ActiveRecord::Migration[6.1]
  def change
    create_table :shows do |t|
      t.string :show_type, null: false, default: 'anime'
      t.boolean :dubbed, default: false, null: false
      t.boolean :subbed, default: true, null: false
      t.boolean :published, null: false, default: false
      t.text :plot, null: false, default: ''
      t.date :released_on, null: false
      t.date :published_on
      t.boolean :featured, null: false, default: false
      t.boolean :recommended, null: false, default: false
      t.string :banner_url, null: false, default: '/img/404.jpg'
      t.text :en_description, default: 'No description'
      t.text :fr_description, default: 'Aucune description'
      t.text :jp_description, default: '概要無し'
      t.string :en_title, null: false, default: 'Title'
      t.string :fr_title, null: false, default: 'Titre'
      t.string :jp_title, null: false, default: 'タイトル'
      t.string :roman_title, null: false, default: 'taitoru'
      t.integer :queue_id

      t.index :banner_url
      t.index :roman_title
      t.index [:en_title, :published]
      t.index [:fr_title, :published]
      t.index [:jp_title, :published]

      t.timestamps
    end
  end
end
