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

int ticket;

// Function to calculate SAR signal
double CalculateSARSignal() {
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, SARInitial); // Parabolic SAR
    double sarSignal = 0.0;

    if (sar > Close[1]) {
        // SAR above price, indicating potential uptrend
        sarSignal = 1.0; // Buy signal
    } else if (sar < Close[1]) {
        // SAR below price, indicating potential downtrend
        sarSignal = -1.0; // Sell signal
    }

    return sarSignal;
}

// Function to calculate Ichimoku signal
double CalculateIchimokuSignal() {
    // Ichimoku Cloud calculations
    double ichimokuTenkan = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, 0);
    double ichimokuKijun = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, 0);
    double ichimokuSenkouA = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANA, 0);
    double ichimokuSenkouB = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, 0);
    double ichimokuSignal = 0.0;

    // Check Ichimoku Cloud trend direction
    if (Close[1] < ichimokuKijun && Close[1] < ichimokuSenkouA && Close[1] < ichimokuSenkouB) {
        ichimokuSignal = 1.0; // Buy signal
    } else if (Close[1] > ichimokuKijun && Close[1] > ichimokuSenkouA && Close[1] > ichimokuSenkouB) {
        ichimokuSignal = -1.0; // Sell signal
    }

    return ichimokuSignal;
}

// Function to calculate SAR close signal
bool CalculateSARCloseSignal() {
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, SARInitial); // Parabolic SAR
    bool sarCloseSignal = false;

    if (sar == Close[1]) {
        sarCloseSignal = true; // Close signal when SAR equals price
    }

    return sarCloseSignal;
}

// Function to handle SAR-based closing of positions
void ClosePositionsBySAR() {
    bool closeSignal = CalculateSARCloseSignal();

    if (closeSignal) {
        // Close existing positions based on SAR signal
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {
                    OrderClose(OrderTicket(), OrderLots(), Bid, 3, Blue);
                } else if (OrderType() == OP_SELL) {
                    OrderClose(OrderTicket(), OrderLots(), Ask, 3, Red);
                }
            }
        }
    }
}

// Function to calculate overall open signal using SAR and Ichimoku signals
double CalculateOpenSignal() {
    double sarSignal = CalculateSARSignal();
    double ichimokuSignal = CalculateIchimokuSignal();
    double openSignal = 0.0;

    // Check if SAR and Ichimoku signals are aligned
    if (sarSignal == ichimokuSignal) {
        openSignal = sarSignal; // Set the open signal to aligned signal
    }

    return openSignal;
}

// Function to handle new tick events
void OnTick(){
    // Check for open positions
    if (OrdersTotal() > 0) {
        ClosePositionsBySAR();
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
