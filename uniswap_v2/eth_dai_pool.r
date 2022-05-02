#!/usr/bin/env Rscript
path = getwd()
source(paste(path, "/utils/install_cran.r", sep=""))
source(paste(path, "/utils/rng.r", sep=""))

# Simulator of constant product AMM (Uniswap V1/V2) 
# Formulas: 
# x * y = k
# Original whitepaper https://hackmd.io/@HaydenAdams/HJ9jLsfTz

# Initial system variables
x = 60000        # Initial DAI liquidity
y = 20           # Initial ETH liquidity
k = x * y        # k as per Uniswap formula
P = x / y        # Initial price of y in terms of x
n = 5000         # Number of trades simulated
yReq = 0;        # Computed y required to meet k
minP = 3000      # Default minimum price
maxP = 4000      # Default maximum price
volumeDAI = 0    # Volume of DAI traded
feeRate = 0.003  # Fee rate
plot = FALSE

# Command line arguments
args = commandArgs(trailingOnly=TRUE)

if (length(args)==1) {
  n = strtoi(args[1], base = 0L)
} else if (length(args)==4) {
  n = strtoi(args[1], base = 0L)
  minP = strtoi(args[2], base = 0L)
  maxP = strtoi(args[3], base = 0L)
  plot = strtoi(args[4], base = 0L)
} 

# Initial state as vector of x, y, k and initial price P
initialState <- c(x, y, k, P)

# Generate matrix from initial state
mat <- matrix(initialState, byrow = TRUE, nrow = n, ncol = length(initialState))

# Derived from Uniswap formula
getY <- function(k,y,P) {
  numerator = sqrt(k * P)
  denominator = P - y
  y = numerator / denominator
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
        yReq = (getY(mat[r-1, 3], mat[r-1, 2], randomPrices[r]))
        mat[r, 1] = mat[r-1, 3] / yReq
        mat[r, 2] = yReq
        mat[r, 3] = yReq * mat[r-1, 3] / yReq
        mat[r, 4] = randomPrices[r]

        # Volume
        if ((mat[r, 1] -  mat[r-1, 1]) > 0) {
          volumeDAI = mat[r, 1] -  mat[r-1, 1]
        } else {
          volumeDAI = -1 * (mat[r, 1] - mat[r-1, 1]) 
        }

        # Fees calculated in terms of x
        fees = fees + (volumeDAI * feeRate); 
        # Total volume
        totalVolume = totalVolume + volumeDAI

        }
      }

# Pool balances
deltaDai = (mat[n, 1]) - x
if (x > (mat[n, 1] )) {
  deltaDai = -1 * (x - mat[n, 1] )
}

deltaEth = mat[n, 2] - y
if (y > mat[n, 2]) {
  deltaEth = -1 * (y - mat[n, 2])
}

# Impermanent loss calculation
# Value of initial position at the end of the simulation
V0 = (x * 1) + (y * randomPrices[n])  

# Actual value of position at the end of the simulation
V1 = (mat[n, 1] * 1) + (mat[n, 2] * randomPrices[n]) 

# IL as delta in portfolio value
if (V0 > V1) {
  IL = (V0 - V1)
} else {
  IL = 0
}

# IL as percentage loss
IL = (IL / V0) * 100

# Get min and max price 
minPrice = randomPrices[which.min(randomPrices)]
maxPrice = randomPrices[which.max(randomPrices)]

# Print impermanent loss
glue::glue("\n\nSimulation ran over {n} trades\n\n")

glue::glue("Current DAI balance {mat[n, 1]} ETH balance {mat[n, 2]}")
glue::glue("Min price {minPrice} max price {maxPrice} last price {randomPrices[n]}")
glue::glue("DAI delta {deltaDai} ETH delta {deltaEth} ")
glue::glue("Impermanent loss is {IL} %")
glue::glue("Fees accrued are {fees} DAI total volume {totalVolume}\n\n")

timeSeries = ts(data = randomPrices, start = 1, end = n, frequency = 1,  deltat = 1, names = )
matplot(timeSeries, type = "l")

if (plot) {
  # Plot results
  XY <- data.frame(mat)

  matplot(XY[,c(1)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
          xlab = "DAI in pool", ylab = "ETH price")

  matplot(XY[,c(2)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
          xlab = "ETH in pool", ylab = "ETH price")
}


    

       