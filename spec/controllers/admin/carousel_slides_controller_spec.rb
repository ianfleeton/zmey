require 'rails_helper'
require 'shared_examples_for_controllers'

describe Admin::CarouselSlidesController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  def mock_carousel_slide(stubs={})
    @mock_carousel_slide ||= double(CarouselSlide, stubs)
  end

  context 'when logged in as admin' do
    before { logged_in_as_admin }

    describe 'GET index' do
      it_behaves_like 'a website owned objects finder', :carousel_slide
    end

    describe 'GET new' do
      it 'assigns a new carousel slide to @carousel_slide' do
        expect(CarouselSlide).to receive(:new).and_return(mock_carousel_slide)
        get :new
        expect(assigns(:carousel_slide)).to eq mock_carousel_slide
      end

      it "sets the slide's active until date into the far future" do
        get :new
        expect(assigns(:carousel_slide).active_until).to be > DateTime.now + 4.years
      end
    end

    describe 'GET edit' do
      it 'assigns the requested carousel slide to @carousel_slide' do
        find_requested_carousel_slide
        get :edit, id: '37'
        expect(assigns(:carousel_slide)).to eq mock_carousel_slide
      end
    end

    describe 'POST create' do
      let(:valid_params) {{ 'carousel_slide' => { 'caption' => 'A Caption' } }}

      it 'assigns a newly created but unsaved carousel slide as @carousel_slide' do
        expect(CarouselSlide).to receive(:new).and_return(mock_carousel_slide(:website= => website, save: false))
        post :create, carousel_slide: {these: 'params'}
        expect(assigns(:carousel_slide)).to equal(mock_carousel_slide)
      end

      describe 'when save succeeds' do
        before do
          allow(CarouselSlide).to receive(:new).and_return(mock_carousel_slide(:website= => website, save: true))
        end

        it 'redirects to the carousel slides list' do
          post :create, valid_params
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end

      describe 'when save fails' do
        before do
          allow(CarouselSlide).to receive(:new).and_return(mock_carousel_slide(:website= => website, save: false))
        end

        it "re-renders the 'new' template" do
          post :create, valid_params
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      let(:valid_params) {{ 'id' => '37', 'carousel_slide' => { 'caption' => 'A Caption' } }}

      it 'updates the requested carousel slide' do
        find_requested_carousel_slide
        expect(mock_carousel_slide).to receive(:update_attributes).with(valid_params['carousel_slide'])
        put :update, valid_params
      end

      describe 'when update succeeds' do
        before do
          allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(update_attributes: true))
        end

        it 'assigns the requested carousel_slide as @carousel_slide' do
          put :update, valid_params
          expect(assigns(:carousel_slide)).to eq mock_carousel_slide
        end

        it 'redirects to the carousel slides list' do
          put :update, valid_params
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end

      describe 'when update fails' do
        it 'assigns the carousel slide as @carousel_slide' do
          allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(update_attributes: false))
          put :update, valid_params
          expect(assigns(:carousel_slide)).to eq mock_carousel_slide
        end

        it "re-renders the 'edit' template" do
          allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(update_attributes: false))
          put :update, valid_params
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested carousel slide' do
        find_requested_carousel_slide
        expect(mock_carousel_slide).to receive(:destroy)
        delete :destroy, id: '37'
      end

      it 'redirects to the carousel slides list' do
        allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(destroy: true))
        delete :destroy, id: '1'
        expect(response).to redirect_to(admin_carousel_slides_path)
      end
    end

    context 'moving' do
      let!(:first) { FactoryGirl.create(:carousel_slide, website: website) }
      let!(:last)  { FactoryGirl.create(:carousel_slide, website: website) }

      describe 'GET move_up' do
        it 'moves the carousel slide up the list' do
          get :move_up, id: last.id
          expect(last.reload.position).to eq 1
        end

        it 'sets flash notice' do
          get :move_up, id: last.id
          expect_moved_notice
        end

        it 'redirects to index' do
          get :move_up, id: last.id
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end

      describe 'GET move_down' do
        it 'moves the carousel slide down the list' do
          get :move_down, id: first.id
          expect(first.reload.position).to eq 2
        end

        it 'sets flash notice' do
          get :move_down, id: first.id
          expect_moved_notice
        end

        it 'redirects to index' do
          get :move_down, id: first.id
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end

      def expect_moved_notice
        expect(flash.notice).to eq 'Moved'
      end
    end
  end

  def find_requested_carousel_slide(stubs={})
    expect(CarouselSlide).to receive(:find_by)
      .with(id: '37', website_id: website.id)
      .and_return(mock_carousel_slide(stubs))
  end
end
