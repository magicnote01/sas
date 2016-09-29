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

  def split_list(list, fun) do
    split_list(list, [], [], fun)
  end
  defp split_list([],list_true, list_false, _fun) do
    { Enum.reverse(list_true) , Enum.reverse(list_false) }
  end
  defp split_list([head | tail], list_true, list_false, fun) do
    if fun.(head) do
      split_list(tail, [head | list_true], list_false, fun)
    else
      split_list(tail, list_true, [head | list_false], fun)
    end
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
