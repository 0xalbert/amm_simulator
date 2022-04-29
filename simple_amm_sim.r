#!/usr/bin/env Rscript
library(glue)

# Simulator of constant product AMM (Uniswap V1/V2) 
# Formulas: 
# x * y = k
# Original whitepaper https://hackmd.io/@HaydenAdams/HJ9jLsfTz

# Initial system variables
x = 60000   # Initial DAI liquidity
y = 20      # Initial ETH liquidity
k = x * y   # k as per Uniswap formula
P = x / y   # Initial price of y in terms of x
n = 5000     # Number of trades simulated
xReq = 0;   # Computed x

# Initial state as vector of x, y, k and price
initialState <- c(x, y, k, P)

# Generate matrix from initial state
mat <- matrix(initialState, byrow = TRUE, nrow = n, ncol =4)

# Generate random prices
randomPrices <- runif(n = n, min = 3000, max = 4000)

# Derived from Uniswap formula
getX <- function(k,y,P) {
  numerator = sqrt(k * P)
  denominator = P - y
  x = numerator / denominator
}

# Simulates trades
for (r in 1:nrow(mat))   
  for (c in 1:ncol(mat))
  # Skip the first line as it is the initial state
    if (r > 1) {
      if (c == 2)
        # Compute x based on k, y and P 
        xReq = ( getX(mat[r-1, 3], mat[r-1, 2], randomPrices[r]))
        mat[r, 1] = mat[r-1, 3] / xReq
        mat[r, 2] = xReq
        mat[r, 3] = xReq * mat[r-1, 3] / xReq
        mat[r, 4] = randomPrices[r]
      }

# Impermanent loss calculation
# Value of initial position at the end of the simulation
V0 = (x * 1) + (y * randomPrices[n])  

# Actual value of position at the end of the simulation
V1 = (mat[n, 1] * 1) + (mat[n, 2] * randomPrices[n]) 

# IL as delta in portfolio value
IL = (V0 - V1)

# IL as percentage loss
IL = (IL / V0) * 100

# Get min and max price 
minPrice = randomPrices[which.min(randomPrices)]
maxPrice = randomPrices[which.max(randomPrices)]

# Print impermanent loss
glue::glue("Simulation ran over {n} cycles")
glue::glue("Min price {minPrice} max price {maxPrice}")
glue::glue("Current DAI balance {mat[n, 1]} ETH balance {mat[n, 2]}")
glue::glue("Impermanent loss is {IL} %")

#print(mat)

# Plot results
XY <- data.frame(mat)

matplot(XY[,c(1)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
        xlab = "DAI in pool", ylab = "ETH price")

matplot(XY[,c(2)], XY[,c(4)], type = "p", lty = 1, col = c("red", "green"), pch = 1,
        xlab = "ETH in pool", ylab = "ETH price")

    

       