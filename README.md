# PhoenixWebsite

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Deployment Overview

To build and deploy the application, we use [edeliver](https://github.com/boldpoker/edeliver) with [distillery](https://github.com/bitwalker/distillery) build tool.

Here is the overview of the deployment process:

<!-- language: lang-none -->

        -----------------------                                           ---------------------------
        |                     |                                           |                         |
        |                     | -------------- (1) build ---------------> |                         |
        |                     |                                           |       build server      |
        |                     | <------- (2) copy to release store ------ |                         |
        |                     |                                           |                         |
        |   control machine   |                                           ---------------------------
        |                     |
        |  (localhost /       |                                           ---------------------------
        |         Circle CI)  |                                           |                         |
        |                     | ------------- (3) deploy ---------------> |     target machine      |
        |                     |                                           |                         |
        |                     | ------ (4) restart & migrate -----------> |  (staging / production) |
        |                     |                                           |                         |
        -----------------------                                           ---------------------------

If (1) compiling and generating the release build was successful, then (2) the release is copied from the build server to the release store.
The release store is the `./.deliver/releases` directory on the control machine.

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
* In [rel/config.exs](rel/config.exs) file we should add seed command with plugin `LinkConfig`.

  ```elixir
  environment :prod do
    set include_erts: true
    set include_src: false
    set cookie: :"rm!z`joIlVak;]t$[Dyo$?D8Mu)/H,by9YjAQ/qIJ1(fS.]d(dI@Cu&{P>S%NI5J"
    # add below 2 lines
    set commands: [
      "seed": "rel/commands/seed.sh",
    ]
    # https://github.com/edeliver/edeliver/wiki/Use-per-host-configuration#linking-with-distillery
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
* Add at the very end of the [config/prod.exs](config/prod.exs) file and ensure the `import_config "prod.secret.exs"` is comment out:

  ```elixir
  # NOTE: this should be commented because we don't use it
  # import_config "prod.secret.exs"

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
    erlang_magic_cookie: :"FILL_IN_HERE"
  ```
* Create [bin/deploy](bin/deploy) with executable chmod `$ chmod a+x deploy` and update there `HOST` to your staging/production servers.
* Create [bin/restart](bin/restart) with executable chmod `$ chmod a+x deploy`

## Staging and production environments

### Machines

* Build server:
  * domain: `elixir-build-server.lunarlogic.io`
* Staging:
  * domain: `phoenix-website-staging.lunarlogic.io` (this server was not provisioned. It's just example)
* Production:
  * domain: [phoenix-website.lunarlogic.io](https://phoenix-website.lunarlogic.io) (This is our example app, you can see it)

### Credentials

Ensure you have `/home/phoenix/phoenix_website/phoenix_website.config` file on the staging and production hosts.

:mortar_board: We use different configurations on different deploy hosts, as described
[here](https://github.com/boldpoker/edeliver/wiki/Use-per-host-configuration)
(we link the `sys.config` by setting the env `LINK_SYS_CONFIG` in [.deliver/config](.deliver/config)).

If you change configuration structure in [config/config.exs](config/config.exs) or [config/prod.exs](config/prod.exs),
then you need to generate new `phoenix_website.config` file. To do so, you need to compile the application and in the compiled
package you will find `$DELIVER_TO/$APP/releases/$VERSION/sys.config` template with `FILL_IN_HERE` instead of
credentials. Use the template file, add proper credentials in it and then upload to staging and production hosts.

Please read comment above the line `LINK_SYS_CONFIG="$DELIVER_TO/$APP/$APP.config"` in the file [.deliver/config](.deliver/config) to see what steps to follow to achieave that.

#### Performing the deployment

The app is deployed to **production** by CircleCI from master branch when tests are green. You can see deployment configuration in [.circleci/config.yml](.circleci/config.yml).

###### Deploying manually

```shell
BRANCH=master TARGET_SERVER=staging bin/deploy      # deploy to staging
BRANCH=master TARGET_SERVER=production bin/deploy   # deploy to production
```

## Tips

* `$ mix phx.gen.secret` can generate secret that can be used for `erlang_magic_cookie` or for `secret_key_base` in `config/prod.exs`.
* In order to run seeds do:

  ```shell
  ssh phoenix@phoenix-website.lunarlogic.io /home/phoenix/phoenix_website/bin/phoenix_website command Elixir.PhoenixWebsite.ReleaseTasks seed
  ```
* How to check logs on App Server

  ```shell
  $ ssh admin@phoenix-website.lunarlogic.io

  # logs for systemd phoenix_website service
  $ sudo journalctl -u phoenix_website

  # check nginx errors log
  $ sudo tail -f /var/log/nginx/error.log
  ```


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
