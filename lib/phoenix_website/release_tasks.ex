# https://hexdocs.pm/distillery/running-migrations.html
defmodule PhoenixWebsite.ReleaseTasks do
  @start_apps [
    :postgrex,
    :ecto
  ]

  @myapps [
    :phoenix_website
  ]

  @repos [
    PhoenixWebsite.Repo
  ]

  def seed do
    run_seed_file("seeds")
  end

  def sample_dev_seeds do
    run_seed_file("sample_dev_seeds")
  end

  def import_production_data do
    run_seed_file("import_production_data")
  end

  def run_seed_file(seed_file_name) do
    IO.puts "Loading myapp.."
    # Load the code for myapp, but don't start it
    :ok = Application.load(:phoenix_website)

    IO.puts "Starting dependencies.."
    # Start apps necessary for executing migrations
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    # Start the Repo(s) for myapp
    IO.puts "Starting repos.."
    Enum.each(@repos, &(&1.start_link(pool_size: 1)))

    # Run migrations
    Enum.each(@myapps, &run_migrations_for/1)

    # Run the seed script if it exists
    seed_script = Path.join([priv_dir(:phoenix_website), "repo", "#{seed_file_name}.exs"])
    if File.exists?(seed_script) do
      IO.puts "Running seed script.."
      Code.eval_file(seed_script)
    end

    # Signal shutdown
    IO.puts "Success!"
    :init.stop()
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(app) do
    IO.puts "Running migrations for #{app}"
    Ecto.Migrator.run(Ieep.Repo, migrations_path(app), :up, all: true)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
  defp seed_path(app), do: Path.join([priv_dir(app), "repo", "seeds.exs"])
end
