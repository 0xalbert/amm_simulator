#!/usr/bin/env Rscript
library(glue)
args = commandArgs(trailingOnly=TRUE)

# Simulator of constant product AMM (Uniswap V1/V2) 
# Formulas: 
# x * y = k
# Original whitepaper https://hackmd.io/@HaydenAdams/HJ9jLsfTz

# Initial system variables
x = 10000       # Initial SNX liquidity
y = 38.35          # Initial ETH liquidity
k = x * y       # k as per Uniswap formula
P = x / y       # Initial price of y in terms of x
n = 5000        # Number of trades simulated
yReq = 0;       # Computed y required to meet k
minP = 260     # Default minimum price
maxP = 390     # Default maximum price
volumeSNX = 0   # Volume of DAI traded
plot = 0;

if (length(args)==1) {
  n = strtoi(args[1], base = 0L)
} else if (length(args)==4) {
  n = strtoi(args[1], base = 0L)
  minP = strtoi(args[2], base = 0L)
  maxP = strtoi(args[3], base = 0L)
  plot = strtoi(args[4], base = 0L)
} 

# Initial state as vector of x, y, k and price
initialState <- c(x, y, k, P)

# Generate matrix from initial state
mat <- matrix(initialState, byrow = TRUE, nrow = n, ncol = length(initialState))

# Generate random prices
# SNX/ETH
randomPricesA <- runif(n = n, min = minP, max = maxP)
# SNX/USD
randomPricesB <- runif(n = n, min = 9, max = 15)

# Derived from Uniswap formula
getY <- function(k,y,P) {
  numerator = P -  sqrt(k * P)
  denominator = P - y
  y = (numerator / denominator)
}

fees = 0
totalVolume = 0
# Simulate trades
for (r in 1:nrow(mat))   
  for (c in 1:ncol(mat))
  # Skip the first line as it is the initial state
    if (r > 1) {
      if (c == 2) {
        
        # Compute y 
        current_k = mat[r-1, 3]
        current_P = randomPricesA[r]
        current_y = mat[r-1, 2]
        #print(glue::glue("Current k {current_k} P {current_P} Y {current_y}"))
        yReq = (getY(current_k, current_y, current_P))
        if (yReq < 0) {
            yReq = -1 * yReq
        }
        mat[r, 1] = mat[r-1, 3] / yReq
        mat[r, 2] = yReq
        mat[r, 3] = yReq * mat[r-1, 3] / yReq
        mat[r, 4] = randomPricesA[r]
        # Volume
        if ((mat[r, 1] -  mat[r-1, 1]) > 0) {
          volumeSNX = mat[r, 1] -  mat[r-1, 1]
        } else {
          volumeSNX = -1 * (mat[r, 1] - mat[r-1, 1]) 
        }
        #print(glue::glue("Previous bal {mat[r-1, 1]} new bal {mat[r, 1]} volume {volumeSNX}"))
        # Fees calculated in terms of x
        fees = fees + (volumeSNX * 0.003); 
        # Total volume
        totalVolume = totalVolume + volumeSNX

        }
      }

# Pool balances
deltaSnx = (mat[n, 1]) - x
if (x > (mat[n, 1] )) {
  deltaSnx = -1 * (x - mat[n, 1] )
}

deltaEth = mat[n, 2] - y
if (y > mat[n, 2]) {
  deltaEth = -1 * (y - mat[n, 2])
}

# Impermanent loss calculation
# Value of initial position at the end of the simulation
V0 = (x * randomPricesB[n]) + (y * randomPricesA[n])  

# Actual value of position at the end of the simulation
V1 = (mat[n, 1] * randomPricesB[n]) + (mat[n, 2] * randomPricesA[n]) 

# IL as delta in portfolio value
IL = (V1 - V0)

# IL as percentage loss
IL = (IL / V0) * 100

# Get min and max price 
minPrice = randomPricesA[which.min(randomPricesA)]
maxPrice = randomPricesA[which.max(randomPricesA)]

# Print impermanent loss

glue::glue("\n\nSimulation ran over {n} trades\n\n")
glue::glue("Initial balances: {mat[1, 1]} SNX and {mat[1, 2]} ETH")
glue::glue("Current  balances: {mat[n, 1]} SNX and {mat[n, 2]} ETH")
glue::glue("SNX delta {deltaSnx} ETH delta {deltaEth} ")
glue::glue("ETH/SNX min {minPrice} max  {maxPrice} last {randomPricesA[n]}")
glue::glue("Impermanent loss is {IL} %")
glue::glue("Fees accrued are {fees} SNX (${fees*randomPricesB[n]})")
glue::glue("Total volume {totalVolume} SNX (${totalVolume * randomPricesB[n]})\n\n")

timeSeries = ts(data = randomPricesA, start = 1, end = n, frequency = 1,  deltat = 1, names = )
matplot(timeSeries, type = "l")

if (plot) {
  # Plot results
  XY <- data.frame(mat)

  matplot(XY[,c(1)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
        xlab = "DAI in pool", ylab = "ETH price")

  matplot(XY[,c(2)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
        xlab = "ETH in pool", ylab = "ETH price")

}
    

       