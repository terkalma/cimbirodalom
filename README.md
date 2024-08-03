# Cimbirodalom

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


## Docs

Project contains an admin and website.

* They use different layouts
* Different html_helpers
* Different assets are compiled for the 2
  * `app.css`  / `app.js` for the website
  * `admin.css` / `admin.js` for the admin


* Both sites use `tailwind` and they share the same config.
* [Flowbite](https://flowbite.com/docs/getting-started/phoenix/) is used for the admin drawer + article carousels (installation details linked).


## Schema

https://app.diagrams.net/#G1z1-ltu_BoqOcla47xdb1DQstcxwVhgnE#%7B%22pageId%22%3A%22R2lEEEUBdFMjLlhIrx00%22%7D


## Resources


Resources can be generated:

### Articles

```
mix phx.gen.live Articles Article articles title:text slug:text:unique subtitle:text created_by:references:admins --web Admin
```

### Article Content

```
mix phx.gen.schema Articles.Content article_contennts article_id:references:articles
```


### Authors

```
mix phx.gen.live Authors Author authors name:text slug:text:unique img_path:text description:text --web Admin
```

