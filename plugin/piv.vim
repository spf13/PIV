" File:        php.vim
" Description: PHP Integration for VIM plugin
" Maintainer:  Steve Francia <steve.francia@gmail.com> <http://spf13.com>
" Version:     0.8
" Last Change: 23rd April 2010

" Most of the functions and settings are php specific and located in ftplugin/php.vim
" This file will be for general settings.

" Detect twig filetype
au BufNewFile,BufRead *.twig      setf htmljinja

" Make sure help set properly for PHP files
autocmd FileType php set kp=:help

