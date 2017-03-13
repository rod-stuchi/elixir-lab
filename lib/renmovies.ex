#nodemon --watch lib --watch test -e ex,exs --exec "clear && mix test"
#/disks/1TB/C_Driver/rods/Documents/LINQPad Queries/Rename-Movies.linq

defmodule Renmovies do
#    import Print

  def main(args \\[]) do
    #IO.puts "dire::" <> File.cwd! <> "\n\n"
    IO.inspect parse_args(args)
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

        p = &(IO.puts/1)

        case option do
            {_, _, [{_, nil}]}
                -> p.(print_usage())
                :wrong
            {[dry_run: true], ["rename"], _}
                -> #IO.puts :dry_rename
                :dry_rename
            {[dry_run: true], ["extract"], _}
                -> #IO.puts :dry_extract;
                extract(true)
                :dry_extract
            {[dry_run: true], ["delete"], _}
                -> #IO.puts :dry_delete
                :dry_delete
            {_, ["rename"], _}
                -> #IO.puts :do_rename
                :do_rename
            {_, ["extract"], _}
                -> #IO.puts :do_extract;
                extract(false)
                :do_extract
            {_, ["delete"], _}
                -> #IO.puts :do_delete
                :do_delete
            _
                -> p.(print_usage())
                :show_print
        end
    end

  def extract(dry \\true) do
    Extract.extract_files(dry)
  end
end
