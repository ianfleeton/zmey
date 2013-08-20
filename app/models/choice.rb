class Choice < ActiveRecord::Base
  belongs_to :feature
  has_many :feature_selections
  has_many :basket_items, through: :feature_selections, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :feature_id

  after_save :create_permutations
  before_destroy :update_permutations

  def create_permutations
    return unless feature.component

    if feature.component.features.count == 1
      # just add the permutation
      Permutation.create!(component_id: feature.component.id, valid_selection: true, permutation: "_#{id}_")
      return
    end

    if feature.choices.count == 1
      # append ID to existing permutations
      feature.component.permutations.each do |permutation|
        permutation.permutation += "_#{id}_"
        permutation.save
      end
      return
    end

    other_features = feature.component.features - [feature]
    # populate choices
    # choice_array is 2D [feature][choice] = choice ID
    num_permutations = 1
    num_features = other_features.count
    choice_array = []
    f_index = 0

    other_features.each do |other_feature|
      choices = other_feature.choices
      num_permutations *= choices.count
      choice_array[f_index] = []

      c_index = 0
      choices.each do |choice|
        choice_array[f_index][c_index] = choice.id
        c_index += 1
      end
      f_index += 1
    end

    (0...num_permutations).each do |c_index|
      permutation_array = []
      change = 1
      (0...choice_array.count).each do |f_index|
        permutation_array[f_index] = choice_array[f_index][(c_index / change) % choice_array[f_index].count]
        change *= choice_array[f_index].count
      end
      permutation_array << id

      permutation_array.sort! # lookups depend on choices being sorted within the permutation
      string = ''
      (0...permutation_array.count).each {|i| string += "_#{permutation_array[i]}_"}
      Permutation.create!(component_id: feature.component.id, valid_selection: true, permutation: string)
    end
  end

  def update_permutations
    return unless feature.component

    match = "%_#{id}_%"

    if feature.choices.count == 1
      Permutation.where(['component_id = ? AND permutation LIKE ?', feature.component.id, match]).each do |permutation|
        permutation.permutation.gsub!("_#{id}_", '')
        permutation.save unless permutation.permutation.blank?
      end
    else
      connection.delete "DELETE FROM permutations WHERE component_id = #{connection.quote(feature.component.id)}" +
      " AND permutation LIKE #{connection.quote(match)}"
    end
  end
end
