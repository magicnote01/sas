defmodule Sas.Router do
  use Sas.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :staff do
    plug Sas.Auth, repo: Sas.Repo
  end

  pipeline :admin do
    plug :authenticate_user, role: Sas.User.admin
  end

  pipeline :distributor do
    plug :authenticate_user, role: Sas.User.distributor
  end

  pipeline :waiter do
    plug :authenticate_user, role: Sas.User.waiter
  end

  pipeline :cashier do
    plug :authenticate_user, role: Sas.User.cashier
  end

  pipeline :order_master do
    plug :authenticate_user, role: Sas.User.order_master
  end

  pipeline :order_master_session do
    plug :confirm_order_master_session
  end

  pipeline :table do
    plug Sas.TableAuth, repo: Sas.Repo
  end

  pipeline :table_auth do
    plug :authenticate_table
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Sas do
    pipe_through [:browser, :table] # Use the default browser stack

    get "/", TableSessionController, :new
    post "/t", TableSessionController, :create
    get "/t", TableSessionController, :create
    get "/t/:name/:password", TableSessionController, :create

    scope "/orders/" do
      pipe_through [:table_auth]
      get "/", OrderController, :table_index
      get "/show/:id", OrderController, :table_show
      get "/new", OrderController, :table_new
      post "/new", OrderController, :table_create
    end
  end

  scope "/staff/", Sas do
    pipe_through [:browser, :staff]

    get "/", SessionController, :new
    resources "/sessions", SessionController, only: [:create, :delete]

    scope "/admin" do
      pipe_through [:admin]
      get "/", PageController, :admin_index
      resources "/users", UserController, only: [:index, :new, :create, :show, :edit, :update ]
      resources "/tables", TableController, only: [:index, :new, :create, :show, :edit, :update ]
      resources "/products", ProductController
    end

    scope "/distributor" do
      pipe_through [:distributor]
      get "/", OrderController, :distributor
      get "/active", OrderController, :distributor_active_order
      get "/orders/take/:id", OrderController, :distributor_take_order
      get "/orders/show/:id", OrderController, :distributor_show_order
      put "/orders/update/:id", OrderController, :distributor_update_order
      patch "/orders/update/:id", OrderController, :distributor_update_order
    end

    scope "/waiter" do
      pipe_through [:waiter]
      get "/", OrderController, :waiter
      get "/orders/complete/:id", OrderController, :waiter_complete_order
    end

    scope "/cashier" do
      pipe_through [:cashier]
      get "/", OrderMasterSessionController, :index
      get "/orders", OrderController, :cashier
      get "/orders/close/:id", OrderController, :cashier_close_order
      resources "/r/orders", OrderController, only: [:new, :create, :show]
      resources "/r/order_master_sessions", OrderMasterSessionController, only: [:index, :new, :create, :show]
      get "/order_master_sessions/close/:id", OrderMasterSessionController, :close
    end

    scope "/order_master" do
      pipe_through [:order_master]
      get "/", OrderController, :order_master
      get "/take_order", TableController, :order_master_table

      scope "/orders" do
        pipe_through [:order_master_session]
        get "/show/:id", OrderController, :order_master_show_order
        post "/close/:id", OrderController, :order_master_close_order
        delete "/cancel/:id", OrderController, :order_master_cancel_order
      end
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", Sas do
  #   pipe_through :api
  # end
end
