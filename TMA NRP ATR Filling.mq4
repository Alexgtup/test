#property copyright   "Copyright © 2023, Vladradon"
#property description " "
#property version     "1.0"
#property strict
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 8 
#include <iCanvas.mqh>

//--- input parameters
input int    History         = 1000;
extern int   PeriodTMA       = 1;
input int    PeriodATR       = 50;
input double BandsDeviations = 0.7;
input int    VerticalShift   = 0;  //Vertical Shift (0 - ATR)
input int    PeriodSmoth     = 0;    //Period Smoth (<2 - dasabled)

input int    AverageWidth    = 2;
input color  AverageColor1   = clrAqua;
input color  AverageColor2   = clrOrange;
input int    ChanelWidth     = 2;
input color  ChannelColor1   = clrBlue;
input color  ChannelColor2   = clrRed;
input color  FillingColor1   = clrBlue;
input color  FillingColor2   = clrRed;
input uchar  Transparent     = 100;                                 // Transparent (0 - 255)
input ENUM_LINE_STYLE LineStyle = STYLE_SOLID;
input int    LineWidth       = 3;
input color  LineColor       = clrChocolate;
input int    TextSize        = 10;
input color  TextColor       = clrWhite;
input bool   AutoVerticalSize = false;
input bool   ChartOnTop      = true;

input bool   AlertSound      = false;
input bool   AlertMessage    = false;
input bool   AlertMail       = false;
input bool   AlertMobile     = false;
input int    AlertBarShift   = 0;

//--- indicator buffers
double BufferTMA1[], BufferTMA2[];
double upBuffer[], upBuffer2[];
double dnBuffer[], dnBuffer2[];
double SigLineUp[], SigLineDn[];
double slope[], slopeUp[], slopeDn[];
bool First = true;
double SigUp=0.0, SigDn=0.0;
datetime TimeAlert=0;
int Start=0;
string Preff="LTMA";
datetime LastSig=0;
bool ScaleFix=false;

int OnInit()
  {
   IndicatorBuffers(11);
   
   SetIndexBuffer(0, BufferTMA1);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,AverageWidth,AverageColor1);
   SetIndexEmptyValue(0,0.0);
   
   SetIndexBuffer(1, BufferTMA2);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,AverageWidth,AverageColor2);
   SetIndexEmptyValue(1,0.0);
   
   SetIndexBuffer(2, upBuffer);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,ChanelWidth,ChannelColor1);
   SetIndexEmptyValue(2,0.0);
   
   SetIndexBuffer(3, upBuffer2);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,ChanelWidth,ChannelColor2);
   SetIndexEmptyValue(3,0.0);
   
   SetIndexBuffer(4, dnBuffer);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,ChanelWidth,ChannelColor1);
   SetIndexEmptyValue(4,0.0);
   
   SetIndexBuffer(5, dnBuffer2);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,ChanelWidth,ChannelColor2);
   SetIndexEmptyValue(5,0.0);
   
   SetIndexBuffer(6, SigLineUp);
   SetIndexStyle(6,DRAW_ARROW,STYLE_SOLID,AverageWidth,AverageColor1);
   SetIndexArrow(6,164);
   SetIndexEmptyValue(6,0.0);
   
   SetIndexBuffer(7, SigLineDn);
   SetIndexStyle(7,DRAW_ARROW,STYLE_SOLID,AverageWidth,AverageColor2);
   SetIndexArrow(7,164);
   SetIndexEmptyValue(7,0.0);
   
   SetIndexBuffer(8, slope);
   SetIndexStyle(8,DRAW_NONE,EMPTY,0,clrNONE);
   SetIndexEmptyValue(8,0.0);
   SetIndexBuffer(9, slopeUp);
   SetIndexStyle(9,DRAW_NONE,EMPTY,0,clrNONE);
   SetIndexEmptyValue(9,0.0);
   SetIndexBuffer(10, slopeDn);
   SetIndexStyle(10,DRAW_NONE,EMPTY,0,clrNONE);
   SetIndexEmptyValue(10,0.0);
   
   ScaleFix=ChartGetInteger(0,CHART_SCALEFIX);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,Preff);
   ChartSetInteger(0,CHART_SCALEFIX,ScaleFix);
  }
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
   if(History<=0) Start=MathMin(rates_total-1-PeriodTMA,5000);
   if(History>0)
     {
      Start=MathMin(rates_total-1-PeriodTMA,History+MathMax(PeriodTMA,50));
      SetIndexDrawBegin(0,rates_total-History);
      SetIndexDrawBegin(1,rates_total-History);
      SetIndexDrawBegin(2,rates_total-History);
      SetIndexDrawBegin(3,rates_total-History);
      SetIndexDrawBegin(4,rates_total-History);
      SetIndexDrawBegin(5,rates_total-History);
      SetIndexDrawBegin(6,rates_total-History);
      SetIndexDrawBegin(7,rates_total-History);
     }
   
   if(First) {Count(); First=false;}
   //---
   for(int i=AlertBarShift; i<5; i++)
   if(TimeAlert<time[i])
     {
      if(SigLineUp[i]>0)
        {
         if(AlertSound) PlaySound("Alert");
         if(AlertMessage) Alert("LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal BUY");
         if(AlertMail) SendMail("LWMA TMA", "LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal BUY");
         if(AlertMobile) SendNotification("LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal BUY");
         TimeAlert=time[i];
        }
      if(SigLineDn[i]>0)
        {
         if(AlertSound) PlaySound("Alert");
         if(AlertMessage) Alert("LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal SELL");
         if(AlertMail) SendMail("LWMA TMA", "LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal SELL");
         if(AlertMobile) SendNotification("LWMA TMA >> "+_Symbol+" "+PeriodString()+" >> Signal SELL");
         TimeAlert=time[i];
        }
     }
