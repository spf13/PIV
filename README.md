# PHP Integration for VIM

## Description 

This project contains the most feature complete and up date date php integration for vim. 
It began as a fork of the largely outdated VIP (formerly PDV), but has morphed into it's own project. 

It does not include non PHP specific functionality like commenting but rather suggests you use one of the many general purpose plugins that do a great job.. Recommendations provided at the end of this doc.

## Features

### Updated Syntax
_Updated for PHP 5.3_

The list of PHP constants, functions, and classes was updated to be current with PHP 5.3.
Many new classes were added in the 5.2 branch and the distributed version only covers up
to 5.1.4. 

### Better Fold Support
This plugin can fold PHP functions and/or classes, properties with their PhpDoc, 
without manually adding marker style folds ({{{ and }}})
[[http://www.vim.org/scripts/script.php?script_id=1623]]

Can be turned off by setting 
    let g:DisableAutoPHPFolding = 1
in your .vimrc file.

### PHP Doc Gen
Generate phpDocumentor conforming documentation blocks for your PHP code. 

To use place cursor on line with class, function or variable definition and type ,pd (in n mode)

### Better Completion
PHP completion script for use with omniComplete. 

Completion from current file, tags and php builtin:
	* classes (after new), 
	* functions  
	* variables
	* constants 
	* language keywords 

After -> and :: options limited to funcs and vars.

### Better indenting w/automatic formatting
Custom php indenting file for VIM


## Recommendations
It isn't my intention to provide php specific functionality when a good general purpose solution exists.

The following plugins are recommended and can be found in my [vim config repository](git@github.com:spf13/spf13-vim.git).

 * [Snipmate](http://github.com/msanders/snipmate.vim)
 * [NerdCommenter](http://github.com/scrooloose/nerdcommenter.git)
 * [NerdTree](http://github.com/scrooloose/nerdtree)
 * [SuperTab](http://www.vim.org/scripts/script.php?script_id=1643)
 * [Fugitive](http://github.com/tpope/vim-fugitive.git)
 * [DelimitMate](http://github.com/Raimondi/delimitMate)
 * [Matchit](http://www.vim.org/scripts/script.php?script_id=39)
 * [CheckSyntax](http://www.vim.org/scripts/script.php?script_id=1431)
 * [Surrounding](http://github.com/msanders/vim-files/blob/master/plugin/surrounding.vim)
 * [AutoCloseTag](http://www.vim.org/scripts/script.php?script_id=2591)
