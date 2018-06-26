# lyz-nf: Lab Monitor Program

Workflow for automatically syncing lab directories, etc..

Successor to [`lyz`](https://github.com/NYU-Molecular-Pathology/lyz), using [Nextflow](https://www.nextflow.io/) execution engine.

# Installation

Clone this repository:

```
git clone https://github.com/NYU-Molecular-Pathology/lyz-nf.git
cd lyz-nf
```

Install Nextflow in the current directory

```
make install
```

# Usage

`lyz-nf` consists of a Nextflow script (`main.nf`) which can be modified to contain any tasks you wish to execute

## Run

You can run the program with the following command:

```
make run
```

Standard Nextflow output will be saved to a timestamped subdirectory under `logs` in the current directory.

## Automation

Automated execution is accomplished with `cron`. You can configure a `crontab` entry with the following command:

```
make cron
```

This will:

- back up any existing `crontab` entries to a timestamped file in the current directory

- create a command for `crontab` to run, saved to a file in the current directory (`cron.job`)

- create a new `crontab` entry from the file `cron.job`

## Configuration

External configurations for your tasks can be saved in a file such as `config.json` (example included). You can direct the program to use this file by including it under the Makefile variable `CONFIG`. Example:

```
make run CONFIG=/path/to/config.json
```

- NOTE: For my convenience, the path to the config I use on my system is currently hard-coded into `Makefile`. You can modify this for your usages instead. 
