require 'spec_helper'

describe CarouselSlidesController do
  let(:website) { mock_model(Website).as_null_object }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  def mock_carousel_slide(stubs={})
    @mock_carousel_slide ||= mock_model(CarouselSlide, stubs)
  end

  context 'when logged in as admin' do
    before { logged_in_as_admin }

    describe 'GET index' do
      it 'assigns this website\'s carousel slides to @carousel slides' do
        website.stub(:carousel_slides).and_return([mock_carousel_slide])
        get 'index'
        expect(assigns(:carousel_slides)).to eq [mock_carousel_slide]
      end
    end

    describe 'GET new' do
      it 'assigns a new carousel slide to @carousel_slide' do
        CarouselSlide.stub(:new).and_return(mock_carousel_slide)
        get 'new'
        expect(assigns(:carousel_slide)).to eq mock_carousel_slide
      end
    end

    describe 'GET edit' do
      it 'assigns the requested carousel slide to @carousel_slide' do
        find_requested_carousel_slide
        get 'edit', id: '37'
        expect(assigns(:carousel_slide)).to eq mock_carousel_slide
      end
    end

    describe 'POST create' do
      let(:valid_params) {{ 'carousel_slide' => { 'caption' => 'A Caption' } }}

      it 'assigns a newly created but unsaved carousel slide as @carousel_slide' do
        CarouselSlide.stub(:new).and_return(mock_carousel_slide(:website_id= => website.id, save: false))
        post 'create', carousel_slide: {these: 'params'}
        expect(assigns(:carousel_slide)).to equal(mock_carousel_slide)
      end

      describe 'when save succeeds' do
        before do
          CarouselSlide.stub(:new).and_return(mock_carousel_slide(:website_id= => website.id, save: true))
        end

        it 'redirects to the carousel slides list' do
          post 'create', valid_params
          expect(response).to redirect_to(carousel_slides_path)
        end
      end

      describe 'when save fails' do
        before do
          CarouselSlide.stub(:new).and_return(mock_carousel_slide(:website_id= => website.id, save: false))
        end

        it "re-renders the 'new' template" do
          post 'create', valid_params
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      let(:valid_params) {{ 'id' => '37', 'carousel_slide' => { 'caption' => 'A Caption' } }}

      it 'updates the requested carousel slide' do
        find_requested_carousel_slide
        mock_carousel_slide.should_receive(:update_attributes).with(valid_params['carousel_slide'])
        put 'update', valid_params
      end

      describe 'when update succeeds' do
        before do
          CarouselSlide.stub(:find_by_id_and_website_id).and_return(mock_carousel_slide(update_attributes: true))
        end

        it 'assigns the requested carousel_slide as @carousel_slide' do
          put 'update', valid_params
          expect(assigns(:carousel_slide)).to eq mock_carousel_slide
        end

        it 'redirects to the carousel slides list' do
          put 'update', valid_params
          expect(response).to redirect_to(carousel_slides_path)
        end
      end

      describe 'when update fails' do
        it 'assigns the carousel slide as @carousel_slide' do
          CarouselSlide.stub(:find_by_id_and_website_id).and_return(mock_carousel_slide(update_attributes: false))
          put 'update', valid_params
          expect(assigns(:carousel_slide)).to eq mock_carousel_slide
        end

        it "re-renders the 'edit' template" do
          CarouselSlide.stub(:find_by_id_and_website_id).and_return(mock_carousel_slide(update_attributes: false))
          put 'update', valid_params
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested carousel slide' do
        find_requested_carousel_slide
        mock_carousel_slide.should_receive(:destroy)
        delete 'destroy', id: '37'
      end

      it 'redirects to the carousel slides list' do
        CarouselSlide.stub(:find_by_id_and_website_id).and_return(mock_carousel_slide(destroy: true))
        delete 'destroy', id: '1'
        expect(response).to redirect_to(carousel_slides_path)
      end
    end
  end

  def find_requested_carousel_slide(stubs={})
    CarouselSlide.should_receive(:find_by_id_and_website_id)
      .with('37', website.id)
      .and_return(mock_carousel_slide(stubs))
  end
end