//-----------------------------
   return(rates_total);
  }
//+------------------------------------------------------------------+
void Count()
  {   
   ObjectsDeleteAll(0,Preff);
   
   ArrayInitialize(slope,0.0);
   ArrayInitialize(slopeUp,0.0);
   ArrayInitialize(slopeDn,0.0);
   ArrayInitialize(BufferTMA1,0.0);
   ArrayInitialize(BufferTMA2,0.0);
   ArrayInitialize(upBuffer,0.0);
   ArrayInitialize(dnBuffer,0.0); 
   ArrayInitialize(SigLineUp,0.0);
   ArrayInitialize(SigLineDn,0.0);
   
   Canvas.Erase(0); 
   double ATR=0.0;
   string text="";
   LastSig=0;

   for(int i=Start; i>=0; i--)
     {
      int NewIndex = i;
      double sumw = (PeriodTMA + 1);
      double sum  = sumw * Close[NewIndex];

      for(int j = 1, k = PeriodTMA; j <= PeriodTMA; j ++, k --)
        {
         sum  += k * Close[NewIndex + j];
         sumw += k;
         if(j <= NewIndex)
           {
            sum  += k * Close[NewIndex - j];
            sumw += k;
           }
        }
        
      if(sumw!=0.0) BufferTMA1[i] = sum/sumw;

      double diff = iClose(NULL,PERIOD_CURRENT,NewIndex) - BufferTMA1[i];
      
      if(PeriodSmoth>1) BufferTMA1[i] = iMAOnArray(BufferTMA1,0,PeriodSmoth,0,MODE_SMA,i);

      if(VerticalShift>0)
        {
         upBuffer[i] = BufferTMA1[i] + VerticalShift*_Point;
         dnBuffer[i] = BufferTMA1[i] - VerticalShift*_Point;
        }
      else
        {
         ATR=iATR(NULL,PERIOD_CURRENT,PeriodATR,i);
         upBuffer[i] = BufferTMA1[i] + BandsDeviations * ATR;
         dnBuffer[i] = BufferTMA1[i] - BandsDeviations * ATR;
        }

      slopeUp[i]=slopeUp[i+1];
      if(upBuffer[i]>upBuffer[i+1]) slopeUp[i]=1;
      if(upBuffer[i]<upBuffer[i+1]) slopeUp[i]=-1;
      
      slopeDn[i]=slopeDn[i+1];
      if(dnBuffer[i]>dnBuffer[i+1]) slopeDn[i]=1;
      if(dnBuffer[i]<dnBuffer[i+1]) slopeDn[i]=-1;
      
      slope[i]=slope[i+1];
      
      if(LastSig<Time[i])
        {
         for(int j=i+1; j<Start; j++)
           {
            if(slopeUp[j]>0 && slopeUp[j+1]<0)
            if((int)((BufferTMA1[i]-upBuffer[j])/_Point)>=0 && LastSig<Time[j])
              {
               slope[i]=1; SigLineUp[i]=BufferTMA1[i];
               DrawLine(Preff+(string)Time[i]+"L", Time[i], BufferTMA1[i], Time[j-1], BufferTMA1[i]);
               text=DoubleToString((BufferTMA1[i]-Close[i])/_Point,0);
               DrawRect(Preff+(string)Time[i], Time[i], MathMin(dnBuffer[i]-100*_Point,Low[i]-100*_Point), text, TextColor, TextSize, clrWhite);
               text="BUY";
               DrawRect(Preff+(string)Time[i]+"T", Time[i], BufferTMA1[i]-80*_Point, text, TextColor, TextSize, clrWhite,0);
               LastSig=Time[j];
               break;
              }
            //---
            if(slopeDn[j]<0 && slopeDn[j+1]>0)
            if((int)((dnBuffer[j]-BufferTMA1[i])/_Point)>=0 && LastSig<Time[j])
              {
               slope[i]=-1; SigLineDn[i]=BufferTMA1[i];
               DrawLine(Preff+(string)Time[i]+"L", Time[i], BufferTMA1[i], Time[j-1], BufferTMA1[i]);
               text=DoubleToString((BufferTMA1[i]-Close[i])/_Point,0);
               DrawRect(Preff+(string)Time[i], Time[i], MathMax(upBuffer[i]+150*_Point, High[i]+100*_Point), text, TextColor, TextSize, clrWhite);
               text="SELL";
               DrawRect(Preff+(string)Time[i]+"T", Time[i], BufferTMA1[i]+50*_Point, text, TextColor, TextSize, clrWhite,2);
               LastSig=Time[j];
               break;
              }
            if(LastSig>=Time[j]) break;
           }
        }
      BufferTMA2[i]=0; upBuffer2[i]=0; dnBuffer2[i]=0;
      if(slope[i]==-1 || (slope[i+1]==-1 && slope[i]==1))
        {
         BufferTMA2[i]=BufferTMA1[i]; BufferTMA2[i+1]=BufferTMA1[i+1];
         upBuffer2[i]=upBuffer[i]; //upBuffer2[i+1]=upBuffer[i+1];
         dnBuffer2[i]=dnBuffer[i]; //dnBuffer2[i+1]=dnBuffer[i+1];
        }
     }

   if(AutoVerticalSize)
     {
      int BarsChart=MathMin((int)ChartGetInteger(0,CHART_VISIBLE_BARS), Start);
      int FirstVisBar=(int)ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR); 
      int FirstBar=FirstVisBar-BarsChart;
      int count=MathMin(History-FirstBar,FirstVisBar-FirstBar);
      double Hi=High[ArrayMaximum(High,count,FirstBar)];
      double Lo=Low[ArrayMinimum(Low,count,FirstBar)];
      double PriceUp=MathMax(upBuffer[ArrayMaximum(upBuffer,count,FirstBar)],Hi);
      double PriceDn=MathMin(dnBuffer[ArrayMinimum(dnBuffer,count,FirstBar)],Lo);
      double Diff=(PriceUp-PriceDn)/100*1; 
      ChartSetInteger(0,CHART_SCALEFIX,true);
      ChartSetDouble(0,CHART_FIXED_MAX,PriceUp+Diff);
      ChartSetDouble(0,CHART_FIXED_MIN,PriceDn-Diff); 
      ChartRedraw();
     }
   else ChartSetInteger(0,CHART_SCALEFIX,ScaleFix);
   
   double fMAFastPrev = upBuffer[Start];
   double fMASlowPrev = dnBuffer[Start];  
   for(int i=Start; i>=0; i--)
     {   
      if((History>0 && i<History) || History<=0)
        FillArea(i, fMAFastPrev, fMASlowPrev, upBuffer[i], dnBuffer[i], slope[i+1]>0 ? FillingColor1 : FillingColor2);
      
      fMAFastPrev = upBuffer[i];
      fMASlowPrev = dnBuffer[i];
     }
   Canvas.Update(); 
   
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string name=ObjectName(0,i);
      if(StringFind(name,"iCanvas",0)>=0) {ObjectSetInteger(0,name,OBJPROP_BACK,ChartOnTop); break;}
     } 
  }
