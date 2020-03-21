class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.import_id
    "id"
  end
end
