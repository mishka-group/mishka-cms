# menu = [
#   %{id: 1, title: "menu 1 main", link: "#", sub: nil},
#   %{id: 2, title: "menu 2 sub menu 1", link: "#", sub: 1},
#   %{id: 3, title: "menu 3 sub menu 1", link: "#", sub: 1},
#   %{id: 4, title: "menu 4 main", link: "#", sub: nil},
#   %{id: 5, title: "menu 5 main", link: "#", sub: nil},
#   %{id: 6, title: "menu 6 sub menu 4", link: "#", sub: 4},
# ]

# Enum.reject(menu, fn x -> x.sub != nil end) |> Enum.map(fn main_menu ->
#   Map.merge(main_menu, %{subs: Enum.filter(menu, fn x -> x.sub == main_menu.id end)})
# end)
