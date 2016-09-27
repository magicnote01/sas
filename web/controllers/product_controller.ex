defmodule Sas.ProductController do
  use Sas.Web, :controller

  alias Sas.Product
  alias Sas.Category

  plug :load_categories when action in [:new, :create, :edit, :update]

  def index(conn, _params) do
    products =
      Product
      |> load_product_with_category_name
      |> Repo.all

    render(conn, "index.html", products: products)
  end

  def new(conn, _params) do
    changeset =
      %Category{}
      |> build_assoc(:products)
      |> Product.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    changeset =
      %Category{id: Map.get(product_params, "category_id")}
      |> build_assoc(:products)
      |> Product.changeset(product_params)

    case Repo.insert(changeset) do
      {:ok, _product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: product_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    {product, category_name} =
      Product
      |> load_product_with_category_name(id)
      |> Repo.one
    render(conn, "show.html", product: product, category_name: category_name)
  end

  def edit(conn, %{"id" => id}) do
    product = Repo.get!(Product, id)
    changeset = Product.changeset(product)
    render(conn, "edit.html", product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Repo.get!(Product, id)
    changeset = Product.changeset(product, product_params)

    case Repo.update(changeset) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: product_path(conn, :show, product))
      {:error, changeset} ->
        render(conn, "edit.html", product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Repo.get!(Product, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: product_path(conn, :index))
  end

  defp load_categories(conn, _) do
    query =
      Category
      |> load_categories_name_id
    categories = Repo.all query
    assign(conn, :categories, categories)
  end

  defp load_categories_name_id(category) do
    from c in category, select: {c.name, c.id}
  end

  defp load_product_with_category_name(product) do
    from p in product,
      join: c in Category, on: p.category_id == c.id,
      select: {p, c.name}
  end

  defp load_product_with_category_name(product, product_id) do
    from p in product,
      join: c in Category, on: p.category_id == c.id,
      where: p.id == ^product_id,
      select: {p, c.name}
  end
end
