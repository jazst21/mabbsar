extern double LotSize = 0.1;
extern int TakeProfit = 100; // Take Profit parameter in points
extern int StopLoss = 50; // Stop Loss parameter in points
extern double SARStep = 0.02; // SAR Step parameter
extern double SARMaximum = 0.2; // SAR Maximum parameter
extern double SARInitial = 0.02; // Initial SAR parameter

int ticket;

// Function to calculate signal value for opening trades
double CalculateOpenSignal(){
    double sar = iSAR(NULL, 0, SARStep, SARMaximum, SARInitial); // Parabolic SAR

    // Implement your signal calculation logic for opening trades using only SAR
    double calculatedValue = 0.0;

    if (sar > Close[1]) {
        calculatedValue = 1.0; // Signal for buying when SAR is greater than price
    } else if (sar < Close[1]) {
        calculatedValue = -1.0; // Signal for selling when SAR is less than price
    }

    return calculatedValue;
}

// Initialization function
int OnInit(){
    return(INIT_SUCCEEDED);
}

// De-initialization function
void OnDeinit(const int reason){
    // Perform any cleanup or final operations
}

// Function to handle new tick events
void OnTick(){
    // Check for open positions before opening a new trade
    if (OrdersTotal() > 0) {
        return; // Exit the function if there's an open position
    }

    double openSignal = CalculateOpenSignal();

    if(openSignal > 0){
        ticket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "Buy Order", 0, Blue);
    } else if(openSignal < 0){
        ticket = OrderSend(Symbol(), OP_SELL, LotSize, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "Sell Order", 0, Red);
    }
}
