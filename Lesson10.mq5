#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

input double TP = 500;
input double SL = 500;
input double MaxProfit = 50;

int cmd = 0;
int Start = 0;
string TextShow = "";

double TotalProfit = 0;
double SumProfit = 0;
double BalanceOut = 0;
double BalanceIn = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {   
   CheckCMD();
   CheckBalance();
   Show();
   
   if (SumProfit + TotalProfit >= MaxProfit && cmd > 0) {
      Delete();
   }
}

void CheckCMD() {
   cmd = 0;
   TextShow = "";
   SumProfit = 0;
   
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong positionTicket = PositionGetTicket(i);
      string positionSymbol = PositionGetString(POSITION_SYMBOL);
      double profitSymbol = PositionGetDouble(POSITION_PROFIT);
      ENUM_POSITION_TYPE P_TYPE = PositionGetInteger(POSITION_TYPE);
      double P_PO = PositionGetDouble(POSITION_PRICE_OPEN);
      double P_SL = PositionGetDouble(POSITION_SL);
      double P_TP = PositionGetDouble(POSITION_TP);
      
      if (P_SL == 0 || P_TP == 0) {
         if (P_TYPE == POSITION_TYPE_BUY) {
            double buySL = NormalizeDouble(P_PO - SL * _Point, 5);
            double buyTP = NormalizeDouble(P_PO + TP * _Point, 5);
            trade.PositionModify(positionTicket, buySL, buyTP);
         } else if (P_TYPE == POSITION_TYPE_SELL) {
            double sellSL = NormalizeDouble(P_PO + SL * _Point, 5);
            double sellTP = NormalizeDouble(P_PO - TP * _Point, 5);
            trade.PositionModify(positionTicket, sellSL, sellTP);
         }
      }
       
      cmd++;
      SumProfit = SumProfit + profitSymbol;
      
      string label = "";
      if (P_TYPE == POSITION_TYPE_BUY) {
         label = "BUY";
      } else if (P_TYPE == POSITION_TYPE_SELL) {
         label = "SELL";
      }
      
      TextShow = TextShow + (string) cmd + " / "
         + label + (string)positionSymbol + " : "
         + (string)profitSymbol + "\n";
   }
}

void CheckBalance() {
   if (Start == 0) {
      BalanceIn = AccountInfoDouble(ACCOUNT_BALANCE);
      Start = 1;
   }
   
   BalanceOut = AccountInfoDouble(ACCOUNT_BALANCE);
   
   if (BalanceIn != BalanceOut) {
      TotalProfit = NormalizeDouble(BalanceOut - BalanceIn, 2);
   }
}

void Delete() {
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      string positionSymbol = PositionGetString(POSITION_SYMBOL);
      trade.PositionClose(positionSymbol, 10);
   }
}

void Show() {
   Comment(
      "Info Trading ", (string)cmd, "(CMD)\n",
      "Total Profit ", (string)TotalProfit, " $\n",
      TextShow, "\n",
      "----------------------------\n",
      "[Sum Profit] ", (string)SumProfit, " $\n"
   );
   
   // Sleep(500);
}