# lyz-nf: Lab Monitor Program

Workflow for automatically syncing lab directories, running miscellaneous tasks, etc..

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

You can also configure `crontab` yourself manually to run the program as per your use case. An example `crontab` command might look like:

```
0 12,23 * * * . /home/kellys04/.bash_profile; cd /production/lyz-nf; make run >/dev/null 2>&1
```

to run the program at 12:00 and 23:00 every day.

## Configuration

External configurations for your tasks can be saved in a file such as `config.json` (example included). You can direct the program to use this file by including it under the Makefile variable `CONFIG`. Example:

```
make run CONFIG=/path/to/config.json
```

- NOTE: For my convenience, the path to the config I use on my system is currently hard-coded into `Makefile`. You can modify this for your usages instead.

# Notes

- To ensure that multiple instances of `lyz-nf` are not running simultaneously (e.g. started by `cron` automatically before the previous finished), a lock file is used to prevent task execution by other instances of the program.

- `lyz-nf` is configured to automatically send email output with execution summary information, configured as `<system username>@nyumc.org`. You can provide your own email address with the `emailFrom` and `emailTo` Nextflow arguments. This, along with other Nextflow parameters, can be passed via the Makefile with the `EP` argument like this:

```
make run EP='--emailFrom bob@server.com --emailTo mary@server.com'
```

# Software

- Java 8 (for Nextflow)

Tested on CentOS 6, should work on any Nextflow-compatible system with `bash`, `make`, and `cron`.
