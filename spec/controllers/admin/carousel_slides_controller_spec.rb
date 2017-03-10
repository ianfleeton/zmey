require 'rails_helper'

RSpec.describe Admin::CarouselSlidesController, type: :controller do
  def mock_carousel_slide(stubs={})
    @mock_carousel_slide ||= double(CarouselSlide, stubs)
  end

  context 'when logged in as admin' do
    before { logged_in_as_admin }

    describe 'POST create' do
      let(:valid_params) {{ 'carousel_slide' => { 'caption' => 'A Caption' } }}

      describe 'when save succeeds' do
        before do
          allow(CarouselSlide).to receive(:new).and_return(mock_carousel_slide(save: true))
        end

        it 'redirects to the carousel slides list' do
          post :create, params: valid_params
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end
    end

    describe 'PUT update' do
      let(:valid_params) {{ 'id' => '37', 'carousel_slide' => { 'caption' => 'A Caption' } }}

      it 'updates the requested carousel slide' do
        find_requested_carousel_slide
        expect(mock_carousel_slide).to receive(:update_attributes)
        put :update, params: valid_params
      end

      describe 'when update succeeds' do
        before do
          allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(update_attributes: true))
        end

        it 'redirects to the carousel slides list' do
          put :update, params: valid_params
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested carousel slide' do
        find_requested_carousel_slide
        expect(mock_carousel_slide).to receive(:destroy)
        delete :destroy, params: { id: '37' }
      end

      it 'redirects to the carousel slides list' do
        allow(CarouselSlide).to receive(:find_by).and_return(mock_carousel_slide(destroy: true))
        delete :destroy, params: { id: '1' }
        expect(response).to redirect_to(admin_carousel_slides_path)
      end
    end

    context 'moving' do
      let!(:first) { FactoryGirl.create(:carousel_slide) }
      let!(:last)  { FactoryGirl.create(:carousel_slide) }

      describe 'GET move_up' do
        it 'moves the carousel slide up the list' do
          get :move_up, params: { id: last.id }
          expect(last.reload.position).to eq 1
        end

        it 'sets flash notice' do
          get :move_up, params: { id: last.id }
          expect_moved_notice
        end

        it 'redirects to index' do
          get :move_up, params: { id: last.id }
          expect(response).to redirect_to(admin_carousel_slides_path)
        end
      end

      describe 'GET move_down' do
        it 'moves the carousel slide down the list' do
          get :move_down, params: { id: first.id }
          expect(first.reload.position).to eq 2
        end

        it 'sets flash notice' do
          get :move_down, params: { id: first.id }
          expect_moved_notice
        end

        it 'redirects to index' do
          get :move_down, params: { id: first.id }
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
      .with(id: '37')
      .and_return(mock_carousel_slide(stubs))
  end
end
