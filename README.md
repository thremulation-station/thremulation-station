# Thremulation Station

<br>
<p align="center">
<img src="images/ts-logo-temp.png" width="30%" alt="">
</p>
<br>

<h2 align="center"><b>Threat emulation and detection for your laptop</b></h2>

<p align="center">
   Collection of open source tools working together to enable a reasonably capable machine to serve as a local cyber range.
</p>

<p align="center"><b>
    <a href="https://thremulation.io">Thremulation.io</a> |
    <a href="https://github.com/thremulation-station/thremulation-station">Github</a> |
    <a href="https://twitter.com/thremulation">Twitter</a> |
    <a href="https://discord.gg/mtNXN4QjHh">Discord</a>
    <br /><br />
</b></p>


<hr />
<br>
Thremulation Station is an approachable small-scale threat emulation and detection range. It leans on Atomic Red Team for ***emulating*** threats, and the Elastic Endpoint Agent for ***detection***.

!!! info "TL;DR"
    If you're ready to skip the reading and jump into things, head to the [Quickstart / Installation](/quickstart/installation.md) section.


## Project Goals

Our goal from the very beginning has been to provide the following:

1. lightweight range that can operate on a laptop with a _minimum_ of 4 threads and 8G of RAM
1. support the big 3 host operating systems (initial linux path is RHEL-based)
1. present users a smooth path to execute threats and observe them with Elastic 
1. provide a singular TUI (Station Control) that can be used to manage all aspects

!!! note "Note"
    You'll be introduced to `./stationctl` early in the [Getting Started](/getting-started/deployment/#introduction-to-station-control) section and use it to deploy boxes, get status, manage and clear data, and much more. A full reference guide is located at [support / stationctl](/support/stationctl.md).


## What are the requirements?

Our goal from the beginning has been to provide a small and useful range that can operate on a laptop with a minimum of ***4 threads available*** and ***8G of RAM***. Obviously the more the better, but the minimum specs with get the job done.  


## Who was it built for?

This project has many practical use cases, and we're excited to see how the community uses TS. Here are a few examples that we had in mind while creating the project.

- Cyber defense education
- Generating training data
- Threat intelligence training
- Writing and validating [detection rules](https://github.com/elastic/detection-rules)
- Writing and testing threat [tactics and techniques](https://attack.mitre.org/tactics/enterprise/)


## How does it work?

A simple user experience is the priority. A brief usage overview looks like this:

1. Clone the project
1. Use the CLI to perform setup
1. Use the CLI to deploy your range
1. Reference the User Guide at [thremulation.io]
1. Use the CLI to perform cleanup / reset tasks
1. Use the CLI to perform setup

> Full details on usage begin in the documentation [Getting Started Guide](getting-started/index.md).


## How can I help?

We welcome contributions! But what if you don't know what to do, or how to start? Check out the [Contribution Section](CONTRIBUTING.md). If you're lost, please ask and we can help guide you to the right place to get started.
