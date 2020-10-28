# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Closure dates admin", type: :request do
  before do
    administrator = FactoryBot.create(:administrator)
    sign_in administrator
  end

  describe "GET /admin/closure_dates" do
    it "lists all closure dates in ascending closed_on date order" do
      FactoryBot.create(
        :closure_date, closed_on: Date.new(2017, 8, 28), delivery_possible: true
      )
      FactoryBot.create(
        :closure_date, closed_on: Date.new(2017, 8, 27), delivery_possible: false
      )
      get "/admin/closure_dates"
      assert_select "tr td", text: "27-08-17"
      assert_select "tr td + td", text: "✘"
      assert_select "tr + tr td", text: "28-08-17"
      assert_select "tr + tr td + td", text: "✔"
    end
  end

  describe "GET /admin/closure_dates/new" do
    it "renders a form for a new closure date" do
      get "/admin/closure_dates/new"
      assert_select "form[action='#{admin_closure_dates_path}']" do
        assert_select "input[name='closure_date[closed_on]']"
        assert_select(
          "input[name='closure_date[delivery_possible]'][type='checkbox']"
        )
      end
    end
  end

  describe "POST /admin/closure_dates" do
    before { post "/admin/closure_dates", params: {closure_date: params} }

    context "with valid params" do
      let(:params) do
        {
          closed_on: "2017-08-28",
          delivery_possible: true
        }
      end

      it "creates a new closure date" do
        expect(ClosureDate.exists?(params)).to be_truthy
      end

      it "redirects to closure dates index" do
        expect(response).to redirect_to admin_closure_dates_path
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq "Saved."
      end
    end

    context "with invalid params" do
      let(:params) { {closed_on: nil} }

      it "re-renders the new closure date form" do
        assert_select "form[action='#{admin_closure_dates_path}']"
        assert_select "input[name='closure_date[closed_on]']"
      end
    end
  end

  describe "GET /admin/closure_dates/:id/edit" do
    it "renders a form to edit the closure dates" do
      cd = FactoryBot.create(:closure_date)
      get "/admin/closure_dates/#{cd.id}/edit"
      assert_select "form[action='#{admin_closure_date_path(cd)}']"
    end
  end

  describe "PATCH /admin/closure_dates/:id" do
    let(:cd) { FactoryBot.create(:closure_date) }
    before do
      patch "/admin/closure_dates/#{cd.id}", params: {closure_date: params}
    end

    context "with valid params" do
      let(:closure_date) do
        FactoryBot.create(:closure_date, closed_on: "2017-08-28")
      end
      let(:params) { {closed_on: "2017-08-29"} }

      it "updates the closure date" do
        updated = ClosureDate.last
        expect(updated.closed_on).to eq Date.new(2017, 8, 29)
      end

      it "redirects to closure dates index" do
        expect(response).to redirect_to admin_closure_dates_path
      end

      it "sets a flash notice" do
        expect(flash[:notice]).to eq "Saved."
      end
    end

    context "with invalid params" do
      let(:params) { {closed_on: nil} }

      it "re-renders the edit closure date form" do
        assert_select "form[action='#{admin_closure_date_path(cd)}']"
        assert_select "input[name='closure_date[closed_on]']"
      end
    end
  end

  describe "DELETE /admin/closure_dates/:id" do
    let(:cd) { FactoryBot.create(:closure_date) }
    before { delete "/admin/closure_dates/#{cd.id}" }

    it "destroys the closure date" do
      expect(ClosureDate.find_by(id: cd.id)).to be_nil
    end

    it "redirects to closure dates index" do
      expect(response).to redirect_to admin_closure_dates_path
    end

    it "sets a flash notice" do
      expect(flash[:notice]).to eq "Deleted."
    end
  end
end
