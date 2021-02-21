#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Object.mqh>
CTrade trade;

input double TPPoint = 1000;
input double TSPoint = 500;

// Dem tong lenh duoc auto dat SL, TP
int dem = 0; 
// So lenh dang ton toi
int cmd = 0; 

double PriceUp_TS = 0;
double PriceDown_TS = 0;

// Ve duong line TS
int AP = 0;
int luot = 0;
int n = 0;

double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
double AskUp = NormalizeDouble(Ask + TPPoint * _Point, 5);
double AskDown = NormalizeDouble(Ask - TPPoint * _Point, 5);

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   AutoSL();
   TrailingStop();
   Show();
   luot++;
}

void AutoSL() {
   double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double AskUp = NormalizeDouble(Ask + TPPoint * _Point, 5);
   double AskDown = NormalizeDouble(Ask - TPPoint * _Point, 5);
   cmd = 0;
   
   if (PositionSelect(_Symbol) == true) {
      for (int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong positionTicket = PositionGetTicket(i);
         string positionSymbol = PositionGetString(POSITION_SYMBOL);
         double P_SL = PositionGetDouble(POSITION_SL);
         ENUM_POINTER_TYPE P_TYPE = PositionGetInteger(POSITION_TYPE);
                 
         if (positionSymbol == _Symbol && P_SL == 0 && P_TYPE == POSITION_TYPE_BUY) {
            trade.PositionModify(positionTicket, AskDown, AskUp);
            PriceUp_TS = NormalizeDouble(AskUp - TSPoint * _Point / 2, 5);
            PriceDown_TS = NormalizeDouble(AskDown + TSPoint * _Point / 2, 5);
         }
         
         if (positionSymbol == _Symbol && P_SL == 0 && P_TYPE == POSITION_TYPE_SELL) {
            trade.PositionModify(positionTicket, AskUp, AskDown);
            PriceUp_TS = NormalizeDouble(AskUp - TSPoint * _Point / 2, 5);
            PriceDown_TS = NormalizeDouble(AskDown + TSPoint * _Point / 2, 5);
         }
         
         if (positionSymbol == _Symbol) {
            cmd++;
         }
      }
   }
   
   if (cmd == 0 && PriceUp_TS != 0) {
      PriceUp_TS = 0;
      PriceDown_TS = 0;
   }
   
   if (PriceUp_TS != 0 && AP == 0) {
      ObjectCreate(0, "PriceUp_TS", OBJ_HLINE, 0, 0, PriceUp_TS);
      ObjectSetInteger(0, "PriceUp_TS", OBJPROP_COLOR, clrGreen);
      ObjectSetInteger(0, "PriceUp_TS", OBJPROP_WIDTH, 1);
      
      ObjectCreate(0, "PriceDown_TS", OBJ_HLINE, 0, 0, PriceDown_TS);
      ObjectSetInteger(0, "PriceDown_TS", OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, "PriceDown_TS", OBJPROP_WIDTH, 1);
      
      AP = 1;
   }
   
   if (PriceUp_TS == 0 && AP == 1) {
      ObjectDelete(0, "PriceUp_TS");
      ObjectDelete(0, "PriceDown_TS");
      AP = 0;
   }
}

void TrailingStop() {
   if (PositionSelect(_Symbol) == true) {
      double Ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      double PriceUp = NormalizeDouble(Ask + TSPoint * _Point, 5);
      double PriceDown = NormalizeDouble(Ask - TSPoint * _Point, 5);
      
      if (Ask >= PriceUp_TS || Ask <= PriceDown_TS) {
         for (int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong positionTicket = PositionGetTicket(i);
            string positionSymbol = PositionGetString(POSITION_SYMBOL);
            double P_SL = PositionGetDouble(POSITION_SL);
            double P_TP = PositionGetDouble(POSITION_TP);
            
            ENUM_POINTER_TYPE P_TYPE = PositionGetInteger(POSITION_TYPE);
            
            if (positionSymbol == _Symbol && P_TYPE == POSITION_TYPE_BUY && Ask >= PriceUp_TS) {
               trade.PositionModify(positionTicket, PriceDown, PriceUp);
               PriceUp_TS = NormalizeDouble(PriceUp - TSPoint * _Point / 2, 5);
               PriceDown_TS = NormalizeDouble(PriceDown + TSPoint * _Point / 2, 5);
               
               if (AP == 1) {
                  ObjectDelete(0, "PriceUp_TS");
                  ObjectDelete(0, "PriceDown_TS");
                  AP = 0;
               }
               
               dem++;
            }
         
            if (positionSymbol == _Symbol && P_TYPE == POSITION_TYPE_SELL && Ask <= PriceDown_TS) {
               trade.PositionModify(positionTicket, PriceUp, PriceDown);
               PriceUp_TS = NormalizeDouble(PriceUp - TSPoint * _Point / 2, 5);
               PriceDown_TS = NormalizeDouble(PriceDown + TSPoint * _Point / 2, 5);
               
               if (AP == 1) {
                  ObjectDelete(0, "PriceUp_TS");
                  ObjectDelete(0, "PriceDown_TS");
                  AP = 0;
               }
               
               dem++;
            }
         }
      }
   }
}

void Show() {
   Comment(
      "\n",
      "Trailing Stop", "\n",
      "So luot kiem tra ", (string)luot, "\n",
      "So lenh Trailing Stop ", (string)dem, "\n",
      "So lenh dang ton tai ", (string)cmd
   );
}