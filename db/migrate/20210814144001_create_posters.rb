class CreatePosters < ActiveRecord::Migration[6.1]
  def change
    create_table :posters do |t|
      t.string :original, default: '/img/404.jpg', null: false
      t.string :large, default: '/img/404.jpg'
      t.string :medium, default: '/img/404.jpg'
      t.string :small, default: '/img/404.jpg'
      t.string :tiny, default: '/img/404.jpg'

      t.timestamps
    end
  end
end
