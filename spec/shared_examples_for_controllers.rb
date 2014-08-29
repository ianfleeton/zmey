shared_examples 'a website owned objects finder' do |object_type|
  it 'gets objects for the current site' do
    our_site = FactoryGirl.create(:website)
    allow(controller).to receive(:website).and_return(our_site)
    other_site = FactoryGirl.create(:website)
    our_object = FactoryGirl.create(object_type, website: our_site)
    other_object = FactoryGirl.create(object_type, website: other_site)
    get :index
    collection = object_type.to_s.pluralize.to_sym
    expect(assigns(collection)).to include(our_object)
    expect(assigns(collection)).not_to include(other_object)
  end
end

shared_examples 'a website association creator' do |object_type|
  it 'associates the newly created object with the website' do
    website = FactoryGirl.create(:website)
    allow(controller).to receive(:website).and_return(website)
    object = FactoryGirl.create(object_type)
    post :create, object_type => object.attributes
    expect(assigns(object_type).website).to eq website
  end
end
