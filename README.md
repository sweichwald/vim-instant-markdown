# vim2pmpm: markdown preview for vim using [pmpm][pmpm]



_Forked from [suan/vim-instant-markdown][forkedfrom] on 2020-04-30;
original copyright and license notices are preserved in [LICENSE](LICENSE) and the same [Apache License 2.0][apache] applies to this repository;
[all changes][changes] are documented._



---



Trims down the original by
a) removing unused functionality and configuration parameters and
b) dropping support for and reference to the Node.js markdown preview server in favour of [pmpm][pmpm] that supports [Pandoc's Markdown][pandocmarkdown].



---



# vim2pmpm: markdown preview for vim using [pmpm][pmpm]

Pipes to [pmpm][pmpm], which serves an html preview of the active buffer's markdown.

## Installation

- Install [pmpm][pmpm]

- For [vim-plug][plug], add the following to your `.vimrc`:

    ``` vim
    Plug 'sweichwald/vim2pmpm', {'for': 'markdown'}
    filetype plugin on
    ```

- Configuration (defaults shown below):

    ``` vim
    "let g:pmpm_slow = 0
    "let g:pmpm_autostart = 1
    "let g:pmpm_autostop = 0
    "let g:pmpm_port = 9877
    ```

## Configuration

### g:pmpm_slow

By default, vim2pmpm will update the display in realtime.  If that taxes your system too much, you can specify

``` vim
let g:pmpm_slow = 1
```

before loading the plugin (for example place that in your `~/.vimrc`). This will cause vim2pmpm to only refresh on the following events:

- No keys have been pressed for a while
- A while after you leave insert mode
- You save the file being edited

### g:pmpm_autostart / -stop

By default, vim2pmpm will automatically launch (and not automatically close) the preview server when you open (or close, respectively) a markdown file. If you want to manually control this behavior, you can specify

``` vim
let g:pmpm_autostart = 0
let g:pmpm_autostop = 1
```

in your .vimrc. You can always manually trigger preview via the command
`:PMPMStart` and stop it via `:PMPMStop`.


### g:pmpm_port

Choose a custom port for the [pmpm][pmpm] websocket server instead of the default `9877`.

``` vim
let g:pmpm_port = 9877
```



[apache]: http://www.apache.org/licenses/LICENSE-2.0
[changes]: https://github.com/suan/vim-instant-markdown/compare/2d5324e...sweichwald:master
[forkedfrom]: https://github.com/suan/vim-instant-markdown/tree/2d5324edf171dd0cd2e1eb995fd77816ee3bb959
[pandocmarkdown]: https://pandoc.org/MANUAL.html#pandocs-markdown
[plug]: https://github.com/junegunn/vim-plug
[pmpm]: https://github.com/sweichwald/pmpm
