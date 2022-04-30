# Simple AMM simulator

This is a simple simulation of a constant product automated market maker with impermanent loss calcuation created using the R language. There are two scripts available under the ```uniswap``` subfolder:

* eth_dai_pool (Simulates a pool composed by ETH and DAI)
* snx_eth_pool (Simulates a pool composed by SNX and ETH)

Requirements:

R - [How to install R on Windows and Linux](https://techvidvan.com/tutorials/install-r/#:~:text=Step%20%E2%80%93%201%3A%20Go%20to%20CRAN,the%20latest%20version%20of%20R.)

Glue [CRAN](https://cran.r-project.org/web/packages/glue/index.html)

# Setup

The setup script will work only on Linux. To install R on Windows see the instructions above.

``` npm run install ``` 

# Examples

The program will run over a 5000 trades cycle by default but this can be changed optionally along with the following parameters:

* number of trades (e.g. 500)
* price range (e.g. 300 600) 
* plot values (0 or 1)

To run a ETH/DAI pool simulation with 500 trades and ETH/DAI range 3000-4000 and plot values:

``` npm run start_a 500 3000 4000 1```

To run a SNX/ETH pool simulation with 500 trades and SNX/ETH range 200-300 and plot values:

``` npm run start_b 200 300 600 1```

Plotting values will generate a pdf file.