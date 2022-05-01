
# Command line arguments
args = commandArgs(trailingOnly=TRUE)

n = 5000        # Number of trades
minP = 2000     # Default minimum price
maxP = 3000     # Default maximum price

if (length(args)==1) {
  n = strtoi(args[1], base = 0L)
} else if (length(args)==4) {
  n = strtoi(args[1], base = 0L)
  minP = strtoi(args[2], base = 0L)
  maxP = strtoi(args[3], base = 0L)
  plot = strtoi(args[4], base = 0L)
} 

# Generate random prices
randomPrices <- runif(n = n, min = minP, max = maxP)


minP = 260      # Default minimum price
maxP = 390      # Default maximum price

# Generate random prices
# SNX/ETH
randomPricesA <- runif(n = n, min = minP, max = maxP)
# SNX/USD
randomPricesB <- runif(n = n, min = 9, max = 15)