//+------------------------------------------------------------------+
//|                                                         pugarjay |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pugarjay"
#property version   "1.00"
#property strict

// Expert Advisor properties
input int FastMAPeriod = 10;  // Period for the fast Moving Average
input int SlowMAPeriod = 20; // Period for the slow Moving Average
input double SARStep = 0.02; // Parabolic SAR step value
input double SARMaximum = 0.2; // Parabolic SAR maximum value
input int TakeProfit = 100;    // Take Profit in points
input int StopLoss = 200;      // Stop Loss in points

// Define global variables
double lastFastMA, lastSlowMA;
int lastSignal = 0; // 0: No trade, 1: Buy, -1: Sell

// Initialize function
int OnInit()
{
    // Initialize MA values
    lastFastMA = iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    lastSlowMA = iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    return(INIT_SUCCEEDED);
}

// Start function
void OnTick()
{
    double currentFastMA = iMA(NULL, 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    double currentSlowMA = iMA(NULL, 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
    
    double currentSAR = iSAR(NULL, 0, SARStep, SARMaximum, 0);
    
    double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);

    int slippage = 5; // Increased slippage to avoid error 130

    // Check for open positions
    if (OrdersTotal() > 0) {
        int total = OrdersTotal();
        for (int i = total - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                if (OrderType() == OP_BUY && currentPrice < currentSAR) {
                    // Close Buy position if price falls below SAR
                    OrderClose(OrderTicket(), OrderLots(), currentPrice, slippage, Red);
                } else if (OrderType() == OP_SELL && currentPrice > currentSAR) {
                    // Close Sell position if price rises above SAR
                    OrderClose(OrderTicket(), OrderLots(), currentPrice, slippage, Blue);
                }
            }
        }
    }

    // Check for new trade signals
    if (currentFastMA > currentSlowMA && lastFastMA <= lastSlowMA && lastSignal != 1 && currentPrice > currentSAR)
    {
        // Buy signal (Fast MA crosses above Slow MA and price above SAR)
        lastSignal = 1;
        if (OrdersTotal() == 0) // Check if there are no open orders
        {
            double buyPrice = Ask;
            double buyStopLoss = buyPrice - (StopLoss + 10) * Point; // Adjusted Stop Loss level with additional distance
            double buyTakeProfit = buyPrice + (TakeProfit + 10) * Point; // Adjusted Take Profit level with additional distance
            
            int buyTicket = OrderSend(Symbol(), OP_BUY, 0.1, buyPrice, slippage, buyStopLoss, buyTakeProfit, "Buy Order", 0, Blue);
            if (buyTicket > 0) {
                Print("Buy order opened with ticket #", buyTicket);
            } else {
                Print("Error opening buy order. Error code:", GetLastError());
            }
        }
    }
    else if (currentFastMA < currentSlowMA && lastFastMA >= lastSlowMA && lastSignal != -1 && currentPrice < currentSAR)
    {
        // Sell signal (Fast MA crosses below Slow MA and price below SAR)
        lastSignal = -1;
        if (OrdersTotal() == 0) // Check if there are no open orders
        {
            double sellPrice = Bid;
            double sellStopLoss = sellPrice + (StopLoss + 10) * Point; // Adjusted Stop Loss level with additional distance
            double sellTakeProfit = sellPrice - (TakeProfit + 10) * Point; // Adjusted Take Profit level with additional distance
            
            int sellTicket = OrderSend(Symbol(), OP_SELL, 0.1, sellPrice, slippage, sellStopLoss, sellTakeProfit, "Sell Order", 0, Red);
            if (sellTicket > 0) {
                Print("Sell order opened with ticket #", sellTicket);
            } else {
                Print("Error opening sell order. Error code:", GetLastError());
            }
        }
    }
    
    lastFastMA = currentFastMA;
    lastSlowMA = currentSlowMA;
}
