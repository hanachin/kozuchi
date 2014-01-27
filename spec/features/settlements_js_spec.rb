# -*- encoding : utf-8 -*-
require 'spec_helper'

describe SettlementsController, :js => true do
  self.use_transactional_fixtures = false
  fixtures :users, :accounts, :account_links, :account_link_requests, :preferences
  set_fixture_class  :accounts => Account::Base

  include_context "太郎 logged in"

  describe "新しい精算" do
    let(:url) { '/settlements/new' }

    describe "口座を変更" do
      let!(:new_card) { FactoryGirl.create(:credit_card, user: current_user, name: "新しいクレカ") }
      before do
        # 新しいクレカの先月の記入が1件ある状態にする
        date = Date.today << 1
        FactoryGirl.create(:general_deal,
                           date: date,
                           debtor_entries_attributes: [account_id: accounts(:taro_food).id, amount: 1500],
                           creditor_entries_attributes: [account_id: new_card.id, amount: -1500])
        visit url
        select "新しいクレカ(クレジットカード)", from: "settlement_account_id"
      end

      it "選択したクレジットカードの記入が表示される" do
        page.find("table.settlement tr.entry td.creditor").should have_content("1,500")
      end
    end

    describe "期間を変えて表示内容を更新" do
      let(:date) { Date.today << 2 }
      let(:account) { current_user.assets.credit.first }
      # 先々月に１件作っておく
      let!(:old_deal) { FactoryGirl.create(:general_deal,
                                          date: date,
                                          debtor_entries_attributes: [account_id: accounts(:taro_food).id, amount: 880],
                                          creditor_entries_attributes: [account_id: account.id, amount: -880]) }
      # 画面を表示し、開始期間を先々月（の1日）にして更新
      before {
        visit url
        select date.year.to_s, from: :start_date_year
        select date.month.to_s, from: :start_date_month
        click_button "表示内容を更新"
      }
      it "先々月の記入が表示される" do
        page.find("table.settlement tr.entry td.creditor").should have_content("880")
      end
    end

  end
end
