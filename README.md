# PhoenixWebsite

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Deployment configuration

* `$ mix release.init` based on https://hexdocs.pm/distillery/getting-started.html
* Add [lib/phoenix_website/release_tasks.ex](lib/phoenix_website/release_tasks.ex) file to the repo and ensure the module name is relevant to your app `PhoenixWebsite` and the atoms mentioned in the code for it as well `phoenix_website`.
* Add [rel/commands/seed.sh](rel/commands/seed.sh) and set executable chmod for it `$ chmod a+x rel/commands/seed.sh`.
* In [rel/config.exs](rel/config.exs) read Erlang Cookie from ENV and add seed command and plugin LinkConfig.
  ```
  environment :prod do
    set include_erts: true
    set include_src: false
    # add below 3 lines instead of fixed cookie
    set cookie: Application.fetch_env!(:ieep, :erlang_magic_cookie)
    set commands: [
      "seed": "rel/commands/seed.sh",
    ]
    plugin Releases.Plugin.LinkConfig
  end
  ```

## Tips

* `$ mix phx.gen.secret` can generate secret that can be used for `cookie`.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
