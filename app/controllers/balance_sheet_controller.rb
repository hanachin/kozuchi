class BalanceSheetController < ApplicationController
  layout 'main'
  menu_group "家計簿"
  menu "貸借対照表"

  include WithCalendar

  def show
    year, month = read_target_date
    redirect_to monthly_balance_sheet_path(:year => year, :month => month)
  end

  def monthly
    @year = params[:year]
    @month = params[:month]

    date = Date.new(@year.to_i, @month.to_i, 1) >> 1
    asset_accounts = current_user.accounts.balances(date, "accounts.type != 'Income' and accounts.type != 'Expense'") # TODO: マシにする
    @assets = AccountsBalanceReport.new(asset_accounts, date)
  end
  
end
