defmodule Sas.ListState do
  def map_state(list,fun,acc) do
    map_state(list,fun,acc,[])
  end
  defp map_state([],_fun,_acc,result) do
    Enum.reverse result
  end
  defp map_state([head|tail],fun,acc,result) do
    {element, acc} = fun.(head,acc)
    map_state(tail,fun,acc,[element|result])
  end

  def to_struct(kind, attrs) do
     struct = struct(kind)
     Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
       case Map.fetch(attrs, Atom.to_string(k)) do
         {:ok, v} -> %{acc | k => v}
         :error -> acc
       end
     end
   end
end
