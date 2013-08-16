Ruby Secret Service
===================

Native Ruby bindings for [freedesktop.org's Secret Service](http://standards.freedesktop.org/secret-service/).  Uses [ruby-dbus](https://github.com/mvidner/ruby-dbus).

##Usage
```
require "secret_service"

ss = SecretService.new

# create a secret in the default collection
name = "my github password"
secret = "s00p3r-s33|<r1+"

ss.collection.create_item(name, secret)

# and read it back
round_trip_secret = ss.collection.get_secret(name)
round_trip_secret == secret || raise "secret reading failed"

# create new collections!
other_coll_name = "other keyring"
other_name = "my heroku password"
other_secret = "1m s00 l33t"
ss.create_collection(other_coll_name)

ss.collection(other_coll_name).create_item(other_name, other_secret)
round_trip_other = ss.collection(other_coll_name).get_secret(other_name)
round_trip_other == other_secret || raise "can't read alt collection secret"
```

## Caveats

   * Both KWallet and GNOME Keyring _REQUIRE_ the use of X11 to prompt
   the user to decrypt ("unlock") the keychain.  While you can use
   this in a terminal-only environment (e.g., ssh'd in from a
   desktop/laptop without X11), you're going to get errors about
   having to unlock collections, but there is literally no way in the
   spec to pass the decryption password over DBus.
   * This is written chiefly to provide a programmatic access to
   Secret Service for one specific program - Heroku Toolbelt.  While
   there's some basic support for multiple collections and
   locking/unlocking, if you're doing anything moderately complex,
   you're potentially better off [doing this in Python](https://bitbucket.org/kang/python-keyring-lib/overview)

