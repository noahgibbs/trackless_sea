# Trackless Sea

"If you want to build a ship, don’t drum up the men to gather wood,
divide the work, and give orders. Instead, teach them to yearn for the
vast and endless sea." - apocryphal, often credited to Antoine de
Saint-Exupéry

Trackless Sea is meant to be a playground built on the Demiurge HTML
game engine. See Demiurge and Demiurge-Createjs for more details about
the gritty software chunks that make Trackless Sea work.

## Start the Server and Your First Security Certificate

    $ scripts/start_server

Setting up a security certificate for local use can be quite
painful. Unfortunately, I don't want to default to an insecure
configuration and then have people deploy that in production.

The first time you run start_server it'll make you a new certificate
and put it where Trackless will use it. But Chrome is still likely to
complain loudly about using a self-signed certificate.

You have two choices here.

First, you can configure Chrome to allow insecure certs for
localhost - it's a good choice for web developers and may help with
projects other than Trackless as well! Here's a StackOverflow question
discussing the problem, including details about the second solution
below:
"https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate".
Quoted from that question, your solution one is to put
"chrome://flags/#allow-insecure-localhost" in the top bar in Chrome,
then hit "Enable" on the setting that shows up in yellow highlight
text.

Or second, you can instead configure your host to trust the
certificate you're using. Keychain Access is the app that does that --
you can find it under the Utils folder under Applications by
default. You can't modify System Root certificates any more, so you'll
need to drag trackless_server.crt (or a copy) into the window. Then
"Get Info" on it (it'll show up as localhost.ssl), pull open the
"Trust" tab and mark it as "Trust Always".

## Can I Skip the Security Certificate Stuff?

It is possible to set things up with really cruddy security for local
development to avoid having to set up a local self-signed certificate,
even though I've made the start_server script already create one for
you. You *will* have to either set up Chrome to allow self-signed
local certificates or make your host trust your certificate. And maybe
that's a smaller problem for you than leaking everybody's password and
causing a huge, legally-actionable data breach because you normally
run insecure and you forgot to change that on the server for just this
one deploy, or your deploy was done by somebody who didn't know that
step.

Awesome.

In that case, all you need to do is change index.html and the
start_server script to the wrong, bad configuration. I won't tell you
how, even though it's very easy. Later, I may add security checks to
index.html and/or the libraries as well, even though those will be
slightly more annoying for you to disable. Why? Because I want a
horrific security breach to be slightly *harder* than no horrific
security breach. And setting up certificates is currently a really
awful pain. Also, if setting up certs gets easier I want my stuff to
default in the right direction then too.

Is there a time deploying without a security certificate is warranted?
Sure. If you set a particular application up with *no* password and
*no* personally-identifying info for a particular application then you
don't much care if people see the random packets being sent. It's
basically all public anyway. In that case and ONLY in that case, feel
free to disable the security.

That's not how Trackless Sea works, though. If you disable the
security and then try to get people to use a password they remember
(usually their real and only one) and then leak that, you're a
terrible person and you deserve whatever horrible thing happens to
you.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/noahgibbs/trackless_sea. This project is intended
to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor
Covenant](http://contributor-covenant.org) code of conduct. See
CODE_OF_CONDUCT.md.

## References, Influences and Sources of Media

* OpenGameArt and the Liberated Pixel Cup
* Source of Tales
* The Tiled Map Editor
* The Mana World - https://github.com/themanaworld
* The Mana Project
* Evol Online

## License

The code is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
