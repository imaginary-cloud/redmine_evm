# Redmine EVM

V1.0.2 (19-Jun-2018)


## About

This plugin uses [EVM (Earned Value Management)](https://www.slideshare.net/GamaFranco/earned-value-management) a project monitoring methodology that measures the current progress of the project. By setting a project baseline it generates three key metrics, the planned value, actual cost and earned value and with these the plugin renders a line chart and performance indicators.

With this plugin you can:
* Manage and keep an history of baselines.
* Get information about the current project performance.
* Predict the project final cost and duration.

## Installation

1. Download tarball
2. `cd {redmine_root}/plugins/`
3. `mkdir redmine_evm`
4. Extract files to {redmine_root}/plugins/redmine_evm/
5. `rake redmine:plugins:migrate NAME=redmine_evm RAILS_ENV={Environment}`

## How to use

First make sure that the project planning is complete, then set up a baseline under the "Baselines" tab in the project settings.

![redmine_evm screenshot](https://raw.githubusercontent.com/imaginary-cloud/redmine_evm/master/screenshot.png)

## Keywords

EVM, CPI, SPI, Earned Value Management, Baseline, Forecast, Redmine, Plugin

## Support

Support will only be given to the following versions or above:

* Redmine version                2.6.10
* Ruby version                   2.2.0
* Rails version                  3.2.22

Note: Redmine 2.6.5 does not support Ruby 2.2. Redmine 2.6.6 supports it (#19652). [Link](http://www.redmine.org/projects/redmine/wiki/RedmineInstall/252#Requirements)


## License

Copyright © 2014 ImaginaryCloud, imaginarycloud.com. This plugin is licensed under the MIT license.

## About Imaginary Cloud

![Imaginary Cloud](https://s3.eu-central-1.amazonaws.com/imaginary-images/Logo_IC_readme.svg)

We apply our own Product Design Process to bring great digital products to life. Visit [our website](https://www.imaginarycloud.com) to find out about our other projects or [contact us](https://www.imaginarycloud.com/contacts) if there's an idea that you want to turn into an outstanding product, we'll take it from there!
