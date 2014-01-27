# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :credit_card, class: Account::Asset do
    # TODO: デフォルトユーザー
    name 'クレジットカード' # TODO: シーケンスに
    asset_kind 'credit_card'
  end
end
