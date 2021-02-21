#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   TakeProfit();
   
   if (sumProfit >= Target || sumProfit < StopLoss) {
      Clear();
   }
   
   Show();
}

input double Target = 15;
input double StopLoss = -10;

double sumProfit = 0;  
int cmd = 0;

void Clear() {
   trade.PositionClose(Symbol(), 10);
   cmd++;
}

void TakeProfit() {
   sumProfit = 0;
   if (PositionSelect(_Symbol) == true) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong positionTicket = PositionGetTicket(i);
         string positionSymbol = PositionGetString(POSITION_SYMBOL);
         double profitSymbol = PositionGetDouble(POSITION_PROFIT);
         
         if (positionSymbol == _Symbol) {
            sumProfit = sumProfit + profitSymbol;
         }
      }
   }
}

void Show() {
   Comment(
      "\n",
      "Sum Profit: ", (string)sumProfit, "\n",
      "Sum Command: ", (string)cmd, "\n"
   );
   Sleep(500); // Stop 0.5s
}