# SSC.Nob

*SSC.Nob* is a simple bot I wrote for the game [Subspace Continuum](https://store.steampowered.com/app/352700/Subspace_Continuum/), just for fun!

*SSC* stands for Subspace Continuum. *Nob* stands for Noble One Bot. Noble One (or Nob) is meant to be a gender-neutral version of King of the Hill.

Subspace Continuum links:
- [Windows / Linux (with wine)](http://subspace-continuum.com/trackdownload.php?type=win)
- [macOS](http://subspace-continuum.com/trackdownload.php?type=mac)
- [UDP Game Protocol [wiki]](http://wiki.minegoboom.com/index.php/UDP_Game_Protocol)

It's **not** a server bot and can be run & used by any user in any zone & arena.

It's currently **not** a [UDP packet](https://www.twcore.org/SubspaceProtocol/) bot. It simply reads a log file for input and uses Java's Robot class for output. For SSC.Nob2 or something, I'd like to read/write packets, but will probably never make it.

## Running

JRuby is required. [ruby-install](https://github.com/postmodern/ruby-install) & [chruby](https://github.com/postmodern/chruby) make this easy:

```
$ ruby-install jruby
$ chruby jruby
$ gem install bundler
```

It's pretty janky at the moment, but works.

Run the app with JRuby:

```
$ bundler install
$ ruby ./lib/ssc.nob.rb
```

**Note:** that's *bundler* with an *r*, not *bundle* (which doesn't work with JRuby).

You'll be asked a couple of questions. Then input the `run` command.

Current Subspace configuration:
- In *Key Defs*, set the *Msg* key to *TAB*.
- Once logged in...
    - do `?log nob.log`
    - do `?kill` until kill messages are set to display in the chat
    - do `?namelen=24`

Now to run *Nob*, private message yourself `!nob.start`. Private message yourself `!nob.stop` to stop it.

[![asciinema demo](https://asciinema.org/a/326310.png)](https://asciinema.org/a/326310)

## License

[GNU GPL v3+](LICENSE.txt)

> SSC.Nob (<https://github.com/esotericpig/ssc.nob>)  
> Copyright (c) 2020 Jonathan Bradley Whited (@esotericpig)  
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
