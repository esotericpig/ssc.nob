# SSC.Nob

[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/ssc.nob)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/ssc.nob.svg)](LICENSE.txt)

*SSC.Nob* is a simple bot I wrote for the game [Subspace Continuum](https://store.steampowered.com/app/352700/Subspace_Continuum), just for fun!

*SSC* stands for Subspace Continuum. *Nob* stands for Noble One Bot. Noble One (or Nob) is meant to be a gender-neutral version of King of the Hill.

Subspace Continuum links:
- [Steam](https://store.steampowered.com/app/352700/Subspace_Continuum)
- [Linux (Lutris)](https://lutris.net/games/subspace-continuum)
- [macOS](http://subspace-continuum.com)
- [UDP Game Protocol [wiki]](http://wiki.minegoboom.com/index.php/UDP_Game_Protocol)

It's **not** a server bot and can be run & used by any user in any zone & arena.

It's currently **not** a [UDP packet](https://www.twcore.org/SubspaceProtocol) bot. It simply reads a log file for input and uses Java's Robot class for output. For SSC.Nob2 or something, I'd like to read/write packets, but will probably never make it.

## Run

### From Jar

Download the latest Jar from the *Assets* on the [Releases page](https://github.com/esotericpig/ssc.nob/releases).

Then simply run the Jar:

```
$ java -jar ssc.nob.jar
```

### From Source

JRuby is required. [ruby-install](https://github.com/postmodern/ruby-install) & [chruby](https://github.com/postmodern/chruby) make this easy:

```
$ ruby-install jruby
$ chruby jruby
```

Run the app with JRuby:

```
[jruby]$ gem install bundler
[jruby]$ bundler install
[jruby]$ ruby ./lib/ssc.nob.rb
```

**Note:** that's *bundler* with an *r*, not *bundle* (which doesn't work with JRuby).

## Setup & Demo

It's pretty janky at the moment, but works.

You'll be asked a couple of questions. Then input the `run` command.

Current Subspace configuration:
- In *Key Defs*, set the *Msg* key to *TAB*.
- Once logged in...
    - do `?log nob.log`
    - do `?kill` until kill messages are set to display in the chat
    - do `?namelen=24`

Now to run *Nob*, private message yourself `!nob.start`. Private message yourself `!nob.stop` to stop it.

[![asciicast](https://asciinema.org/a/326310.svg)](https://asciinema.org/a/326310)

## Hack

Use this Rake task for creating a Jar for release:

```
[jruby]$ bundler exec rake jar
```

There's a task for running as well:

```
[jruby]$ bundler exec rake runjar
```

Don't forget to include it in the release:

```
$ gh release create v0.0.0 pkg/*.jar pkg/*.gem
```

## License

[GNU GPL v3+](LICENSE.txt)

> SSC.Nob (<https://github.com/esotericpig/ssc.nob>)  
> Copyright (c) 2020-2021 Bradley Whited  
> 
> SSC.Nob is free software: you can redistribute it and/or modify  
> it under the terms of the GNU General Public License as published by  
> the Free Software Foundation, either version 3 of the License, or  
> (at your option) any later version.  
> 
> SSC.Nob is distributed in the hope that it will be useful,  
> but WITHOUT ANY WARRANTY; without even the implied warranty of  
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
> GNU General Public License for more details.  
> 
> You should have received a copy of the GNU General Public License  
> along with SSC.Nob.  If not, see <https://www.gnu.org/licenses/>. 
