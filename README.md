# driverboy-demo

Demo ROM for [driverboy]

## Setting up

Make sure a few things are installed:

- [RGBDS], at least version 0.7.0.
- A [Nim] compiler (for [tbc], which we use for the microgames).

> [!IMPORTANT]
> On Windows, you must use [WSL], [MSYS2], or [Cygwin].

## Compiling

Simply open you favorite command prompt / terminal, place yourself in this directory (the one this README is located in), and run the command `./do`.
This should create a bunch of things, including the output in the `bin` directory.

Pass the `-j <N>` flag to `./do` to build more things in parallel, replacing `<N>` with however many things you want to build in parallel; your number of (logical) CPU cores is often a good pick (so, `-j 8` for me), run the command `nproc` to obtain it.

If you get errors that you don't understand, try running `redo clean`.
If that gives the same error, try deleting the `bin` and `obj` directories.
If that still doesn't work, feel free to ask for help.

## Contributing

This project's build system is [Redo]; `./do` is sufficient for people only looking to build this project, but *always* rebuilds everything.
It is advisable to use Redo, or one of [the alternative implementations](//news.dieweltistgarnichtso.net/bin/redo-sh.html#implementation-comparison) ([here's another, unlisted one][redo-rs]) if intending to hack on this.

## License

This project is licensed under the Mozilla Public License 2.0 (see the LICENSE file).

[driverboy]: //github.com/ISSOtm/driverboy
[RGBDS]: //github.com/gbdev/rgbds
[Nim]: //nim-lang.org
[WSL]: //learn.microsoft.com/en-us/windows/wsl
[MSYS2]: //msys2.org/
[Cygwin]: //www.cygwin.com/install.html
[Redo]: //redo.rtfd.io/
[redo-rs]: //github.com/zombiezen/redo-rs/#installation
