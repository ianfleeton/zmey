# Actinic CSV importer for v8.5.3.0.0.0.IDHB
class ActinicImporter
  def initialize(website)
    @website = website
  end

  def import_csv(file, delete_current_website_content = true)
    require 'csv'

    @context = nil

    @primary_nav = Page.find_by(slug: 'primary')
    raise 'Primary navigation required' unless @primary_nav

    ids = @primary_nav.children.collect {|c| c.id.to_s}
    ids << @primary_nav.id.to_s
    ids = ids.join(',')

    if delete_current_website_content
      @website.pages.destroy_all("id NOT IN (#{ids})")
      @website.products.destroy_all
    end

    @brochure_nav = create_navigation('brochure')
    @sections_nav = create_navigation('catalogue')
    
    @section_parent_stack = [@sections_nav]

    @parsed_file = CSV.parse(File.open(file), col_sep: ';')
    @parsed_file.each do |row|
      puts row[0]
      case row[0]
      when 'BrochurePage'
        do_brochure_page row
      when 'BrochureFragment'
        do_brochure_fragment row
      when 'Customer'
        do_customer row
      when 'CustomerBuyer'
        do_customer_buyer row
      when 'CustomProperty'
        do_custom_property row
      when 'End'
        do_end row
      when 'Product'
        do_product row
      when 'Section'
        do_section row
      end
    end
    true
  end
  
  protected

  def create_navigation(slug)
    Page.create(
      title: slug.titleize,
      name: slug.titleize,
      slug: slug,
      keywords: slug,
      description: slug
    )
  end

  def tidy_content c
    return '' if c.nil?
    c.gsub('\n', "\n").gsub('!!<', '').gsub('>!!', '')
  end

  def do_end row
    @context = :section
    if row[1] == 'Section'
      @section_parent_stack.pop
      @current_page = @section_parent_stack.last
    end
  end
  
  def do_brochure_page row
    @current_page = Page.new
    @current_page.name = @current_page.title = row[1]
    @current_page.slug = row[2].downcase.gsub('.html','').gsub('_', '-').squeeze('-')
    if @current_page.slug == 'index'
      @current_page.slug = ''
      @current_page.name = 'Home'
      @current_page.parent_id = @primary_nav.id
    else
      @current_page.parent_id = @brochure_nav.id
    end
    @current_page.website_id = @website.id
    @current_page.keywords = @current_page.description = 'change me'
    @current_page.save
  end

  def do_brochure_fragment row
    @current_page.content += 'h2. ' + row[1] + "\n\n" + tidy_content(row[4])
    @current_page.save
  end

  def do_customer(row)
    m = v853_customer_mapping
    @customer = User.find_by(email: row[m[:email_address]])
    @customer ||= User.new
    @customer.company_name = row[m[:name]]
    @customer.external_reference = row[m[:external_reference]].nil? ? '' : row[m[:external_reference]]
    @customer.email = row[m[:email_address]]
    @customer.name = row[m[:contact_name]]
    @customer.notes = row[m[:comments]].nil? ? '' : row[m[:comments]].gsub('\n', "\n")
  end

  def do_customer_buyer(row)
    m = v853_customer_buyer_mapping
    @customer.password = row[m[:password]]
    @customer.active = true
    unless @customer.save
      pp @customer.errors
    end
  end

  def do_custom_property(row)
    map = {
      'BACKGROUND' => :background=,
      'BRAND' => :part_brand=,
      'EXCLUDEWORDS' => :exclude_words=,
      'INFOPIC' => :info_pic=,
      'SECTIONNOTICE' => :section_notice=,
      'SECTIONTYPE' => :section_type=,
      'SHIPPING' => :shipping_options=,
      'SUBSECTIONPIC' => :subsection_pic=,
      'TITLEPIC' => :title_pic=,
      'TITLETEXT' => :title_text=
    }
    property = row[1]
    value = row[2]
    if method = map[property]
      if @current_page && @context == :section
        @current_page.send(method, value)
        @current_page.save
      elsif @context == :product && @product.respond_to?(method)
        @product.send(method, value)
        @product.save
      end
    end
  end

  def do_product(row)
    m = v853_product_mapping
    @context = :product
    @product = Product.new
    @product.sku = row[m[:product_reference]]
    @product.name = row[m[:short_description]]
    @product.description = row[m[:full_description]].nil? ? '' : row[m[:full_description]].gsub('\n', '')
    @product.price = row[m[:price]].to_f / 100.0
    @product.tax_type = Product::EX_VAT
    @product.actinic_image_filename = row[m[:image_filename]].nil? ? '' : row[m[:image_filename]]
    @product.actinic_filename = row[m[:extended_info_page_name]]
    @product.website_id = @website.id
    @product.save!
    if @current_page
      ProductPlacement.create!(page_id: @current_page.id, product_id: @product.id)
      @product.page_title = "#{@product.name} #{@current_page.title_text}"
      @product.save
    end
  end

  def do_section row
    m = v853_section_mapping
    require 'pp'
    pp row

    filename = row[m[:page_name]]
    return if filename.nil?

    is_deleted = row[m[:is_deleted]] == '1'
    return if is_deleted

    @current_page = Page.new(
      parent_id: @section_parent_stack.last ? @section_parent_stack.last.id : nil
    )
    @current_page.name = row[m[:section_name]]
    @current_page.title = row[m[:page_title]].nil? ? row[m[:section_name]] : row[m[:page_title]]
    @current_page.actinic_filename = filename
    @current_page.slug = filename.downcase.gsub('.html','').gsub('_', '-').squeeze('-')
    @current_page.keywords = row[m[:section_meta_keywords]].nil? ? 'change me' : row[m[:section_meta_keywords]]
    @current_page.description = row[m[:section_meta_description]].nil? ? 'change me' : row[m[:section_meta_description]]
    @current_page.content = tidy_content(row[m[:section_description]])
    @current_page.visible = row[m[:section_hidden_on_web_site]] != '1'

    if(!@current_page.save)
      pp @current_page
      pp @current_page.errors
      raise 'failed to save'
    end
    @section_parent_stack.push @current_page
  end

  protected

    include ActinicMappingsV853
end
