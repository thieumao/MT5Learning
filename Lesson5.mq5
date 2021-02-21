#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

/*
input double PBUY = 1.25921;
input double PSELL = 1.22111;
input double SL = 500;
input double TP = 500;
input double VOL = 0.05;

int orderCount = 0;
double ask = 0;
double bid = 0;
*/  

/*
double sumProfit = 0;  
string note = ""; 
*/

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   AutoSLTP();
   Show();
}

int cmd = 0;

void AutoSLTP() {
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double askUp = NormalizeDouble(ask + 500 * _Point, 5);
   double askDown = NormalizeDouble(ask - 500 * _Point, 5);
   
   if (PositionSelect(_Symbol) == true) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong positionTicket = PositionGetTicket(i);
         string positionSymbol = PositionGetString(POSITION_SYMBOL);
         double P_SL = PositionGetDouble(POSITION_SL);
         ENUM_POINTER_TYPE P_TYPE = PositionGetInteger(POSITION_TYPE);
                 
         if (positionSymbol == _Symbol && P_SL == 0 && P_TYPE == POSITION_TYPE_BUY) {
            trade.PositionModify(positionTicket, askDown, askUp);
            cmd++;
         }
         
         if (positionSymbol == _Symbol && P_SL == 0 && P_TYPE == POSITION_TYPE_SELL) {
            trade.PositionModify(positionTicket, askUp, askDown);
            cmd++;
         }
      }
   }
}

void Show() {
   Comment(
      "\n",
      "Number of orders were set SL & TP: ", (string)cmd, "\n"
   );
   Sleep(1000);
}

/*
void Clear() {
   trade.PositionClose(Symbol(), 10);
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
      "State: ", note
   );
   Sleep(5000); // Stop 5s
   note = "......";
}
*/

/*
void Show() {
   Comment(
      "\n",
      "Sum Profit: ", (string)sumProfit, "\n"
   );
}
*/

/*
void CheckCmd() {
   orderCount = 0;
   if (PositionSelect(_Symbol) == true) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong positionTicket = PositionGetTicket(i);
         string positionSymbol = PositionGetString(POSITION_SYMBOL);
         
         if (positionSymbol == _Symbol) {
            orderCount++;
         }
      }
   }
}

void CheckBuySell() {
   ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   
   if (orderCount == 0 && ask >= PBUY) {
      double buySL = ask - TP * _Point;
      double buyTP = ask + TP * _Point;
      
      trade.Buy(VOL, NULL, ask, buySL, buyTP, NULL);
   }
   
   if (orderCount == 0 && bid <= PSELL) {
      double sellSL = bid + TP * _Point;
      double sellTP = bid - TP * _Point;
      
      trade.Sell(VOL, NULL, bid, sellSL, sellTP, NULL);
   }
}

void Show() {
   Comment(
      "\n",
      "Waitting Buy Price: ", string(PBUY), "\n",
      "Watting Sell Price: ", string(PSELL), "\n",
      "VOLUME: ", string(VOL), "\n",
      "TP Point: ", string(TP), "\n",
      "SL Point: ", string(SL), "\n",
      "Order Count: ", string(orderCount), "\n",
      "ASK Price: ", string(ask), "\n",
      "BID Price: ", string(bid), "\n"
   );
}
*/