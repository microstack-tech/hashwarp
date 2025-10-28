# Hashwarp

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)][Gitter]
[![Releases](https://img.shields.io/github/downloads/microstack-tech/hashwarp/total.svg)][Releases]

> Parallax miner with OpenCL and stratum support

**Hashwarp** is a Parallax GPU miner: with Hashwarp you can mine Parallax which relies on the XHash Proof of Work algorithm. Hashwarp is a fork of Ethminer which originates from [cpp-ethereum] project (where GPU mining has been discontinued) and builds on the improvements made in [Genoil's fork]. See [FAQ](#faq) for more details.

## Features

* OpenCL mining
* Nvidia CUDA mining
* realistic benchmarking against arbitrary epoch/DAG/blocknumber
* on-GPU DAG generation (no more DAG files on disk)
* stratum mining without proxy
* OpenCL devices picking
* farm failover (getwork + stratum)

## Table of Contents

* [Install](#install)
* [Usage](#usage)
  * [Examples connecting to pools](#examples-connecting-to-pools)
* [Build](#build)
  * [Continuous Integration and development builds](#continuous-integration-and-development-builds)
  * [Building from source](#building-from-source)
* [Maintainers & Authors](#maintainers--authors)
* [Contribute](#contribute)
* [F.A.Q.](#faq)

## Install

[![Releases](https://img.shields.io/github/downloads/microstack-tech/hashwarp/total.svg)][Releases]

Standalone **executables** for *Linux*, *macOS* and *Windows* are provided in
the [Releases] section.
Download an archive for your operating system and unpack the content to a place
accessible from command line. The ethminer is ready to go.

| Builds | Release | Date |
| ------ | ------- | ---- |
| Last   | [![GitHub release](https://img.shields.io/github/release/microstack-tech/hashwarp/all.svg)](https://github.com/microstack-tech/hashwarp/releases) | [![GitHub Release Date](https://img.shields.io/github/release-date-pre/microstack-tech/hashwarp.svg)](https://github.com/microstack-tech/hashwarp/releases) |
| Stable | [![GitHub release](https://img.shields.io/github/release/microstack-tech/hashwarp.svg)](https://github.com/microstack-tech/hashwarp/releases/latest) | [![GitHub Release Date](https://img.shields.io/github/release-date/microstack-tech/hashwarp.svg)](https://github.com/microstack-tech/hashwarp/releases/latest) |

## Usage

The **hashwarp** is a command line program. This means you launch it either
from a Windows command prompt or Linux console, or create shortcuts to
predefined command lines using a Linux Bash script or Windows batch/cmd file.
For a full list of available command, please run:

```sh
hashwarp --help
```

### Examples connecting to pools

Check our [samples](docs/POOL_EXAMPLES_ETH.md) to see how to connect to different pools.

## Build

### Continuous Integration and development builds

| CI            | OS            | Status  | Development builds |
| ------------- | ------------- | -----   | -----------------  |
| [Travis CI]   | Linux, macOS  | [![Travis CI](https://img.shields.io/travis/microstack-tech/hashwarp/master.svg)][Travis CI]    | ✗ No build artifacts, [Amazon S3 is needed] for this |
| [AppVeyor]    | Windows       | [![AppVeyor](https://img.shields.io/appveyor/ci/microstack-tech/hashwarp/master.svg)][AppVeyor] | ✓ Build artifacts available for all PRs and branches |

The AppVeyor system automatically builds a Windows .exe for every commit. The latest version is always available [on the landing page](https://ci.appveyor.com/project/microstack-tech/hashwarp) or you can [browse the history](https://ci.appveyor.com/project/microstack-tech/hashwarp/history) to access previous builds.

To download the .exe on a build under `Job name` select the CUDA version you use, choose `Artifacts` then download the zip file.

### Building from source

See [docs/BUILD.md](docs/BUILD.md) for build/compilation details.

## License

Licensed under the [GNU General Public License, Version 3](LICENSE).

## F.A.Q

### Why is my hashrate with Nvidia cards on Windows 10 so low?

The new WDDM 2.x driver on Windows 10 uses a different way of addressing the GPU. This is good for a lot of things, but not for Parallax mining.

* For Kepler GPUs: I actually don't know. Please let me know what works best for good old Kepler.
* For Maxwell 1 GPUs: Unfortunately the issue is a bit more serious on the GTX750Ti, already causing suboptimal performance on Win7 and Linux. Apparently about 4MH/s can still be reached on Linux, which, depending on the Parallax price, could still be profitable, considering the relatively low power draw.
* For Maxwell 2 GPUs: There is a way of mining Parallax at Win7/8/Linux speeds on Win10, by downgrading the GPU driver to a Win7 one (350.12 recommended) and using a build that was created using CUDA 6.5.
* For Pascal GPUs: You have to use the latest WDDM 2.1 compatible drivers in combination with Windows 10 Anniversary edition in order to get the full potential of your Pascal GPU.

### Why is a GTX 1080 slower than a GTX 1070?

Because of the GDDR5X memory, which can't be fully utilized for Parallax mining (yet).

### Are AMD cards also affected by slowdowns with increasing DAG size?

Only GCN 1.0 GPUs (78x0, 79x0, 270, 280), but in a different way. You'll see that on each new epoch (30K blocks), the hashrate will go down a little bit.

### What are the optimal launch parameters?

The default parameters are fine in most scenario's (CUDA). For OpenCL it varies a bit more. Just play around with the numbers and use powers of 2. GPU's like powers of 2.

### What does the `--cuda-parallel-hash` flag do?

[@davilizh](https://github.com/davilizh) made improvements to the CUDA kernel hashing process and added this flag to allow changing the number of tasks it runs in parallel. These improvements were optimised for GTX 1060 GPUs which saw a large increase in hashrate, GTX 1070 and GTX 1080/Ti GPUs saw some, but less, improvement. The default value is 4 (which does not need to be set with the flag) and in most cases this will provide the best performance.

### CUDA GPU order changes sometimes. What can I do?

There is an environment var `CUDA_DEVICE_ORDER` which tells the Nvidia CUDA driver how to enumerates the graphic cards.
The following values are valid:

* `FASTEST_FIRST` (Default) - causes CUDA to guess which device is fastest using a simple heuristic.
* `PCI_BUS_ID` - orders devices by PCI bus ID in ascending order.

To prevent some unwanted changes in the order of your CUDA devices you **might set the environment variable to `PCI_BUS_ID`**.
This can be done with one of the 2 ways:

* Linux:
  * Adapt the `/etc/environment` file and add a line `CUDA_DEVICE_ORDER=PCI_BUS_ID`
  * Adapt your start script launching hashwarp and add a line `export CUDA_DEVICE_ORDER=PCI_BUS_ID`

* Windows:
  * Adapt your environment using the control panel (just search `setting environment windows control panel` using your favorite search engine)
  * Adapt your start (.bat) file launching hashwarp and add a line `set CUDA_DEVICE_ORDER=PCI_BUS_ID` or `setx CUDA_DEVICE_ORDER PCI_BUS_ID`. For more info about `set` see [here](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/set_1), for more info about `setx` see [here](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/setx)

### Insufficient CUDA driver

```text
Error: Insufficient CUDA driver: 9010
```

You have to upgrade your Nvidia drivers. On Linux, install `nvidia-396` package or newer.

[Amazon S3 is needed]: https://docs.travis-ci.com/user/uploading-artifacts/
[AppVeyor]: https://ci.appveyor.com/project/microstack-tech/hashwarp
[cpp-ethereum]: https://github.com/ethereum/cpp-ethereum
[Genoil's fork]: https://github.com/Genoil/cpp-ethereum
[Gitter]: https://gitter.im/microstack-tech/hashwarp
[Releases]: https://github.com/microstack-tech/hashwarp/releases
[Travis CI]: https://travis-ci.org/microstack-tech/hashwarp
