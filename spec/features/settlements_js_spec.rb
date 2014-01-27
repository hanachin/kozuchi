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

    describe "すべて解除ボタンを押す" do
      include_context "先月に精算対象記入が２件あるとき" do
        let(:target_account) { current_user.assets.credit.first }
        let(:partner_account) { accounts(:taro_food) }
      end
      before do
        visit url
        click_link("すべて解除")
      end
      it "２件が表示されており、チェックが外れており、合計が0" do
        page.find("#creditor_sum").should have_content("0")
        page.find("#debtor_sum").should have_content("0")
        page.find("#target_description").should have_content("から")
        entries = page.all("tr.entry")
        entries.size.should == 2
        entries.first.find("input[type='checkbox']")[:checked].should be_false
        entries.first[:class].split(/\s/).should include("disabled")
        entries.last.find("input[type='checkbox']")[:checked].should be_false
        entries.last[:class].split(/\s/).should include("disabled")
      end
    end

    describe "すべて選択ボタンを押す" do
      include_context "先月に精算対象記入が２件あるとき" do
        let(:target_account) { current_user.assets.credit.first }
        let(:partner_account) { accounts(:taro_food) }
      end
      before do
        visit url
        click_link("すべて解除") # 一度解除してから
        click_link("すべて選択")
      end
      it "２件が表示されており、チェックされており、合計が5,900" do
        page.find("#creditor_sum").should have_content("5,900")
        page.find("#debtor_sum").should have_content("0")
        page.find("#target_description").should have_content("に")
        entries = page.all("tr.entry")
        entries.size.should == 2
        entries.first.find("input[type='checkbox']")[:checked].should be_true
        entries.first[:class].split(/\s/).should_not include("disabled")
        entries.last.find("input[type='checkbox']")[:checked].should be_true
        entries.last[:class].split(/\s/).should_not include("disabled")
      end
    end

    describe "1件チェックボックスをはずす" do
      include_context "先月に精算対象記入が２件あるとき" do
        let(:target_account) { current_user.assets.credit.first }
        let(:partner_account) { accounts(:taro_food) }
      end
      before do
        visit url
        first_entry = page.first("tr.entry")
        first_entry.find("input[type='checkbox']").click() # 外す
      end
      it "合計が4,700円" do
        page.find("#creditor_sum").should have_content("4,700")
        page.find("#debtor_sum").should have_content("0")
        page.find("#target_description").should have_content("に")
        entries = page.all("tr.entry")
        entries.size.should == 2
        entries.first.find("input[type='checkbox']")[:checked].should be_false
        entries.first[:class].split(/\s/).should include("disabled")
        entries.last.find("input[type='checkbox']")[:checked].should be_true
        entries.last[:class].split(/\s/).should_not include("disabled")
      end
    end
  end
end
