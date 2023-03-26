class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.import_id
    "id"
  end
end
