// Expert Advisor properties
input int FastMAPeriod = 5;  // Period for the fast Moving Average
input int SlowMAPeriod = 20; // Period for the slow Moving Average
input double SARStep = 0.02; // Parabolic SAR step value
input double SARMaximum = 0.2; // Parabolic SAR maximum value
input int TakeProfit = 50;    // Take Profit in points
input int StopLoss = 50;      // Stop Loss in points

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
    
    int slippage = 3; // Define slippage here

    if (currentFastMA > currentSlowMA && lastFastMA <= lastSlowMA && lastSignal != 1)
    {
        // Buy signal (Fast MA crosses above Slow MA)
        lastSignal = 1;
        if (OrdersTotal() == 0) // Check if there are no open orders
        {
            double buyPrice = Ask;
            double buyStopLoss = buyPrice - StopLoss * Point;
            double buyTakeProfit = buyPrice + TakeProfit * Point;
            
            int buyTicket = OrderSend(Symbol(), OP_BUY, 0.1, buyPrice, slippage, buyStopLoss, buyTakeProfit, "Buy Order", 0, Blue);
            if (buyTicket > 0) {
                Print("Buy order opened with ticket #", buyTicket);
            } else {
                Print("Error opening buy order. Error code:", GetLastError());
            }
        }
    }
    else if (currentFastMA < currentSlowMA && lastFastMA >= lastSlowMA && lastSignal != -1)
    {
        // Sell signal (Fast MA crosses below Slow MA)
        lastSignal = -1;
        if (OrdersTotal() == 0) // Check if there are no open orders
        {
            double sellPrice = Bid;
            double sellStopLoss = sellPrice + StopLoss * Point;
            double sellTakeProfit = sellPrice - TakeProfit * Point;
            
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
