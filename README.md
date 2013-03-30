gopkg
=====

`gopkg` facilitates versioning of [Go](http://golang.org) packages - as a web service! - based on git tags.


### Benefits

 * Non-invasive, works with `go get`
 * No metadata file in packages - just `git tag`
 * Totally optional - if you don't like it, don't use it.  If you use a package
   that in turn uses it, you'll notice nothing more than `go get` downloading a
   few longish package names.
 * Mostly decentralized.  No persistent copy of any package, nor any index of
   packages, is kept.  The `gopkg` app is centralized if you choose to use it -
   but it's AGPL and deploys in a single command, so feel free to host your own.  
 * Only need to change import statement; all other code remains the same.
 * Doesn't care about or attempt to understand version numbering schemes

### Drawbacks

 * 'go get' emits a complaint, because it tries (and fails) to connect with
   git:// before trying (and succeeding with) http://
 * Long, slightly repetitive import names
 * Can't push changes back to tagged repos (this may be a benefit)

### Notes

 * Currently `gopkg` is a Ruby application based on
   [grack](https://github.com/schacon/grack), because there is no Git HTTP
   server implementation in Go.  
 * It only supports github right now, but would not be hard to add other VCS.  
 * No effort is made at sane caching - repos are created in  temp space, which
   is not persistent on heroku.  Does not attempt to clean up repos - but does
   recreate them if they are >120 seconds old.
 * Might have performance issues for very large repos?


## Install

An instance of `gopkg` is currently running at `gopkg.herokuapp.com`.  It's
also easy to deploy your own instance on [Heroku](http://heroku.com):

```bash
$ ./heroku.sh your_app_name
```


## Usage

Let's say you want to use a tag named 'sometag' from a repo named
'github.com/someuser/somerepo'.  You would just update your import statement to
the following, and run 'go get' as normal:

``` go
import (
    "gopkg.herokuapp.com/github.com/someuser/somerepo/tag/sometag/somerepo.git"
)
```

When `go get` clones what it thinks of as an ordinary repo, the `gopkg` app
will init a new repo, fetch data from github, merge the specified tag into
master, and serve up this new repo to the client.  This way we can install a
package locked to a particular tag without modifying go get's behavior.



## License


This is Free Software, released under the terms of the AGPL v3.  See
www.gnu.org/licenses/agpl-3.0.html for details.
