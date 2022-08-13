class CreateMedia < ActiveRecord::Migration[7.1]
  def change
    create_table :media do |t|
      t.bigint :id_mal
      
      # titles
      t.string :romaji
      t.string :english
      t.string :native
      t.string :user_preferred

      t.string :type
      t.string :format
      t.string :status
      t.string :description
      t.string :html_description

      t.date :start_date
      t.date :end_date
      t.string :season
      t.integer :season_year
      t.integer :season_int
      t.integer :episodes
      t.integer :duration
      t.integer :chapters
      t.integer :volumes
      
      t.string :xl_cover_url
      t.string :l_cover_url
      t.string :m_cover_url
      t.string :color
      t.string :banner_url

      t.boolean :is_adult

      t.timestamps
    end
  end
end
