class EnquiriesController < ApplicationController

  # spam protection based on Jack Born's Safer Contact Forms Without CAPTCHA's
  # http://15daysofjquery.com/examples/contact-forms/
  
  before_filter :admin_required, :except => [:new, :create, :thank_you, :current_time]
  
  # GET /enquiries
  # GET /enquiries.xml
  def index
    @enquiries = Enquiry.all

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

    respond_to do |format|
      if @enquiry.save
        EnquiryNotifier.deliver_enquiry @w, @enquiry
        format.html { redirect_to(:action => 'thank_you') }
        format.xml  { render :xml => @enquiry, :status => :created, :location => @enquiry }
      else
        format.html { render :action => "new", :layout => 'application' }
        format.xml  { render :xml => @enquiry.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # returns the current time, according to the server, and sets
  # a cookie containing the time + session secret hashed
  def current_time
    current_time = Time.now.to_i.to_s
    session[:enquiry_token] = hash current_time
    render :update do |page|
      page.replace_html 'current_time', :partial => 'current_time', :object => current_time
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

  private

  def hash plain
    Digest::SHA1.hexdigest("--#{plain}--#{ActionController::Base.session_options[:secret]}--")
  end
  
  def good_token?
    completed_time = Time.now.to_i
    # check required parameter and cookie
    if params[:current_time].nil? or session[:enquiry_token].nil?
      flash.now[:notice] = 'We could not send your form. Check that you have an ' +
        'up-to-date browser with Javascript switched on and cookies enabled.'
      return false
    end

    start_time = params[:current_time]

    # check that the submitted timestamp, when hashed, is the same as the
    # cookie we set earlier
    if hash(start_time) != session[:enquiry_token]
      flash.now[:notice] = 'We could not send your form. Please try again.'
      return false
    end

    shortest_time_allowed = 3 
    longest_time_allowed = 10 * 60
    
    delta = completed_time - start_time.to_i
    
    if delta < shortest_time_allowed or delta > longest_time_allowed
      flash.now[:notice] = 'We could not send your form as it was submitted too quickly or too slowly.'
      return false
    end
    
    return true
  end
end
