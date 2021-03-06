//+------------------------------------------------------------------+
//|                                                     MiddleH1.mq5 |
//|                                                 Tislin (ttss000) |
//|                                      https://twitter.com/ttss000 |
//+------------------------------------------------------------------+
//reference: https://humidity50.com/archives/post-14734html

#property copyright "Tislin (ttss000)"
#property link      "https://twitter.com/ttss000"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1 "MA_L_Line"     // データウィンドウでのプロット名
#property indicator_type1   DRAW_LINE   // プロットの種類は「線」
#property indicator_color1  clrBlack     // 線の色
#property indicator_style1 STYLE_SOLID // 線のスタイル
#property indicator_width1  1           // 線の幅

#property indicator_label2 "UpArrow"     // データウィンドウでのプロット名
#property indicator_type2   DRAW_ARROW   // プロットの種類は「yajirushi」
#property indicator_color2  clrBlue     // 線の色
#property indicator_style2 STYLE_SOLID // 線のスタイル
#property indicator_width2  1           // 線の幅

#property indicator_label3 "DnArrow"     // データウィンドウでのプロット名
#property indicator_type3   DRAW_ARROW   // プロットの種類は「yajirushi」
#property indicator_color3  clrRed     // 線の色
#property indicator_style3 STYLE_SOLID // 線のスタイル
#property indicator_width3  1           // 線の幅

input int Symbol_UP=217; //上向きの記号の文字コード
input int Symbol_Down=218; //下向きの記号の文字コード

double Middle_Line[]; //
double UpArrow[];
double DnArrow[];


//+------------------------------------------------------------------+
int ObjectType(string name)
{
  return ObjectGetInteger (0, name, OBJPROP_TYPE);
}
//+------------------------------------------------------------------+
datetime TimeMonth(datetime TargetTime)
{
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.mon;
}
//+------------------------------------------------------------------+
datetime TimeDay(datetime TargetTime)
{
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.day;
}
//+------------------------------------------------------------------+
datetime TimeMinute(datetime TargetTime)
{
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.min;
}
//+------------------------------------------------------------------+
datetime TimeHour(datetime TargetTime)
{
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.hour;
}
//+------------------------------------------------------------------+
datetime TimeDayOfWeek(datetime TargetTime)
{
  MqlDateTime tm;
  TimeToStruct(TargetTime,tm);
  return tm.day_of_week;
}
//+------------------------------------------------------------------+//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
  SetIndexBuffer(0,Middle_Line, INDICATOR_DATA);
  PlotIndexSetInteger(0,PLOT_LINE_STYLE, STYLE_SOLID);

  SetIndexBuffer(1,UpArrow, INDICATOR_DATA);
  PlotIndexSetInteger(1,PLOT_ARROW,Symbol_UP);

  SetIndexBuffer(2,DnArrow, INDICATOR_DATA);
  PlotIndexSetInteger(2,PLOT_ARROW,Symbol_Down);
//---

  ArraySetAsSeries(Middle_Line, true);
  ArraySetAsSeries(UpArrow, true);
  ArraySetAsSeries(DnArrow, true);

  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
  MqlDateTime tm;

  int limit;

  double highest_H1=-1;
  double lowest_H1=-1;

  int i_highest_H1=-1;
  int i_lowest_H1=-1;

  if(prev_calculated == 0){
    limit = rates_total - 2;
  }else{
    limit = rates_total - prev_calculated;
  }

  for(int i = limit ; 0 <= i ; i--){

    UpArrow[i]=EMPTY_VALUE;
    DnArrow[i]=EMPTY_VALUE;

    // Get hour
    int ibar_hour_begin = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_CURRENT, i), false);
    int ibar_hour_begin_current_period = iBarShift(NULL, PERIOD_CURRENT, iTime(NULL, PERIOD_H1, ibar_hour_begin), false);
    i_highest_H1 = iHighest(NULL, PERIOD_CURRENT, MODE_HIGH, ibar_hour_begin_current_period-i+1, i);
    i_lowest_H1 = iLowest(NULL, PERIOD_CURRENT, MODE_HIGH, ibar_hour_begin_current_period-i+1, i);
    highest_H1 = iHigh(NULL, PERIOD_CURRENT, i_highest_H1);
    lowest_H1 = iLow(NULL, PERIOD_CURRENT, i_lowest_H1);
    Middle_Line[i]=(highest_H1+lowest_H1)/2;
    //if(i==40){
    //  Print("i=40 iTime(NULL, PERIOD_CURRENT, i)="+iTime(NULL, PERIOD_CURRENT, i));
    //  //Print("i=10 dt_hour="+dt_hour);
    //  Print("i=40 ibar_hour_begin="+ibar_hour_begin);
    //  Print("i=40 ibar_hour_begin_current_period="+ibar_hour_begin_current_period);
    //  Print("i=40 i_highest_H1="+i_highest_H1);
    //  Print("i=40 i_lowest_H1="+i_lowest_H1);
    //  Print("i=40 highest_H1="+highest_H1);
    //  Print("i=40 lowest_H1="+lowest_H1);
    //  Print("i=40 Middle_Line[i]="+Middle_Line[i]);
    //}

    // buy signal
    if(Middle_Line[i] < iLow(NULL, PERIOD_CURRENT, i) && iLow(NULL, PERIOD_CURRENT, i) < iLow(NULL, PERIOD_CURRENT, i+1)    ){
      UpArrow[i]=iLow(NULL, PERIOD_CURRENT, i)-10*Point();
    }

    // sell signal
    if(Middle_Line[i] > iHigh(NULL, PERIOD_CURRENT, i) && iHigh(NULL, PERIOD_CURRENT, i) > iHigh(NULL, PERIOD_CURRENT, i+1)    ){
      DnArrow[i]=iHigh(NULL, PERIOD_CURRENT, i)+10*Point();
    }


  }

//--- return value of prev_calculated for next call
  return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---

}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---

}
//+------------------------------------------------------------------+
