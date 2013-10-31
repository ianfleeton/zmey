module DiscountsHelper
  def reward_type_options
    [
      ['Free products', :free_products],
      ['Percentage off order', :percentage_off_order],
      ['Percentage off', :percentage_off],
    ]
  end
end
