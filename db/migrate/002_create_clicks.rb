class CreateClicks < ActiveRecord::Migration
  def self.up
    create_table :clicks do |t|
      t.integer  :short_url_id
      t.text    :referrer
      t.timestamps
    end

    add_index(:clicks, :short_url_id)
  end

  def self.down
    drop_table :clicks
  end
end