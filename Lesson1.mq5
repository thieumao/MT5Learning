#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

int i = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick() {
   Comment(
      "\n"
      + "Lesson 1: Display data ", "\n"
      + "Test: ", (string)i, "\n"
      + "------------------------"
   );
   i++;
   Sleep(1000);
}