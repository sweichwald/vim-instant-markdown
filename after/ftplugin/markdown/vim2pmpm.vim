" # Configuration
if !exists('g:pmpm_slow')
    let g:pmpm_slow = 0
endif

if !exists('g:pmpm_autostart')
    let g:pmpm_autostart = 1
endif

if !exists('g:pmpm_autostop')
    let g:pmpm_autostop = 0
endif

if !exists('g:pmpm_port')
    let g:pmpm_port = 9877
endif



let g:pipe = expand("$XDG_RUNTIME_DIR/pmpm/pipe")


" # Utility Functions
" Simple system wrapper that ignores empty second args
function! s:system(cmd, stdin)
    if strlen(a:stdin) == 0
        call system(a:cmd)
    else
        call system(a:cmd, a:stdin)
    endif
endfu

" Wrapper function to automatically execute the command asynchronously and
" redirect output in a cross-platform way. Note that stdin must be passed as a
" List of lines.
function! s:systemasync(cmd, stdinLines)
    let cmd = a:cmd
    if has('win32') || has('win64')
        call s:winasync(cmd, a:stdinLines)
    elseif has('nvim')
        let job_id = jobstart(cmd)
        call chansend(job_id, join(a:stdinLines, "\n"))
        call chanclose(job_id, 'stdin')
    else
        let cmd = cmd . ' &'
        call s:system(cmd, join(a:stdinLines, "\n"))
    endif
endfu

" Executes a system command asynchronously on Windows. The List stdinLines will
" be concatenated and passed as stdin to the command. If the List is empty,
" stdin will also be empty.
function! s:winasync(cmd, stdinLines)
    " To execute a command asynchronously on windows, the script must use the
    " "!start" command. However, stdin can't be passed to this command like
    " system(). Instead, the lines are saved to a file and then piped into the
    " command.
    if len(a:stdinLines)
        let tmpfile = tempname()
        call writefile(a:stdinLines, tmpfile)
        let command = 'type ' . tmpfile . ' | ' . a:cmd
    else
        let command = a:cmd
    endif
    exec 'silent !start /b cmd /c ' . command
endfu

function! s:refreshView()
    let bufnr = expand('<bufnr>')
    call writefile(s:bufGetLines(bufnr), g:pipe)
endfu

function! s:startDaemon(initialMDLines)
    let argv = ' --port '.g:pmpm_port
    call s:systemasync('pmpm --start'.argv, a:initialMDLines)
endfu

function! s:initDict()
    if !exists('s:buffers')
        let s:buffers = {}
    endif
endfu

function! s:pushBuffer(bufnr)
    call s:initDict()
    let s:buffers[a:bufnr] = 1
endfu

function! s:popBuffer(bufnr)
    call s:initDict()
    call remove(s:buffers, a:bufnr)
endfu

function! s:killDaemonAuto()
    if g:pmpm_autostop
        let argv = ' --port '.g:pmpm_port
        call s:systemasync('pmpm --stop'.argv, [])
    endif
endfu

function! s:stop()
    let argv = ' --port '.g:pmpm_port
    call s:systemasync('pmpm --stop'.argv, [])
    au! vim2pmpm * <buffer>
endfu

function! s:bufGetLines(bufnr)
  let lines = getbufline(a:bufnr, 1, "$")
  " prepend directory of active file
  return [ "<!-- filepath:".expand('%:p')." -->" ] + lines
endfu

" I really, really hope there's a better way to do this.
fu! s:myBufNr()
    return str2nr(expand('<abuf>'))
endfu

" # Functions called by autocmds
"
" ## push a new Markdown buffer into the system.
"
" 1. Track it so we know when to garbage collect the daemon
" 2. Start daemon if we're on the first MD buffer.
" 3. Initialize changedtickLast, possibly needlessly(?)
fu! s:pushMarkdown()
    let bufnr = s:myBufNr()
    call s:initDict()
    if len(s:buffers) == 0
        call s:startDaemon(s:bufGetLines(bufnr))
    endif
    call s:pushBuffer(bufnr)
    let b:changedtickLast = b:changedtick
endfu

" ## pop a Markdown buffer
"
" 1. Pop the buffer reference
" 2. Garbage collection
"     * daemon
"     * autocmds
fu! s:popMarkdown()
    let bufnr = s:myBufNr()
    silent au! vim2pmpm * <buffer=abuf>
    call s:popBuffer(bufnr)
    if len(s:buffers) == 0
        call s:killDaemonAuto()
    endif
endfu

let g:refreshTimerFast = 0
let g:refreshTimerSlow = 0

" ## Refresh if there's something new worth showing
"
" 'All things in moderation'
fu! s:temperedRefresh(dummy)
    if !exists('b:changedtickLast')
        let b:changedtickLast = b:changedtick
    elseif b:changedtickLast != b:changedtick
        let b:changedtickLast = b:changedtick
        call s:refreshView()
    endif
    if a:dummy isnot 0
        let g:refreshTimerSlow = 0
    endif
endfu

fu! s:temperedRefreshPing()
    " restart the fast timer
    call timer_stop(g:refreshTimerFast)
    let g:refreshTimerFast = timer_start(150, function('s:temperedRefresh'))
    if g:refreshTimerSlow is 0
        let g:refreshTimerSlow = timer_start(1000, function('s:temperedRefresh'))
    endif
endfu

fu! s:previewMarkdown()
  call s:startDaemon(getline(1, '$'))
  aug vim2pmpm
    au CursorHold,CursorHoldI,BufWrite,InsertLeave <buffer> call s:temperedRefresh(0)
    if !g:pmpm_slow
      au CursorMoved,CursorMovedI <buffer> call s:temperedRefreshPing()
    endif
    au BufUnload <buffer> call s:cleanUp()
  aug END
endfu

fu! s:cleanUp()
  call s:killDaemonAuto()
  au! vim2pmpm * <buffer>
endfu

if g:pmpm_autostart
    " # Define the autocmds "
    aug vim2pmpm
        au! * <buffer>
        au BufEnter <buffer> call s:refreshView()
        au CursorHold,CursorHoldI,BufWrite,InsertLeave <buffer> call s:temperedRefresh(0)
        if !g:pmpm_slow
          au CursorMoved,CursorMovedI <buffer> call s:temperedRefreshPing()
        endif
        au BufUnload <buffer> call s:popMarkdown()
        au BufWinEnter <buffer> call s:pushMarkdown()
    aug END
endif

command! -buffer PMPMStart call s:previewMarkdown()
command! -buffer PMPMStop call s:stop()
