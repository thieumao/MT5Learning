#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;
/*
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
*/
input double TP = 500;
input double SL = 500;
// So point cua TP dat 80%
// neu quay dau bot se dong lenh khi taget = 5%
input double TargetPercent = 80;

input double BuyVolume = 0.01;
input double SellVolume = 0.02;

// % so point cao nhat TP dat duoc
double LoadMax = 0;
// % so point cao nhat SL dat duoc
double LoadMin = 0;
// % so point hien tai
double LoadCurrent = 0;

double SumProfit = 0;

int cmd = 0;
int iB = 0;
int iS = 0;
// tong so lenh da dong
int TotalBreak = 0;

// Gia khi vao lenh
double PriceOpen = 0;
double Ask = 0;
double Bid = 0;
// lenh da dong
double Break = 0;
double Spread = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   Spread = NormalizeDouble((Ask - Bid) / _Point, 0);
   
   CheckCMD();
   CheckTarget();
   CheckBuySell();
   Show();
}

void CheckCMD() {
   cmd = 0;
   SumProfit = 0;
   
   if (PositionSelect(_Symbol) == true) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong positionTicket = PositionGetTicket(i);
         string positionSymbol = PositionGetString(POSITION_SYMBOL);
         double profitSymbol = PositionGetDouble(POSITION_PROFIT);
         
         if (positionSymbol == _Symbol) {
            cmd++;
            SumProfit = SumProfit + profitSymbol;
         }
      }
   }
   if (cmd == 0) {
      LoadMax = 0;
      LoadMin = 0;
      LoadCurrent = 0;
      
      iB = 0;
      iS = 0;
      
      PriceOpen = 0;
      Break = 0;
   }
}

void CheckTarget() {
   if (iB = 1) {
      double pointCurrent = (Ask - PriceOpen) / _Point;
      LoadCurrent = NormalizeDouble((pointCurrent * 100 / TP), 2);      
   
      if (LoadCurrent > LoadMax) {
         LoadMax = LoadCurrent;
      }
      
      if (LoadCurrent < LoadMin) {
         LoadMin = LoadCurrent;
      }
   }
   
   if (iS = 1) {
      double pointCurrent = (PriceOpen - Bid) / _Point;
      LoadCurrent = NormalizeDouble((pointCurrent * 100 / TP), 2);      
   
      if (LoadCurrent > LoadMax) {
         LoadMax = LoadCurrent;
      }
      
      if (LoadCurrent < LoadMin) {
         LoadMin = LoadCurrent;
      }
   }
   
   if (LoadCurrent >= TargetPercent && Break != 1) {
      Break = 1;
   }
   
   if (LoadCurrent <= 5 && Break == 1) {
      Break = 0;
      Clean();
      TotalBreak++;
      
      Print(
         "[LoadMin %]" + (string)LoadMin +
         "[LoadCurrent %]" + (string)LoadCurrent +
         "[LoadMax %]" + (string)LoadMax
      );
      //Sleep(200);
   }
}

void Clean() {
   trade.PositionClose(Symbol(), 10);
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
   if (Ask > PriceInfo[1].high && Ask > PriceInfo[2].high && Ask > PriceInfo[3].high
      && Ask > PriceInfo[4].high && Ask > PriceInfo[5].high) {
      trade.Buy(BuyVolume, NULL, Ask, BuySL, BuyTP, NULL);
      iB = 1;
      iS = 0;
      PriceOpen = Ask;
   }
   
   // check sell
   if (Bid < PriceInfo[1].low && Bid < PriceInfo[2].low && Bid < PriceInfo[3].low
      && Bid < PriceInfo[4].low && Bid < PriceInfo[5].low) {
      trade.Sell(SellVolume, NULL, Bid, SellSL, SellTP, NULL);
      iB = 0;
      iS = 1;
      PriceOpen = Bid;
   }
}

void Show() {
   string iC = "";
   
   if (iB == 1) {
      iC = "I'm Buy\n";
   } else if (iS == 1) {
      iC = "I'm Sell\n";
   } else {
      iC = "I'm Waiting...\n";
   }
   
   Comment(
      "\n",
      iC,
      "[Speed] ", (string)Spread, "(Point)\n",
      "------------------------\n",
      "[LoadMin] ", (string)NormalizeDouble(LoadMin, 2), "(Point)\n",
      "[LoadCurrent] ", (string)NormalizeDouble(LoadCurrent, 2), " %\n",
      "[LoadMax] ", (string)NormalizeDouble(LoadMax, 2), " %\n",
      "[TotalBreak] ", (string)TotalBreak, " %\n"
   );
   
   //Sleep(500);
}