#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

input double TP = 3000;
input double SL = 250;
input double Volume = 0.01;
input double MaxProfit = 50;

int cmd = 0;
int Reset = 0;

int OldSumProfitCount = 0;
double OldSumProfit = 0;
double SumProfit = 0;
string Label = "Start";
string iCMD = "";

double MA13 = 0;
double MA50 = 0;

double Bid = 0;
double Ask = 0;

int Start = 0;
double TotalProfit = 0;
double BalanceOut = 0;
double BalanceIn = 0;

int iSell = 0;
int iBuy = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   if (Start == 0) {
      BalanceIn = AccountInfoDouble(ACCOUNT_BALANCE);
      Start = 1;
   }
   
   CheckCMD();
   
   if (cmd == 0 && Reset == 2) {
      Label = "Start";
      iCMD = "";
      BalanceOut = AccountInfoDouble(ACCOUNT_BALANCE);
      TotalProfit = NormalizeDouble(BalanceOut - BalanceIn, 2);
      
      Reset = 0;
   }
   
   CheckMA1350();
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
         ENUM_POINTER_TYPE P_TYPE = PositionGetInteger(POSITION_TYPE);
                 
         if (positionSymbol == _Symbol) {
            cmd++;
            SumProfit = SumProfit + profitSymbol;
            if (SumProfit != 0 && SumProfit != OldSumProfit) {
               OldSumProfitCount++;
               if (OldSumProfitCount >= 700) {
                  Delete();
               }
            }
            if (SumProfit != 0 && SumProfit != OldSumProfit) {
               OldSumProfit = SumProfit;
               OldSumProfitCount = 0;
            }
            
            if (P_TYPE == POSITION_TYPE_BUY) {
               iCMD = "Buy / ";
            } else if (P_TYPE == POSITION_TYPE_SELL) {
               iCMD = "SELL / ";
            }
         }
      }
   }
}

void CheckMA1350() {
   MA13 = 0;
   MA50 = 0;
   
   double MAArray13[], MAArray50[];
   ArraySetAsSeries(MAArray13, true);
   ArraySetAsSeries(MAArray50, true);
   
   int iMA13 = iMA(_Symbol, _Period, 13, 0, MODE_EMA, PRICE_CLOSE);
   int iMA50 = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   CopyBuffer(iMA13, 0, 0, 3, MAArray13);
   CopyBuffer(iMA50, 0, 0, 3, MAArray50);
   
   MA13 = NormalizeDouble(MAArray13[0], 5);
   MA50 = NormalizeDouble(MAArray50[0], 5);
   if (Label == "Start" && Reset == 0 && cmd <= 1) {
      if (MA13 > MA50) {
         Label = "Waiting Sell";
         Reset = 1;
      } else if (MA13 < MA50) {
         Label = "Waiting Buy";
         Reset = 1;
      }
   }
}

void CheckBuySell() {
   if (cmd <= 1) {
      Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      Bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
      
      if (MA13 < MA50 && Label == "Waiting Sell" && Ask < MA13) {
         double SellSL = NormalizeDouble(Bid + SL * _Point, 5);
         double SellTP = NormalizeDouble(Bid - TP * _Point, 5);
         
         Delete();
         trade.Sell(Volume, NULL, Bid, SellSL, SellTP, NULL);
         
         Label = "Sell Action";
      }
      
      if (MA13 > MA50 && Label == "Waiting Buy" && Bid > MA13) {
         double BuySL = NormalizeDouble(Ask - SL * _Point, 5);
         double BuyTP = NormalizeDouble(Ask + TP * _Point, 5);
         
         Delete();
         trade.Buy(Volume, NULL, Ask, BuySL, BuyTP, NULL);
         
         Label = "Buy Action";
      }
   }
   
   if (cmd > 0) {
      Reset = 2;
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
      "\n",
      "[TotalProfit] ", (string)TotalProfit, " $\n",
      "Info: ", Label, "\n",
      "MA13:", (string)MA13, "\n",
      "MA50: ", (string)MA50, " $\n",
      "-----------------\n",
      "Symbol Profit: ", (string)SumProfit, " $\n"
   );
   // Sleep(500);
}