//-------------------------------------------------------------------------------
string PeriodString(ENUM_TIMEFRAMES tf=PERIOD_CURRENT)
  {
   switch (tf) 
    {
     case PERIOD_M1:  return("M1");
     case PERIOD_M5:  return("M5");
     case PERIOD_M15: return("M15");
     case PERIOD_M30: return("M30");
     case PERIOD_H1:  return("H1");
     case PERIOD_H4:  return("H4");
     case PERIOD_D1:  return("D1");
     case PERIOD_W1:  return("W1");
     case PERIOD_MN1: return("MN1");
     default: return("M"+(string)_Period);
   }  
   return("M"+(string)_Period); 
  }   
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Processing the chart events                                                                                                                                                              |
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
  {
   if(id!=CHARTEVENT_CHART_CHANGE) return;
   if(!First) Count(); 
  }
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Filling the arrea between two bars and two lines                                                                                                                                         |
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void FillArea(const int nBarIndex, const double fPrevBarPrice1, const double fPrevBarPrice2, const double fCurBarPrice1, const double fCurBarPrice2, const color clrFilling)
{
   datetime dtLeftBar = iTime(NULL, PERIOD_CURRENT, nBarIndex + 1);
   datetime dtRightBar = iTime(NULL, PERIOD_CURRENT, nBarIndex);

   int nXLeft, nXRight, nYFastLineLeft, nYFastLineRight, nYSlowLineLeft, nYSlowLineRight;
   ChartTimePriceToXY(0, 0, dtLeftBar, fPrevBarPrice1, nXLeft, nYFastLineLeft);
   ChartTimePriceToXY(0, 0, dtRightBar, fCurBarPrice1, nXRight, nYFastLineRight);
   ChartTimePriceToXY(0, 0, dtRightBar, fCurBarPrice2, nXRight, nYSlowLineRight);
   ChartTimePriceToXY(0, 0, dtLeftBar, fPrevBarPrice2, nXLeft, nYSlowLineLeft);
   
   double fKFastLine, fKSlowLine;
   double fBFastLine = CalculateBAndKKoefs(nXLeft, nYFastLineLeft - 3, nXRight, nYFastLineRight - 3, fKFastLine);
   double fBSlowLine = CalculateBAndKKoefs(nXLeft, nYSlowLineLeft - 3, nXRight, nYSlowLineRight - 3, fKSlowLine);
   
   for (int nByX = nXLeft; nByX <= nXRight; ++nByX)
   {
      int nYFastLine = Round(fKFastLine * nByX + fBFastLine);
      int nYSlowLine = Round(fKSlowLine * nByX + fBSlowLine);
      int nMinY = fmin(nYFastLine, nYSlowLine);
      int nMaxY = fmax(nYFastLine, nYSlowLine);
      
      for (int nByY = nMinY; nByY <= nMaxY; ++nByY)
         Canvas.PixelSet(nByX, nByY, ColorToARGB(clrFilling, Transparent));
   }
}
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| K and B сoefficients calculating by equation of a straight line                                                                                                                          |
//+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double CalculateBAndKKoefs(const int nX1, const int nY1, const int nX2, const int nY2, double &fKKoef)
  {
   if(nX1 == nX2) return DBL_MAX;
      
   fKKoef = (nY2 - nY1) / 1.0 / (nX2 - nX1);
   return nY1 - fKKoef * nX1;   
  }
