defmodule Print do
    def print(obj, label \\"", num \\false) do
        if String.length(label) > 0 do  
            Apex.ap label, numbers: false
            Apex.ap obj, numbers: num
        else
            Apex.ap obj, numbers: num
        end
  end
end