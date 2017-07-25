#!/bin/sh

# This file must be executable. Run from main repo directory:
# $ chmod a+x rel/commands/seed.sh

bin/phoenix_website command Elixir.PhoenixWebsite.ReleaseTasks seed
