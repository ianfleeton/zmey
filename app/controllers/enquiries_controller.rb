class EnquiriesController < ApplicationController
  include SpamProtection
  
  before_filter :admin_or_manager_required, :except => [:new, :create, :thank_you, :current_time]
  
  # GET /enquiries
  # GET /enquiries.xml
  def index
    @enquiries = @w.enquiries

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @enquiries }
    end
  end

  # GET /enquiries/1
  # GET /enquiries/1.xml
  def show
    @enquiry = Enquiry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @enquiry }
    end
  end

  # GET /enquiries/new
  # GET /enquiries/new.xml
  def new
    @title = 'Enquiry'
    @enquiry = Enquiry.new
    unless @current_user.nil?
      @enquiry.name = @current_user.name
      @enquiry.email = @current_user.email
    end
    @enquiry.enquiry = params[:enquiry] unless params[:enquiry].nil?

    respond_to do |format|
      format.html { render :layout => 'application' } # new.html.erb
      format.xml  { render :xml => @enquiry }
    end
  end

  # GET /enquiries/1/edit
  def edit
    @enquiry = Enquiry.find(params[:id])
  end

  # POST /enquiries
  # POST /enquiries.xml
  def create
    @title = 'Enquiry'
    @enquiry = Enquiry.new(params[:enquiry])
    
    unless good_token?
      render :action => 'new', :layout => 'application'
      return
    end
    
    @enquiry.website_id = @w.id

    respond_to do |format|
      if @enquiry.save
        EnquiryNotifier.enquiry(@w, @enquiry).deliver
        format.html { redirect_to(:action => 'thank_you') }
        format.xml  { render :xml => @enquiry, :status => :created, :location => @enquiry }
      else
        format.html { render :action => "new", :layout => 'application' }
        format.xml  { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end

  def thank_you
    @title = 'Thank you for your enquiry'
    render :layout => 'application'
  end

  # PUT /enquiries/1
  # PUT /enquiries/1.xml
  def update
    @enquiry = Enquiry.find(params[:id])

    respond_to do |format|
      if @enquiry.update_attributes(params[:enquiry])
        flash[:notice] = 'Enquiry was successfully updated.'
        format.html { redirect_to(@enquiry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /enquiries/1
  # DELETE /enquiries/1.xml
  def destroy
    @enquiry = Enquiry.find(params[:id])
    @enquiry.destroy

    respond_to do |format|
      format.html { redirect_to(enquiries_url) }
      format.xml  { head :ok }
    end
  end

end
