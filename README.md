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

Standalone **executables** for *Windows* and *Linux* are provided in
the [Releases] section.
Download an archive for your operating system and unpack the content to a place
accessible from command line. The Hashwarp is ready to go.

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
| [AppVeyor]    | Windows, Linux | [![AppVeyor](https://img.shields.io/appveyor/ci/microstack-tech/hashwarp/main.svg)][AppVeyor] | ✓ Build artifacts available for the `main` branch |

The AppVeyor system automatically builds a Windows .exe and a Linux binary for every commit in the `main` branch. The latest version is always available [on the landing page](https://ci.appveyor.com/project/microstack-tech/hashwarp) or you can [browse the history](https://ci.appveyor.com/project/microstack-tech/hashwarp/history) to access previous builds.

To download the .exe on a build under `Job name` select the CUDA version you use, choose `Artifacts` then download the zip file.

### Building from source

See [docs/BUILD.md](docs/BUILD.md) for build/compilation details.

## License

Licensed under the [GNU General Public License, Version 3](LICENSE).

[AppVeyor]: https://ci.appveyor.com/project/microstack-tech/hashwarp
[cpp-ethereum]: https://github.com/ethereum/cpp-ethereum
[Genoil's fork]: https://github.com/Genoil/cpp-ethereum
[Gitter]: https://gitter.im/microstack-tech/hashwarp
[Releases]: https://github.com/microstack-tech/hashwarp/releases
