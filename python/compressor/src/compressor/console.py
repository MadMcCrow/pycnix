# custom printing
from rich.console import Console
from rich.theme import Theme

# custom theme for simple coloring scheme
custom_theme = Theme({
    "info": "dim cyan",
    "warning": "magenta",
    "error": "bold red",
    "success" : "bold white on green"
})

# make sure console works
console = Console(theme=custom_theme)

# override default print function
def print(text, end='\n') :
    console.print(text, end = end)