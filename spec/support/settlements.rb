# -*- encoding : utf-8 -*-
# target_account, partner_account を指定して利用する
shared_context "先月に精算対象記入が２件あるとき" do
  let!(:first_deal) {
    FactoryGirl.create(:general_deal,
                       date: (Date.today << 1),
                       debtor_entries_attributes: [account_id: partner_account.id, amount: 1200],
                       creditor_entries_attributes: [account_id: target_account.id, amount: -1200])
  }
  let!(:second_deal) {
    FactoryGirl.create(:general_deal,
                       date: (Date.today << 1),
                       debtor_entries_attributes: [account_id: partner_account.id, amount: 4700],
                       creditor_entries_attributes: [account_id: target_account.id, amount: -4700])
  }
end
