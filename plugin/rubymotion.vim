" rubymotion.vim - Detect a rubymotion application
" Author: Jordan Brock <http://github.com/jordanbrock>
"
" Install this file as plugin/rubymotion.vim

if exists('g:loaded_rubymotion') || &cp || v:version < 700
  finish
endif
let g:loaded_rubymotion = 1

" Utility Functions {{{1
function! RubyMotionDetect(...) abort
  if exists('b:rubymotion_root')
    return 1
  endif
  let file = findfile('app/app_delegate.rb, escape(fn, ', ').';')
  if !empty(file)
    let b:rubymotion_root = fnamemodify(file, ':p:h:h')
    return 1
  endif
endfunction

augroup rubymotionPluginDetect
  autocmd!
  autocmd BufEnter * if exists("b:rubymotion_root")|silent doau User BufEnterRubyMotion|endif
  autocmd BufLeave * if exists("b:rubymotion_root")|silent doau User BufLeaveRubyMotion|endif

  autocmd BufNewFile,BufReadPost *
        \ if RubyMotionDetect(expand("<afile>:p")) && empty(&filetype) |
        \   call rubymotion#buffer_setup() |
        \ endif
  autocmd VimEnter *
        \ if empty(expand("<amatch>")) && RubyMotionDetect(getcwd()) |
        \   call rubymotion#buffer_setup() |
        \   silent doau User BufEnterRubyMotion |
        \ endif
  autocmd FileType netrw
        \ if RubyMotionDetect() |
        \   silent doau User BufEnterRubyMotion |
        \ endif
  autocmd FileType * if RubyMotionDetect() | call rubymotion#buffer_setup() | endif

  autocmd BufNewFile,BufReadPost *.yml.example set filetype=yaml
  autocmd BufNewFile,BufReadPost *.ruby
        \ if &filetype !=# 'ruby' | set filetype=ruby | endif

  autocmd Syntax ruby,eruby,yaml
        \ if RubyMotionDetect() | call rubymotion#buffer_syntax() | endif
augroup END

command! -bar -bang -nargs=* -complete=dir RubyMotion execute rubymotion#new_app_command(<bang>0,<f-args>)

" }}}1
" abolish.vim {{{1

function! s:function(name)
  return function(substitute(a:name,'^s:',matchstr(expand('<sfile>'), '<SNR>\d\+_'),''))
endfunction

augroup rubymotionPluginAbolish
  autocmd!
  autocmd VimEnter * call s:abolish_setup()
augroup END

function! s:abolish_setup()
  if exists('g:Abolish') && has_key(g:Abolish,'Coercions')
    if !has_key(g:Abolish.Coercions,'l')
      let g:Abolish.Coercions.l = s:function('s:abolish_l')
    endif
    if !has_key(g:Abolish.Coercions,'t')
      let g:Abolish.Coercions.t = s:function('s:abolish_t')
    endif
  endif
endfunction

function! s:abolish_l(word)
  let singular = rubymotion#singularize(a:word)
  return a:word ==? singular ? rubymotion#pluralize(a:word) : singular
endfunction

function! s:abolish_t(word)
  if a:word =~# '\u'
    return rubymotion#pluralize(rubymotion#underscore(a:word))
  else
    return rubymotion#singularize(rubymotion#camelize(a:word))
  endif
endfunction

" }}}1
" vim:set sw=2 sts=2:
