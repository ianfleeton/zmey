class OrdersController < ApplicationController
  include ActionView::Helpers::NumberHelper
  include ProductsHelper

  before_filter :admin_or_manager_required, :only => [:destroy]

  before_filter :find_order, :only => [:show, :destroy, :invoice]
  before_filter :require_order, :only => [:select_payment_method, :receipt]
  before_filter :user_required, :only => [:index, :show, :invoice]

  def index
    if admin_or_manager?
      @can_delete = true
      if params[:user_id]
        @orders = User.find(params[:user_id]).orders.where(:website_id => @w.id)
      else
        @orders = @w.orders
      end
    else
      @can_delete = false
      @orders = @current_user.orders
    end
  end
  
  def select_payment_method
  end

  def receipt
    redirect_to :controller => 'basket', :action => 'index' and return unless (@order.payment_received? or @order.status==Order::PAYMENT_ON_ACCOUNT)
    @google_ecommerce_tracking = true
  end
  
  def show
    if admin_or_manager? or @current_user.id==@order.user_id
      render :action => 'receipt'
    else
      redirect_to :root, :notice => 'You do not have permission to view that order.'
    end
  end

  def purge_old_unpaid
    Order.purge_old_unpaid
    redirect_to :action => 'index', :notice => 'Old and unpaid orders purged.'
  end

  def destroy
    @order.destroy
    redirect_to :action => "index", :notice => "Order deleted."
  end

  def invoice
    url_dir = "/invoices/#{@order.hash.to_s}"
    dir = "#{Rails.root.to_s}/public#{url_dir}"
    FileUtils.makedirs(dir)
    filename = "#{dir}/Invoice-#{@order.order_number}.pdf"
    url_filename = "#{url_dir}/Invoice-#{@order.order_number}.pdf"

    Prawn::Document.generate(filename, :page_size => "A4") do |pdf|
      spacing = 3
      pdf.font 'fonts/Aller_Lt.ttf'
      pdf.font_size 18
      pdf.text "Invoice number #{@order.order_number}"
      pdf.move_down 24
      pdf.font_size 11
      pdf.text "Invoice created at: #{@order.created_at}"
      pdf.move_down 24

      address_top = 700

      pdf.bounding_box([0, address_top], :width => 200, :height => 200) do
        pdf.text @w.invoice_details, :leading => 4
      end

      pdf.bounding_box([300, address_top], :width => 200, :height => 200) do
        pdf.text("Customer:\n" + @current_user.name + "\n" +
          @order.address_line_1 + "\n" + @order.address_line_2 + "\n" +
          @order.town_city + "\n" + @order.county + "\n" + @order.postcode +
          "\n" + @order.country.to_s, :leading => 4)
      end

      cells = []
      cells << ["Product", "Price"]
      @order.order_lines.each do |line|
        cells << [line.product_name, formatted_gbp_price(line.line_total)]
      end
      cells << ["Order total:", formatted_gbp_price(@order.total)]

      t = Prawn::Table.new(cells, pdf)
      t.draw
    end

    send_file(filename)
  end

  protected

  # get valid order from current session or send user back to their basket
  def require_order
    @order = Order.from_session session
    if @order.nil?
      redirect_to({:controller => 'basket', :action => 'index'},
        :notice => "We couldn't find an order for you.")
    end
  end

  # get specific order
  def find_order
    @order = Order.find_by_id_and_website_id(params[:id], @w.id)
    if @order.nil?
      redirect_to :action => 'index', :notice => 'Cannot find order.'
    end
  end
end
