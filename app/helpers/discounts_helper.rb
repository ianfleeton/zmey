module DiscountsHelper
  def reward_type_options
    [
      ['Free products', :free_products],
      ['Amount off order', :amount_off_order],
      ['Percentage off order', :percentage_off_order],
      ['Percentage off', :percentage_off],
    ]
  end
end
