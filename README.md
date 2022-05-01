# Simple AMM simulator

This is a simulation of a constant product automated market maker with impermanent loss calculation created using the [R language](https://www.r-project.org/). Currently covers Uniswap V2 and V3 (concentrated liquidity).

# Requirements:

R - [How to install R on Windows and Linux](https://techvidvan.com/tutorials/install-r/#:~:text=Step%20%E2%80%93%201%3A%20Go%20to%20CRAN,the%20latest%20version%20of%20R.)

Glue [CRAN](https://cran.r-project.org/web/packages/glue/index.html)

# Setup

The setup script will work only on Linux. To install R on Windows see the instructions above.

``` npm run install ``` 

# Examples

The program will run with hardcoded default parameters which can be changed as follows:

* number of trades (e.g. 500)
* price range (e.g. 3000 4000)
* plot values (1 or 0)

To run a V2 style ETH/DAI pool simulation with 500 trades, ETH/DAI range 3000-4000 and plot values:

``` npm run v2_ethdai 500 3000 4000 1```

To run a V2 style SNX/ETH pool simulation with 500 trades, SNX/ETH range 200-300 and plot values:

``` npm run v2_snxeth 200 300 600 1```

To run a V3 style ETH/DAI pool simulation with 500 trades, ETH/DAI range 3000-4000 and plot values:

``` npm run v3_ethdai 500 3000 4000 1```


Plotting values will generate a pdf file.