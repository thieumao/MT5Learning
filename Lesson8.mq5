#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

input int StartTime = 14;
input int EndTime = 23;

input double TP = 500;
input double SL = 300;

input double BuyVolume = 0.01;
input double SellVolume = 0.02;

int orderCount = 0;
string TimeServer = "";

double Ask = 0;
double Bid = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   CheckCMD();
   CheckTime();
   Show();
}

void CheckCMD() {
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

void CheckTime() {
   MqlDateTime t;
   datetime actionTime = TimeCurrent(t);
   TimeServer = " / " + (string)t.hour + " : " + (string)t.min + " : " + (string)t.sec;
   
   if (t.hour >= StartTime && t.hour <= EndTime && orderCount == 0) {
      CheckBuySell();
   }
   
   if (t.hour >= StartTime && t.hour <= EndTime && orderCount > 0) {
      Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   }
   
   if (t.hour < StartTime || t.hour > EndTime) {
      Ask = 0;
      Bid = 0;
   }
}

void CheckBuySell() {
   MqlRates PriceInfo[];
   ArraySetAsSeries(PriceInfo, true);
   double Data = CopyRates(Symbol(), Period(), 0, Bars(Symbol(), Period()), PriceInfo);
   
   Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   
   double BuySL = NormalizeDouble(Ask - SL * _Point, 5);
   double BuyTP = NormalizeDouble(Ask + TP * _Point, 5);
   
   double SellSL = NormalizeDouble(Bid + SL * _Point, 5);
   double SellTP = NormalizeDouble(Bid - TP * _Point, 5);
   
   // check buy
   if (Ask > PriceInfo[1].high && Ask > PriceInfo[2].high && Ask > PriceInfo[3].high) {
      trade.Buy(BuyVolume, NULL, Ask, BuySL, BuyTP, NULL);
   }
   
   // check sell
   if (Bid < PriceInfo[1].low && Bid < PriceInfo[2].low && Bid < PriceInfo[3].low) {
      trade.Sell(SellVolume, NULL, Bid, SellSL, SellTP, NULL);
   }
}

void Show() {
   Comment(
      "\n",
      "Time Server ", (string)TimeServer, "\n",
      "Trading Time (hours) ", (string)StartTime, " --- ", (string)EndTime, "\n",
      "Ask: ", (string)Ask, "\n",
      "Bid: ", (string)Bid, "\n"
   );
}