//----------------------------------------------------------------------------
void DrawRect(string Name="", datetime time1=0, double price1=0.0, string Text="", color TextCol=0, int FontSize=0, color Color=clrWhite, ENUM_ANCHOR_POINT an=0)
  {
 /*  datetime time2=datetime(time1+_Period*60*(5-ChartGetInteger(0,CHART_SCALE,0)+15));
   double price2=price1+100*_Point;
   if(ObjectFind(0,Name)<0)
   if(!ObjectCreate(0,Name,OBJ_RECTANGLE,0,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, ": не удалось создать прямоугольник! Код ошибки = ",GetLastError()); 
      return; 
     } 
   ObjectSetInteger(0,Name,OBJPROP_COLOR,Color); 
   ObjectSetInteger(0,Name,OBJPROP_STYLE,STYLE_SOLID); 
   ObjectSetInteger(0,Name,OBJPROP_WIDTH,1); 
   ObjectSetInteger(0,Name,OBJPROP_FILL,true); 
   ObjectSetInteger(0,Name,OBJPROP_BACK,false); 
   ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,Name,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,Name,OBJPROP_HIDDEN,true); */
   
   Name+="Txt";
   if(ObjectFind(0,Name)<0)
     {
      if(!ObjectCreate(0,Name,OBJ_TEXT,0,time1-_Period*60,price1)) 
        { 
         Print(__FUNCTION__, ": failed to create object! Error code = ",GetLastError()); 
         return; 
        } 
      ObjectSetString(0,Name,OBJPROP_TEXT,Text); 
      ObjectSetString(0,Name,OBJPROP_FONT,"Arial"); 
      ObjectSetInteger(0,Name,OBJPROP_FONTSIZE,FontSize); 
      ObjectSetDouble(0,Name,OBJPROP_ANGLE,0); 
      ObjectSetInteger(0,Name,OBJPROP_ANCHOR,an); 
      ObjectSetInteger(0,Name,OBJPROP_COLOR,TextCol); 
      ObjectSetInteger(0,Name,OBJPROP_BACK,false); 
      ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false); 
      ObjectSetInteger(0,Name,OBJPROP_SELECTED,false); 
      ObjectSetInteger(0,Name,OBJPROP_HIDDEN,true); 
     }
  }
//+------------------------------------------------------------------+
void DrawLine(string Name="", datetime time1=0, double price1=0.0, datetime time2=0, double price2=0.0)
  {
   if(ObjectFind(0,Name)<0)
     {
      if(!ObjectCreate(0,Name,OBJ_TREND,0,time1,price1,time2,price2)) 
        { 
         Print(__FUNCTION__, ": failed to create object! Error code = ",GetLastError()); 
         return; 
        } 
      ObjectSetInteger(0,Name,OBJPROP_COLOR,LineColor); 
      ObjectSetInteger(0,Name,OBJPROP_STYLE,LineStyle); 
      ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth); 
      ObjectSetInteger(0,Name,OBJPROP_BACK,false); 
      ObjectSetInteger(0,Name,OBJPROP_SELECTABLE,false); 
      ObjectSetInteger(0,Name,OBJPROP_SELECTED,false); 
      ObjectSetInteger(0,Name,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,Name,OBJPROP_RAY,false); 
    }   
  }
//+------------------------------------------------------------------+   
