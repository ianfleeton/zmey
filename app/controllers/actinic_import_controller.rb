class ActinicImportController < ApplicationController
  before_filter :admin_required

  def index
  end
  def import_csv
    require 'csv'
    
    # delete current website content
    Page.destroy_all(['website_id = ?', @w.id])
    
    @primary_nav = Page.create_navigation @w, 'primary'
    @brochure_nav = Page.create_navigation @w, 'brochure'
    @sections_nav = Page.create_navigation @w, 'sections'
    
    @section_parent_stack = [@sections_nav]
    
    @parsed_file = CSV::Reader.parse(params[:import][:file])
    @parsed_file.each do |row|
      puts row[0]
      case row[0]
      when 'BrochurePage'
        do_brochure_page row
      when 'BrochureFragment'
        do_brochure_fragment row
      when 'End'
        do_end row
      when 'Section'
        do_section row
      end
    end
  end
  
  protected
  
  def tidy_content c
    c.gsub('\n', "\n").gsub('!!<', '').gsub('>!!', '')
  end
  
  def do_end row
    if row[1] == 'Section'
      @section_parent_stack.pop
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
    @current_page.website_id = @w.id
    @current_page.keywords = @current_page.description = 'change me'
    @current_page.save
  end

  def do_brochure_fragment row
    @current_page.content += 'h2. ' + row[1] + "\n\n" + tidy_content(row[4])
    @current_page.save
  end
  
  def do_section row
    @current_page = Page.new
    @current_page.name = @current_page.title = row[1]
    @current_page.slug = row[16].downcase.gsub('.html','').gsub('_', '-').squeeze('-')
    @current_page.website_id = @w.id
    @current_page.keywords = @current_page.description = 'change me'
    @current_page.content = tidy_content(row[2])
    @current_page.parent_id = @section_parent_stack.last.id
    @current_page.save
    @section_parent_stack.push @current_page
  end
end
