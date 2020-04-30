**Work in Progress**

Forked from [suan/vim-instant-markdown][forkedfrom] on 2020-04-30;
original copyright and license notices are preserved in [LICENSE](LICENSE) and the same [Apache License 2.0][apache] applies to this repository;
[all changes][changes] are documented.

Trims down the original by a) removing unused functionality and configuration parameters and b) dropping support for and reference to the Node.js markdown preview server in favour of the python one that supports [Pandoc's Markdown][pandocmarkdown].



---



# vim-instant-markdown

PUTs to [smdv][smdv], which serves an html preview of the active buffer's markdown.

## Installation

- Install [smdv][smdv]

- For [vim-plug][plug], add the following to your `.vimrc`:

    ``` vim
    Plug 'sweichwald/vim-instant-markdown', {'for': 'markdown'}
    filetype plugin on
    ```

- Configuration (defaults shown below):

    ``` vim
    "let g:instant_markdown_slow = 0
    "let g:instant_markdown_autostart = 1
    "let g:instant_markdown_logfile = '/dev/null'
    "let g:instant_markdown_autoscroll = 1
    "let g:instant_markdown_port = 8090
    ```

## Configuration

### g:instant_markdown_slow

By default, vim-instant-markdown will update the display in realtime.  If that taxes your system too much, you can specify

``` vim
let g:instant_markdown_slow = 1
```

before loading the plugin (for example place that in your `~/.vimrc`). This will cause vim-instant-markdown to only refresh on the following events:

- No keys have been pressed for a while
- A while after you leave insert mode
- You save the file being edited

### g:instant_markdown_autostart

By default, vim-instant-markdown will automatically launch the preview server when you open a markdown file. If you want to manually control this behavior, you can specify

``` vim
let g:instant_markdown_autostart = 0
```

in your .vimrc. You can always manually trigger preview via the command
`:InstantMarkdownPreview` and stop it via `:InstantMarkdownStop`.

### g:instant_markdown_logfile

For troubleshooting, server startup and curl communication from Vim to the server can be logged into a file.

```
let g:instant_markdown_logfile = '/tmp/instant_markdown.log'
```

### g:instant_markdown_port

Choose a custom port instead of the default `8090`.

``` vim
let g:instant_markdown_port = 8888
```

### g:instant_markdown_autoscroll

By default, the live preview auto-scrolls to where your cursor is positioned.
To disable this behaviour, edit your .vimrc and add

``` vim
let g:instant_markdown_autoscroll = 0
```



[apache]: http://www.apache.org/licenses/LICENSE-2.0
[changes]: https://github.com/suan/vim-instant-markdown/compare/2d5324e...sweichwald:master
[forkedfrom]: https://github.com/suan/vim-instant-markdown/tree/2d5324edf171dd0cd2e1eb995fd77816ee3bb959
[pandocmarkdown]: https://pandoc.org/MANUAL.html#pandocs-markdown
[plug]: https://github.com/junegunn/vim-plug
[smdv]: https://github.com/sweichwald/smdv
