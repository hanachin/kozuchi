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
        new_simple_deal(date.month, date.day, new_card, accounts(:taro_food), 1500, date.year).save!

        visit url
        select "新しいクレカ(クレジットカード)", from: "settlement_account_id"
      end

      it "選択したクレジットカードの記入が表示される" do
        page.find("table.settlement tr.entry td.creditor").should have_content("1,500")
      end
    end

    #describe "期間を変えて表示内容を更新" do
    #end

  end
end
