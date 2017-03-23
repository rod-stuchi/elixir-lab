defmodule Extract do
    import Print

#------------------------------------------------------------------------------------------------------------------
  def extract_files(dry \\true) do
    paths = Utils.get_paths()

    print_result = fn dry ->
      import IO.ANSI
      IO.puts format([
        color(2), :bright,
        dry
          && "\n dry-run, will extract files to base directory:\n\n"
          || "\n extracted files to base directory:\n\n",
        Enum.map(paths, fn d -> [
          color(7),
          " " <> d.basedir, :italic,
          "\n   from: \n",
          color(8), :normal, :not_italic,
          Enum.map(d.paths, fn x -> "     │ " <> Path.relative_to(x.old, d.basedir) <> "\n" end),
          color(7), :italic,
          "   to:\n",
          color(7), :normal, :not_italic,
          Enum.map(d.paths, fn x -> "     ║ " <> Path.relative_to(x.new, d.basedir) <> "\n" end),
          "\n",
        ] end)
      ], true)
    end

    if (dry) do
      print_result.(dry)
    else
      # save current state before move files
      Utils.save_state paths
      
      # move files
      paths
      |> Enum.map(fn x ->
        x.paths |> Enum.map(fn p ->
          File.rename(p.old, p.new)
        end)
      end)

      # remove empty directories
      paths
      |> Enum.map(fn x ->
        Path.wildcard(x.basedir <> "/**")
        |> Enum.filter_map(& File.dir?(&1), & File.rm_rf(&1))
      end)

      print_result.(dry)
    end
  end

end