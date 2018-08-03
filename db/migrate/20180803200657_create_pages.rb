class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
    	t.string :name, null: false, default: ''
		t.string :description, null: false, default: ''

      	t.timestamps
    end
  end
end
