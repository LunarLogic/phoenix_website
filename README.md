# PhoenixWebsite

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Deployment configuration

Here is the list of steps you need to follow to configure a fresh Phoenix Framework app in order compile it on Build Server and later deploy to App Server.
You can find here relevant [Ansible playbooks to provision Build Server and App Server](https://github.com/LunarLogic/ansible-elixir-playbooks).

* Add [distillery](https://github.com/bitwalker/distillery) (release manager) in `mix.exs` and run `$ mix deps.get`.

  ```elixir
  defp deps do
    [{:distillery, "~> 1.4", runtime: false}]
  end
  ```

* Generate a new [rel/config.exs](rel/config.exs) file with `$ mix release.init`. You can learn more here if you like https://hexdocs.pm/distillery/getting-started.html
* Add [lib/phoenix_website/release_tasks.ex](lib/phoenix_website/release_tasks.ex) file to the repo and ensure the module name is relevant to your app `PhoenixWebsite` and the atoms mentioned in the code for it as well `:phoenix_website`.
* Add [rel/commands/seed.sh](rel/commands/seed.sh) and set executable chmod for it `$ chmod a+x rel/commands/seed.sh`.
* In [rel/config.exs](rel/config.exs) file we should read Erlang Cookie from ENV and add seed command with plugin LinkConfig.

  ```elixir
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

* Add [edelivery](https://github.com/edeliver/edeliver) (build and deploy Elixir app) in `mix.exs` and run `$ mix deps.get`.

  ```elixir
  def application do
    [
      mod: {PhoenixWebsite.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        # Add edeliver to the END of the list
        :edeliver,
      ]
    ]
  end
  ```

  ```elixir
  defp deps do
    [
      ...
      # add edeliver here
      {:edeliver, "~> 1.4.3"},
      {:distillery, "~> 1.4", runtime: false},
    ]
  end
  ```

* Add in `.gitignore` the line `.deliver/releases/`.
* Add at the very end of the [config/prod.exs](config/prod.exs) file:

  ```elixir
  # We don't want to use prod.secret.exs
  #
  # Instead we will compile the keys but with example values FILL_IN_HERE
  # that will be manually replaced later in /home/phoenix/phoenix_website/phoenix_website.config on the App Server.
  #
  # Thanks to that values won't be compiled into our release package.
  # In result we will be able to deploy compiled release package to multiple environments like staging/production.
  # (You don't have to compile app separatly for the staging and production as it was with using prod.secret.exs approach)
  config :phoenix_website, PhoenixWebsiteWeb.Endpoint,
    secret_key_base: "FILL_IN_HERE",
    # we use hardcoded port and it's set in Ansible playbooks
    # roles/phoenix-app/0.0.1/templates/nginx.j2
    http: [port: 8888]

  # Configure your database
  config :phoenix_website, PhoenixWebsite.Repo,
    adapter: Ecto.Adapters.Postgres,
    username: "FILL_IN_HERE",
    password: "FILL_IN_HERE",
    database: "FILL_IN_HERE",
    pool_size: 15

  config :phoenix_website,
    # Nodes connecting to each other are required to prove that they possess a shared secret, called a "cookie". This is
    # mostly aimed at ensuring that different Erlang clusters on the same network don't accidentally merge. All Erlang
    # nodes in a cluster trust each other completely. Any node in the cluster can run any code on any of the other nodes.
    # This must be atom hence colon sign before value.
    # You can generate new erlang_magic_cookie with: `mix phx.gen.secret`.
    erlang_magic_cookie: :"FILL_IN_HERE",
  ```
* Create [bin/deploy](bin/deploy) with executable chmod `$ chmod a+x deploy` and update there `HOST` to your staging/production servers.
* Create [bin/restart](bin/restart) with executable chmod `$ chmod a+x deploy`



## Tips

* `$ mix phx.gen.secret` can generate secret that can be used for `cookie` or for `secret_key_base` in `config/prod.exs`.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
