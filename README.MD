# property copyright "pugarjay"
#### property version   "1.00"

> A simple expert advisor metatrader4 with fast-slow MA, bollinger band
> and parabolic sar

main signal parameters:

    input int FastMAPeriod = 10;  // Period for the fast Moving Average
    input int SlowMAPeriod = 20; // Period for the slow Moving Average
    input double SARStep = 0.02; // Parabolic SAR step value
    input double SARMaximum = 0.2; // Parabolic SAR maximum value
    input int TakeProfit = 30;    // Take Profit in points
    input int StopLoss = 100;      // Stop Loss in points

main strategy:

> 1. above ma fast-slow
> 2. crossover sar

