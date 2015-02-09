# Redmine EVM

V1.0.0 (4-Jul-2014)


## About

This plugin uses EVM (Earned Value Management) a project monitoring methodology that measures the current progress of the project. By setting a project baseline it generates three key metrics, the planned value, actual cost and earned value and with these the plugin renders a line chart and performance indicators.

With this plugin you can:
* Manage and keep an history of baselines.
* Get information about the current project performance.
* Predict the project final cost and duration.

## Installation

1. Download tarball
2. cd {redmine_root}/plugins/; mkdir redmine_evm
3. Extract files to {redmine_root}/plugins/redmine_evm/
4. rake redmine:plugins:migrate NAME=redmine_evm RAILS_ENV=production

## How to use

First make sure that the project planning is complete, then set up a baseline under the "Baselines" tab in the project settings.

![redmine_evm screenshot](https://raw.githubusercontent.com/imaginary-cloud/redmine_evm/master/screenshot.png)

## Keywords

EVM, CPI, SPI, Earned Value Management, Baseline, Forecast, Redmine, Plugin

## Support

Support will only be given to the following versions or above:

* Redmine version                2.5.0.stable
* Ruby version                   1.9.2-p328
* Rails version                  3.2.17

## License

Copyright © 2014 ImaginaryCloud, imaginarycloud.com. This plugin is licensed under the MIT license.

