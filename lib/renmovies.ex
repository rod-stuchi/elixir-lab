#nodemon --watch lib --watch test -e ex,exs --exec "clear && mix test"
#/disks/1TB/C_Driver/rods/Documents/LINQPad Queries/Rename-Movies.linq

defmodule Renmovies do
  def main(args \\[]) do
    #IO.puts "dire::" <> File.cwd! <> "\n\n"
    parse_args(args)
  end

  def print(obj, num \\false) do
    Apex.ap obj, numbers: num
  end

  def print_usage do
    import IO.ANSI
    format([
            :italic, 
            "Path:\t ", 
            color(8), File.cwd!, "\n", 
            color(25), :bright, :not_italic, 
            "\nUsage:\n\n",
            color(7),
            "\trenmovie delete       : to delete unnecessary files\n",
            "\trenmovie rename       : to rename files and folders\n",
            "\trenmovie extract      : to extract content from subfolders\n",
            "\trenmovie --dry-run    : to simulate what will happen"
    ], true)
  end

  def parse_args(args) do
        # option = OptionParser.parse(System.argv, strict: [dry_run: :boolean])
        option = OptionParser.parse(args, strict: [dry_run: :boolean])
        #IO.inspect(option, pretty: true)

        p = &(IO.puts/1)

        case option do
            {_, _, [{_, nil}]} 
                -> p.(print_usage())
                :wrong
            {[dry_run: true], ["rename"], _}
                -> IO.puts :dry_rename
                :dry_rename
            {[dry_run: true], ["extract"], _}
                -> IO.puts :dry_extract; 
                extract(true)
                :dry_extract
            {[dry_run: true], ["delete"], _}
                -> IO.puts :dry_delete
                :dry_delete
            {_, ["rename"], _}
                -> IO.puts :do_rename
                :do_rename
            {_, ["extract"], _}
                -> IO.puts :do_extract
                :do_extract
            {_, ["delete"], _}
                -> IO.puts :do_delete
                :do_delete
            _ 
                -> p.(print_usage())
                :show_print
        end
    end

  def extract(dry \\true) do
    path = File.cwd! <> "/movies/*"
    
    fsize = fn p -> 
      case File.stat p do 
        {:ok, %{size: sizee}} -> Sizeable.filesize(sizee)
        {:error, reason} -> reason
      end
    end

    dire = Path.wildcard(path) 
            |> Enum.filter(fn f -> File.dir?(f) end)
            |> Enum.map(fn fl -> %{ 
                basedir: Path.relative_to_cwd(fl), 
                paths: Path.wildcard(fl <> "/**")
                    |> Enum.filter_map(
                        fn fd -> not File.dir?(fd) end,
                        fn sp -> %{
                            old: Path.relative_to_cwd(sp), 
                            new: Path.join(fl, Path.basename(sp)) |> Path.relative_to_cwd(),
                            size: fsize.(sp) 
                    } end)
                    |> Enum.filter(fn f -> f.old != f.new end)
            } end)
            # |> Enum.drop(-2)
            #|> Enum.map(fn x -> print x end)

    if (dry) do
        import IO.ANSI
        IO.puts format([
            # :italic, 
            # "Path:\t ", 
            # color(8), File.cwd!, "\n", :not_italic,
            color(2), :bright,
            "\n dry-run, will extract files to base directory:\n\n",
            Enum.map(dire, fn d -> [
                color(7),
                " " <> d.basedir, :italic, 
                "\n   from: \n",
                color(8), :normal, :not_italic,
                # Enum.map(d.paths, fn x -> 
                #     "     ┌─ " <> Path.relative_to(x.old, d.basedir) <> "\n" end) |> Enum.take(1),
                # Enum.map(d.paths, fn x -> 
                #     "     ├─ " <> Path.relative_to(x.old, d.basedir) <> "\n" end) |> Enum.drop(-1) |> Enum.drop(1), 
                # Enum.map(d.paths, fn x -> 
                #     "     └─ " <> Path.relative_to(x.old, d.basedir) <> "\n" end) |> Enum.take(-1),
                Enum.map(d.paths, fn x -> 
                    "     │ " <> Path.relative_to(x.old, d.basedir) <> "\n" end), 
                color(7), :italic,
                "   to:\n",
                color(7), :normal, :not_italic,
                Enum.map(d.paths, fn x -> 
                    "     ║ " <> Path.relative_to(x.new, d.basedir) <> "\n" end), 
                "\n",
            ] end)
        ], true)
    end
    # IO.inspect(dire, pretty: true)
    # print dire, dry
  end
end
