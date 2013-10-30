module DiscountsHelper
  def reward_type_options
    [
      ['Free products', :free_products],
      ['Percentage off', :percentage_off]
    ]
  end
end
