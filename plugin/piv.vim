" File:        php.vim
" Description: PHP Integration for VIM plugin
" Maintainer:  Steve Francia <piv@spf13.com> <http://spf13.com>
" Version:     0.9
" Last Change: 7th January 2012

" Most of the functions and settings are php specific and located in ftplugin/php.vim
" This file will be for general settings.

" Detect twig filetype
au BufNewFile,BufRead *.twig      setf htmljinja

" Make sure help set properly for PHP files
autocmd FileType php set kp=:help

