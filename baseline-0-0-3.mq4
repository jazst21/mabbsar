// Define variables and constants
extern double LotSize = 0.1;
extern double ATRThreshold = 0.001; // ATR threshold parameter
extern int TakeProfit = 100; // Take Profit parameter in points
extern int StopLoss = 50; // Stop Loss parameter in points
extern double SARStep = 0.02; // SAR Step parameter
extern double SARMaximum = 0.2; // SAR Maximum parameter
extern int CloseTakeProfit = 80; // Close Take Profit parameter in points
extern int CloseStopLoss = 40; // Close Stop Loss parameter in points

int ticket;

// Define indicator or price variables
double signalValue;

// Function to calculate signal value for opening trades
double CalculateOpenSignal(){
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, 0); // Parabolic SAR
    double atr = iATR(NULL, 0, 14); // ATR with period 14

    // Implement your signal calculation logic for opening trades using SAR and ATR with the threshold parameter
    double calculatedValue = 0.0;

    if (sar < Close[1] && atr > ATRThreshold) {
        calculatedValue = 1.0; // Signal for buying
    } else if (sar > Close[1] && atr > ATRThreshold) {
        calculatedValue = -1.0; // Signal for selling
    }

    return calculatedValue;
}

// Function to calculate signal value for closing trades
double CalculateCloseSignal(){
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, 0); // Parabolic SAR
    double atr = iATR(NULL, 0, 14); // ATR with period 14

    // Implement your signal calculation logic for closing trades using SAR and ATR with different parameters
    double calculatedValue = 0.0;

    if (sar < Close[1] && atr > ATRThreshold && High[1] - Low[1] > ATR(NULL, 0, 14) * 2) {
        calculatedValue = -1.0; // Signal to close buy orders
    } else if (sar > Close[1] && atr > ATRThreshold && High[1] - Low[1] > ATR(NULL, 0, 14) * 2) {
        calculatedValue = 1.0; // Signal to close sell orders
    }

    return calculatedValue;
}

// Initialization function
int OnInit(){
    // Initialize any necessary parameters or indicators
    // Return 0 for successful initialization
    return(INIT_SUCCEEDED);
}

// De-initialization function
void OnDeinit(const int reason){
    // Perform any cleanup or final operations
}

// Function to handle new tick events
void OnTick(){
    // Calculate the signal value for opening trades using the separate function
    double openSignal = CalculateOpenSignal();

    // Implement trading logic based on the calculated open signal
    if(openSignal > 0){
        // Open a buy trade with Take Profit and Stop Loss
        ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, 0, 0, "Buy Order", 0, TakeProfit, Blue);
        if(ticket > 0){
            // Set Stop Loss for the Buy Order
            OrderSend(Symbol(), OP_SL, Bid - StopLoss * Point, LotSize, 3, 0, 0, "Stop Loss", 0, Red);
        }
    } else if(openSignal < 0){
        // Open a sell trade with Take Profit and Stop Loss
        ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, 0, 0, "Sell Order", 0, TakeProfit, Blue);
        if(ticket > 0){
            // Set Stop Loss for the Sell Order
            OrderSend(Symbol(), OP_SL, Ask + StopLoss * Point, LotSize, 3, 0, 0, "Stop Loss", 0, Red);
        }
    }

    // Calculate the signal value for closing trades using the separate function
    double closeSignal = CalculateCloseSignal();

    // Implement trading logic based on the calculated close signal
    if(closeSignal > 0){
        // Close all buy orders
        for(int i = OrdersTotal() - 1; i >= 0; i--){
            if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_BUY){
                OrderClose(OrderTicket(), OrderLots(), Bid, 3, Blue);
            }
        }
    } else if(closeSignal < 0){
        // Close all sell orders
        for(int i = OrdersTotal() - 1; i >= 0; i--){
            if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_SELL){
                OrderClose(OrderTicket(), OrderLots(), Ask, 3, Blue);
            }
        }
    }

    // Implement other conditions or actions based on your strategy
}

// Additional functions for handling different events can be added as needed
