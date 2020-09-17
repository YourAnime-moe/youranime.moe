class AddPosterUrlToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :poster_url, :string, default: '/img/404.jpg', null: false
  end
end
