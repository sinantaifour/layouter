# Layouter: A layout engine for terminals

If you ever had to deal with dividing the terminal into sub-parts that adjust
in size when the terminal changes size, then this is the gem for you.

If you're wondering why you would ever need that, check the
[`termplot`](https://github.com/staii/termplot) gem.

## Installation

```console
$ gem install termplot
```

## Usage

```ruby
require 'layouter'

# A `spacer` grows and shrinks to fill unused space.
spacer1 = Layouter.spacer
spacer2 = Layouter.spacer
spacer3 = Layouter.spacer

# A `literal` is shown as-is, in a single line.
literal = Layouter.literal("Title")

# A `vertical` grows vertically as needed, repeating the given character.
vertical1 = Layouter.vertical("|")
vertical2 = Layouter.vertical(" ")

# A `custom` calls a block with its width and height to render.
custom = Layouter.custom(width: (5..25), importance: 1.5) do |w, h|
  # Return a string of characters, `h` lines, with `w` characters per line,
  # selected from "!@&%^".
  chars = "!@&%^"
  h.times.map do |j|
    w.times.map do |i|
      chars[(j * w + i) % chars.length]
    end.join("")
  end.join("\n")
end

# An `annotation` is like a literal, but it can shrink to make space.
annotation1 = Layouter.annotation("Some long string")
annotation2 = Layouter.annotation(Math::PI)

root = Layouter.rows( # Our layout has rows ...
  Layouter.cols(      # ... the first row has 3 columns ...
    spacer1, literal, spacer2
  ),
  Layouter.cols(      # ... and the second row has 4 columns ...
    vertical1,
    custom,
    vertical2,
    Layouter.rows(    # ... of which the last column consists of 3 rows.
      annotation1, spacer3, annotation2
    )
  )
)

root.layout(30, 10) # Lay everything out into 30 columns and 10 rows.
puts root.render
```

Results in:

```
            Title             
|!@&%^!@&%^!@&%^!@& Some long…
|%^!@&%^!@&%^!@&%^!           
|@&%^!@&%^!@&%^!@&%           
|^!@&%^!@&%^!@&%^!@           
|&%^!@&%^!@&%^!@&%^           
|!@&%^!@&%^!@&%^!@&           
|%^!@&%^!@&%^!@&%^!           
|@&%^!@&%^!@&%^!@&%           
|^!@&%^!@&%^!@&%^!@ ~3.1415926
```
