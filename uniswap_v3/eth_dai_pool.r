#!/usr/bin/env Rscript
library(glue)


getLiqX <- function(x, P, Pb) {
  numerator = sqrt(P) * sqrt(Pb)
  denominator = sqrt(Pb) - sqrt(P)
  L = x * (numerator / denominator)
}

getLiqY <- function(y, P, Pa) { 
  denominator = sqrt(P) - sqrt(Pa)
  Ly = y / denominator
}

getPa <- function(x, y, P, Pb) {
  firstTerm = (y / (sqrt(Pb) * x)) + sqrt(P)
  secondTerm = y / (sqrt(P) * x)
  Pa = (firstTerm - secondTerm) ** 2
}

getx <- function(L, P, Pb) {
  numerator = sqrt(Pb) - sqrt(P)
  denominator = sqrt(P) * sqrt(Pb)
  xNew = L * (numerator / denominator)
}

gety <- function(L, P, Pa) {
  yNew = (sqrt(P) - sqrt(Pa))
  print(glue::glue("Got L {L} yNew {yNew}"))
  yNew = yNew * L
}

# Simulator of constant product AMM with concentrated liquidity (Uniswap V3) 
# Formulas taken from: 
# https://atiselsts.github.io/pdfs/uniswap-v3-liquidity-math.pdf

# Initial system variables
x = 2           # Initial ETH liquidity
y = 4000        # Initial DAI liquidity
k = x * y       # k as per Uniswap formula
P = y / x       # Initial price of y in terms of x
n = 5000        # Number of trades simulated
yReq = 0        # Computed y required to meet k
minP = 2000     # Default minimum price
maxP = 3000     # Default maximum price
volumeDAI = 0   # Volume of DAI traded
plot = FALSE

# Compute min P
minP = getPa(x, y, P, maxP)

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

# Generate random prices
randomPrices <- runif(n = n, min = minP, max = maxP)


fees = 0
totalVolume = 0

# Simulate trades
for (r in 1:nrow(mat))   
  for (c in 1:ncol(mat))
  # initial state
  if (r == 1) {
    mat[r, 1] = x
    mat[r, 2] = y
    mat[r, 3] = x * y
    mat[r, 4] = P
    Pa = getPa(mat[r, 1], mat[r, 2], P, maxP)
  } else {  
    
    if (c == 2) {
      
      if (r == 2) {
        currentPrice = P
      } else {
        currentPrice = mat[r-1, 4]
      }

      randomPrice = randomPrices[r]

      Lx = getLiqX(mat[r-1, 1], currentPrice, maxP)
      Ly = getLiqY(mat[r-1, 2], currentPrice, Pa)

      liq = c(Lx, Ly)
      L = liq[which.min(liq)]
 
      xNew = getx(L, randomPrice, maxP)
      yNew = gety(L, randomPrice, Pa)
 
      mat[r, 1] = xNew
      mat[r, 2] = yNew
      mat[r, 3] = x * y
      mat[r, 4] = randomPrice      

    }

  }

print(mat)
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
V0 = (x * randomPrices[n]) + (y * 1)  

# Actual value of position at the end of the simulation
V1 = (mat[n, 1] * randomPrices[n]) + (mat[n, 2] * 1) 

# IL as delta in portfolio value
IL = (V1 - V0)

# IL as percentage loss
IL = (IL / V0) * 100

# Get min and max price 
minPrice = randomPrices[which.min(randomPrices)]
maxPrice = randomPrices[which.max(randomPrices)]

# Print impermanent loss
glue::glue("\n\nSimulation ran over {n} trades\n\n")

glue::glue("Current DAI balance {mat[n, 2]} ETH balance {mat[n, 1]}")
glue::glue("Min price {minPrice} max price {maxPrice} last price {randomPrices[n]}")
glue::glue("ETH delta {deltaDai} DAI delta {deltaEth} ")
glue::glue("Impermanent loss is {IL} %")
glue::glue("Original position value {V0} Current position value {V1}")

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


    

       