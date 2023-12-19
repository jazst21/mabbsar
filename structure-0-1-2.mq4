//+------------------------------------------------------------------+
//|                                                         pugarjay |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pugarjay"
#property version   "1.00"
#property strict

extern double LotSize = 0.1;
extern int TakeProfit = 100; // Take Profit parameter in points
extern int StopLoss = 50; // Stop Loss parameter in points
extern double SARStep = 0.02; // SAR Step parameter
extern double SARMaximum = 0.2; // SAR Maximum parameter
extern double SARInitial = 0.02; // Initial SAR parameter
input int Slippage = 3;
int ticket;

// Function to calculate SAR signal for opening a position (Buy signal when SAR is above price)
double CalculateSARSignalOpen() {
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, SARInitial); // Parabolic SAR
    double currentPrice = Ask; // Current Ask price

    double sarSignalOpen = 0.0;

    if (sar > currentPrice) {
        sarSignalOpen = 1.0; // Set a value to indicate a buy signal
    }
    if (sar < currentPrice) {
        sarSignalOpen = -1.0; // Set a value to indicate a buy signal
    }

    return sarSignalOpen;
}

// Function to calculate Ichimoku Cloud signal for opening a position (buy signal when price is between Tenkan-sen and Kijun-sen, above Span A and Span B)
double CalculateIchimokuSignalOpen() {
    // Ichimoku Cloud calculations
    double ichimokuTenkanSen = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, 0);
    double ichimokuKijunSen = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, 0);
    double ichimokuSenkouA = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANA, 0);
    double ichimokuSenkouB = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, 0);
    double currentPrice = Close[0]; // Current close price

    double ichimokuSignalOpen = 0.0; // Initialize the signal

    if (currentPrice > ichimokuTenkanSen && currentPrice < ichimokuKijunSen && currentPrice > ichimokuSenkouA && currentPrice > ichimokuSenkouB) {
        ichimokuSignalOpen = 1.0; // Set a value to indicate a buy signal
    } else if (currentPrice < ichimokuTenkanSen && currentPrice > ichimokuKijunSen && currentPrice < ichimokuSenkouA && currentPrice < ichimokuSenkouB) {
        ichimokuSignalOpen = -1.0; // Set a value to indicate a sell signal
    }

    return ichimokuSignalOpen;
}


// Function to calculate SAR close signal based on price crossover
bool CalculateSARSignalClose() {
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, SARInitial); // Parabolic SAR
    double currentPrice = Close[0]; // Current close price
    bool sarSignalClose = false;

    // Condition for price crossover above SAR
    if (currentPrice > sar && Close[1] < sar) {
        sarSignalClose = true; // Set to true for a buy crossover
    }

    // Condition for price crossover below SAR
    if (currentPrice < sar && Close[1] > sar) {
        sarSignalClose = true; // Set to true for a sell crossover
    }

    return sarSignalClose;
}

// Function to calculate Ichimoku Cloud signal for closing a position (based on Chikou Span, Span A, or Span B crossover)
bool CalculateIchimokuSignalClose() {
    // Ichimoku Cloud calculations
    double ichimokuChikouSpan = iIchimoku(NULL, 0, 9, 26, 52, MODE_CHIKOUSPAN, 0);
    double ichimokuSenkouSpanA = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANA, 0);
    double ichimokuSenkouSpanB = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, 0);
    double currentPrice = Close[0]; // Current close price
    double previousPrice = Close[1]; // Previous close price

    bool ichimokuSignalClose = false; // Initialize the signal

    // Condition for price crossover above Chikou Span
    if ((currentPrice > ichimokuChikouSpan && previousPrice < ichimokuChikouSpan) ||
        (currentPrice > ichimokuSenkouSpanA && previousPrice < ichimokuSenkouSpanA) ||
        (currentPrice > ichimokuSenkouSpanB && previousPrice < ichimokuSenkouSpanB)) {
        ichimokuSignalClose = true; // Set to true for a buy crossover
    }

    // Condition for price crossover below Chikou Span
    if ((currentPrice < ichimokuChikouSpan && previousPrice > ichimokuChikouSpan) ||
        (currentPrice < ichimokuSenkouSpanA && previousPrice > ichimokuSenkouSpanA) ||
        (currentPrice < ichimokuSenkouSpanB && previousPrice > ichimokuSenkouSpanB)) {
        ichimokuSignalClose = true; // Set to true for a sell crossover
    }

    return ichimokuSignalClose;
}


// Function to handle Ichimoku-based closing of positions
void CalculateCloseSignal() {
    if (CalculateIchimokuSignalClose()) {
        int totalOrders = OrdersTotal();
        for (int i = totalOrders - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
                if (OrderSymbol() == Symbol() && OrderType() <= OP_SELL) {
                    // Closing logic based on Ichimoku signal
                    OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, Blue);
                }
            }
        }
    }
}



// Function to calculate overall open signal using SAR and Ichimoku signals
double CalculateOpenSignal() {
    double sarSignal = CalculateSARSignalOpen();
    double ichimokuSignal = CalculateIchimokuSignalOpen();
    double openSignal = 0.0;

    // If both SAR and Ichimoku indicate a buy, set buy signal
    if (sarSignal > 0 && ichimokuSignal > 0) {
        openSignal = 1.0; // Buy signal
    }
    // If both SAR and Ichimoku indicate a sell, set sell signal
    else if (sarSignal < 0 && ichimokuSignal < 0) {
        openSignal = -1.0; // Sell signal
    }
    return openSignal;
}


// Function to handle new tick events
void OnTick(){
    // Check for open positions
    if (OrdersTotal() > 0) {
        CalculateCloseSignal();
        return; // Exit the function if there are open positions
    }

    // No open positions, check for new trades
    double openSignal = CalculateOpenSignal();

    if (openSignal > 0) {
        // Buy signal
        ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "Buy Order", 0, Blue);
    } else if (openSignal < 0) {
        // Sell signal
        ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "Sell Order", 0, Red);
    }
}
