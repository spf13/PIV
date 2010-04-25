" Plugin for automatic folding of PHP functions (also folds related PHPdoc)
"
" Maintainer: Ray Burgemeestre
" Last Change: 2010 Jan 15
"
" USAGE
"  If you enabled the script in your after/ftplugin directory (see install)
"  then it will be executed after you open a .php file.
"
"  After e.g. adding/moving functions, you can re-execute the script by using
"  the following key mappings:
"
"  F5 - To fold functions, classes, and other stuff with PHPdoc (depending
"       on your configuration).
"  F6 - To do the same with more extensive bracket checking (might work
"       better if your folds are messed up due to misinterpreted brackets).
"  F7 - To remove all folds.
"
" INSTALL
"  1. Put phpfolding.vim in your plugin directory (~/.vim/plugin)
"  2. You might want to add the following keyboard mappings to your .vimrc:
"
"       map <F5> <Esc>:EnableFastPHPFolds<Cr>
"       map <F6> <Esc>:EnablePHPFolds<Cr>
"       map <F7> <Esc>:DisablePHPFolds<Cr>
"
"  3. You can disable auto folding in your .vimrc with:
"
"       let g:DisableAutoPHPFolding = 1
"
"    By default EnableFastPHPFolds is called. Do these mess up your folds, 
"    you can try to replace EnableFastPHPFolds by EnablePHPFolds. You can
"    change this in function s:CheckAutocmdEnablePHPFold. 
"
" NOTE
"  It may be that you need to load the plugin from your .vimrc manually, in
"  case it doesn't work:
"
"    let php_folding=0
"      (if you can't use the after directory in step 3)
"    source ~/path/to/phpfolding.vim
"      (if you're not using the default plugin directory)
"
"  MORE INFORMATION
"  - In PHPCustomFolds() you can i.e. comment the PHPFoldPureBlock('class', ...)
"    call to have the script not fold classes. You can also change the second
"    parameter passed to that function call, to have it or not have it fold
"    PhpDoc comments. All other folding you can turn on/off in this function.
"  - You can tweak the foldtext to your liking in the function PHPFoldText().
"  - You can set some preferences and default settings a few lines below
"    at the "Script configuration" part.
"
"  This script is tested with Vim version >= 6.3 on windows and linux.

" Avoid reloading {{{1
if exists('loaded_phpfolding')
    finish
endif

let loaded_phpfolding = 1
" }}}

" .vimrc variable to disable autofolding for php files {{{1
if !exists("g:DisableAutoPHPFolding")
    let g:DisableAutoPHPFolding = 0
endif
" }}}

command! EnableFastPHPFolds call <SID>EnableFastPHPFolds()
command! -nargs=* EnablePHPFolds call <SID>EnablePHPFolds(<f-args>)
command! DisablePHPFolds call <SID>DisablePHPFolds()

" {{{ Script configuration
" Display the following after the foldtext if a fold contains phpdoc
let g:phpDocIncludedPostfix = '**'
let g:phpDocBlockIncludedPostfix = '**#@+'

" Default values
" .. search this # of empty lines for PhpDoc comments
let g:searchPhpDocLineCount = 1
" .. search this # of empty lines that 'trail' the foldmatch
let g:searchEmptyLinesPostfixing = 1
" }}}
" {{{ Script constants
let s:synIDattr_exists = exists('*synIDattr')
let s:TRUE = 1
let s:FALSE = 0
let s:MODE_CREATE_FOLDS = 1
let s:MODE_REMEMBER_FOLD_SETTINGS = 2
let s:FOLD_WITH_PHPDOC = 1
let s:FOLD_WITHOUT_PHPDOC = 2
let s:SEARCH_PAIR_START_FIRST = 1
let s:SEARCH_PAIR_IMMEDIATELY = 2
" }}}

function! s:EnableFastPHPFolds() " {{{
	call s:EnablePHPFolds(s:FALSE)
endfunction
" }}}
function! s:EnablePHPFolds(...) " {{{
	let s:extensiveBracketChecking = s:TRUE

	" Check function arguments
	if a:0 == 1
		let s:extensiveBracketChecking = a:1
	endif

	" Remember cursor information if possible
	let s:savedCursor = line(".")

	" Initialize variables
	set foldmethod=manual
	set foldtext=PHPFoldText()
	let s:openFoldListItems = 0
	let s:fileLineCount = line('$')

	let s:searchPhpDocLineCount = g:searchPhpDocLineCount
	let s:searchEmptyLinesPostfixing = g:searchEmptyLinesPostfixing


	" Move to end of file
	exec s:fileLineCount	
	
	" First pass: Look for Folds, remember opened folds
	let s:foldingMode = s:MODE_REMEMBER_FOLD_SETTINGS
	call s:PHPCustomFolds()

	" Second pass: Recreate Folds, restore previously opened
	let s:foldingMode = s:MODE_CREATE_FOLDS
	" .. Remove all folds first
	normal zE
	let s:foldsCreated = 0
	call s:PHPCustomFolds()
	" .. Fold all
	normal zM

	" Restore previously opened folds
	let currentItem = 0
	while currentItem < s:openFoldListItems
		exec s:foldsOpenedList{currentItem}
		normal zo
		let currentItem = currentItem + 1
	endwhile

    :redraw
	echo s:foldsCreated . " fold(s) created"

	" Restore cursor
	exec s:savedCursor
	
endfunction
" }}}
function! s:DisablePHPFolds() " {{{
	"set foldmethod=manual
	set foldtext=
	normal zE
	echo "php fold(s) deleted"
endfunction
" }}}
function! s:PHPCustomFolds() " {{{
	" NOTE: The two last parameters for functions PHPFoldProperties() and
	"       PHPFoldPureBlock() overwrite: 'g:searchPhpDocLineCount' and
	"       'g:searchEmptyLinesPostfixing'..

	" Fold function with PhpDoc (function foo() {})
	call s:PHPFoldPureBlock('function', s:FOLD_WITH_PHPDOC)

	" Fold class properties with PhpDoc (var $foo = NULL;)
	call s:PHPFoldProperties('^\s*var\s\$', ";", s:FOLD_WITH_PHPDOC, 1, 1)

	" Fold class without PhpDoc (class foo {})
	call s:PHPFoldPureBlock('^\s*\(abstract\s*\)\?class', s:FOLD_WITH_PHPDOC)
	
	" Fold define()'s with their PhpDoc
	call s:PHPFoldProperties('^\s*define\s*(', ";", s:FOLD_WITH_PHPDOC)

	" Fold includes with their PhpDoc
	call s:PHPFoldProperties('^\s*require\s*', ";", s:FOLD_WITH_PHPDOC)
	call s:PHPFoldProperties('^\s*include\s*', ";", s:FOLD_WITH_PHPDOC)

	" Fold GLOBAL Arrays with their PhpDoc (some PEAR packages use these)
	call s:PHPFoldProperties('^\s*\$GLOBALS.*array\s*(', ";", s:FOLD_WITH_PHPDOC)

	" Fold marker style comments ({{{ foo }}})
	call s:PHPFoldMarkers('{{{', '}}}')

	" Fold PhpDoc "DocBlock" templates (#@+ foo #@-)
	call s:PHPFoldMarkers('#@+', '#@-')
endfunction
" }}}
function! s:PHPFoldPureBlock(startPattern, ...) " {{{
	let s:searchPhpDocLineCount = g:searchPhpDocLineCount
	let s:searchEmptyLinesPostfixing = g:searchEmptyLinesPostfixing
	let s:currentPhpDocMode = s:FOLD_WITH_PHPDOC

	if a:0 >= 1
		" Do we also put the PHP doc part in the fold?
		let s:currentPhpDocMode = a:1
	endif
	if a:0 >= 2
		" How far do we want to look for PhpDoc comments?
		let s:searchPhpDocLineCount = a:2
	endif
	if a:0 == 3
		" How greedy are we on postfixing empty lines?
		let s:searchEmptyLinesPostfixing = a:3
	endif

	" Move to file end
	exec s:fileLineCount

	" Loop through file, searching for folds
	while 1
		let s:lineStart = s:FindPureBlockStart(a:startPattern)

		if s:lineStart != 0

			let s:lineStart = s:FindOptionalPHPDocComment()
			let s:lineStop = s:FindPureBlockEnd('{', '}', s:SEARCH_PAIR_START_FIRST)

			" Stop on Error
			if s:lineStop == 0
				break
			endif

			" Do something with the potential fold based on the Mode we're in
			call s:HandleFold()

		else
			break
		endif

		" Goto fold start (remember we're searching upwards)
		exec s:lineStart
	endwhile


	if s:foldingMode != s:MODE_REMEMBER_FOLD_SETTINGS
    	" Remove created folds
	    normal zR
    endif
endfunction
" }}}
function! s:PHPFoldMarkers(startPattern, endPattern, ...) " {{{
	let s:currentPhpDocMode = s:FOLD_WITHOUT_PHPDOC

	" Move to file end
	exec s:fileLineCount

	" Loop through file, searching for folds
	while 1
		let s:lineStart = s:FindPatternStart(a:startPattern)

		if s:lineStart != 0
			let s:lineStart = s:FindOptionalPHPDocComment()
			" The fourth parameter is for disabling the search for trailing
			" empty lines..
			let s:lineStop = s:FindPureBlockEnd(a:startPattern, a:endPattern,
				\ s:SEARCH_PAIR_IMMEDIATELY, s:FALSE)

			" Stop on Error
			if s:lineStop == 0
				break
			endif

			" Do something with the potential fold based on the Mode we're in
			call s:HandleFold()
		else
			break
		endif

		" Goto fold start (remember we're searching upwards)
		exec s:lineStart
	endwhile

	if s:foldingMode != s:MODE_REMEMBER_FOLD_SETTINGS
    	" Remove created folds
	    normal zR
    endif
endfunction
" }}}
function! s:PHPFoldProperties(startPattern, endPattern, ...) " {{{
	let s:searchPhpDocLineCount = g:searchPhpDocLineCount
	let s:searchEmptyLinesPostfixing = g:searchEmptyLinesPostfixing
	let s:currentPhpDocMode = s:FOLD_WITH_PHPDOC
	if a:0 >= 1
		" Do we also put the PHP doc part in the fold?
		let s:currentPhpDocMode = a:1
	endif
	if a:0 >= 2
		" How far do we want to look for PhpDoc comments?
		let s:searchPhpDocLineCount = a:2
	endif
	if a:0 == 3
		" How greedy are we on postfixing empty lines?
		let s:searchEmptyLinesPostfixing = a:3
	endif

	" Move to end of file
	exec s:fileLineCount

	" Loop through file, searching for folds
	while 1
		let s:lineStart = s:FindPatternStart(a:startPattern)

		if s:lineStart != 0
			let s:lineStart = s:FindOptionalPHPDocComment()
			let s:lineStop = s:FindPatternEnd(a:endPattern)

			" Stop on Error
			if s:lineStop == 0
				break
			endif

			" Do something with the potential fold based on the Mode we're in
			call s:HandleFold()
		else
			break
		endif

		" Goto fold start (remember we're searching upwards)
		exec s:lineStart
		
	endwhile

	if s:foldingMode != s:MODE_REMEMBER_FOLD_SETTINGS
    	" Remove created folds
	    normal zR
    endif
endfunction
" }}}
function! s:HandleFold() " {{{
	if s:foldingMode == s:MODE_REMEMBER_FOLD_SETTINGS
		" If we are in an actual fold..,
		if foldlevel(s:lineStart) != 0
			" .. and it is not closed..,
			if foldclosed(s:lineStart) == -1
                " .. and it is more then one lines
                " (it has to be or it will be open by default)
                if s:lineStop - s:lineStart >= 1
                    " Remember it as an open fold
                    let s:foldsOpenedList{s:openFoldListItems} = s:lineStart
                    let s:openFoldListItems = s:openFoldListItems + 1
                endif
			endif
		endif

		" If the cursor is inside the fold, it needs to be opened
		if s:lineStart <= s:savedCursor && s:lineStop >= s:savedCursor
			" Remember it as an open fold
			let s:foldsOpenedList{s:openFoldListItems} = s:lineStart
			let s:openFoldListItems = s:openFoldListItems + 1
		endif
		
	elseif s:foldingMode == s:MODE_CREATE_FOLDS
		" Correct lineStop if needed (the script might have mistaken lines
		"   beyond the file's scope for trailing empty lines)
		if s:lineStop > s:fileLineCount
			let s:lineStop = s:fileLineCount
		endif
		" Create the actual fold!
		exec s:lineStart . "," . s:lineStop . "fold"
		let s:foldsCreated = s:foldsCreated + 1
	endif
endfunction
" }}}
function! s:FindPureBlockStart(startPattern) " {{{
	" When the startPattern is 'function', this following search will match:
	"
	" function foo($bar) {			function foo($bar)
	" {
	"
	" function foo($bar)			function foo($bar1,
	" .. {								$bar2)
	"								{
	"
	"return search(a:startPattern . '.*\%[\n].*{', 'W')
	"return search(a:startPattern . '.*\%[\n].*\%[\n].*{', 'bW')

	" This function can match the line its on *again* if the cursor was
	" restored.. hence we search twice if needed..
	let currentLine = line('.')
	let line = search(a:startPattern . '.*\%[\n].*\%[\n].*{', 'bW')
	if currentLine == line
		let line = search(a:startPattern . '.*\%[\n].*\%[\n].*{', 'bW')
	endif
	return line
endfunction
" }}}
function! s:FindPatternStart(startPattern) " {{{
	" This function can match the line its on *again* if the cursor was
	" restored.. hence we search twice if needed..
	let currentLine = line('.')
	let line = search(a:startPattern, 'bW')
	if currentLine == line
		let line = search(a:startPattern, 'bW')
	endif
	return line
endfunction
" }}}
function! s:FindOptionalPHPDocComment() " {{{
	" Is searching for PHPDoc disabled?
	if s:currentPhpDocMode == s:FOLD_WITHOUT_PHPDOC
		" .. Return the original Fold's start
		return s:lineStart
	endif

	" Skipover 'empty' lines in search for PhpDoc
	let s:counter = 0
	let s:currentLine = s:lineStart - 1
	while s:counter < s:searchPhpDocLineCount
		let line = getline(s:currentLine)
		if (matchstr(line, '^\s*$') == line)
			let s:currentLine = s:currentLine - 1
		endif
		let s:counter = s:counter + 1
	endwhile

	" Is there a closing C style */ on the above line?
	let checkLine = s:currentLine
	if strridx(getline(checkLine), "\*\/") != -1
		" Then search for the matching C style /* opener
		while 1
			if strridx(getline(checkLine), "\/\*") != -1
				" Only continue adjusting the Fold's start if it really is PHPdoc..
				"  (which is characterized by a double asterisk, like /**)
				if strridx(getline(checkLine), "\/\*\*") != -1
					" Also only continue adjusting if the PHPdoc opener does
					" not contain a '/**#@+'. Those type of comments are
					" supposed to match with a #@- ..
					if strridx(getline(checkLine), '#@+') == -1
						" .. Return this as the Fold's start
						return checkLine
					else
						break
					endif
				else
					break
				endif
			endif
			let checkLine = checkLine - 1
		endwhile
	endif
	" .. Return the original Fold's start
	return s:lineStart
endfunction
" }}}
function! s:FindPureBlockEnd(startPair, endPair, searchStartPairFirst, ...) " {{{
	" Place Cursor on the opening pair/brace?
	if a:searchStartPairFirst == s:SEARCH_PAIR_START_FIRST
		let line = search(a:startPair, 'W')
	endif

	" Search for the entangled closing brace
	" call cursor(line, 1) " set the cursor to the start of the lnum line
	if s:extensiveBracketChecking == s:TRUE
		let line = searchpair(a:startPair, a:startPair, a:endPair, 'W', 'SkipMatch()')
	else
		let line = searchpair(a:startPair, a:startPair, a:endPair, 'W')
	endif
	if line == 0
		let line = search(a:endPair, 'W')
	endif
	if line == 0
		" Return error
		return 0
	endif

	" If the fold exceeds more than one line, and searching for empty lines is
	" not disabled..
	let foldExceedsOneLine = line - s:lineStart >= 1
	if a:0 == 1
		let emptyLinesNotDisabled = a:1
	else
		let emptyLinesNotDisabled = s:TRUE
	endif
	if foldExceedsOneLine && emptyLinesNotDisabled
		" Then be greedy with extra 'trailing' empty line(s)
		let s:counter = 0
		while s:counter < s:searchEmptyLinesPostfixing
			let linestr = getline(line + 1)		
			if (matchstr(linestr, '^\s*$') == linestr)
				let line = line + 1
			endif
			let s:counter = s:counter + 1
		endwhile
	endif

	return line
endfunction
" }}}
function! s:FindPatternEnd(endPattern) " {{{
	let line = search(a:endPattern, 'W')

	" If the fold exceeds more than one line
	if line - s:lineStart >= 1
		" Then be greedy with extra 'trailing' empty line(s)
		let s:counter = 0
		while s:counter < s:searchEmptyLinesPostfixing
			let linestr = getline(line + 1)		
			if (matchstr(linestr, '^\s*$') == linestr)
				let line = line + 1
			endif
			let s:counter = s:counter + 1
		endwhile
	endif

	return line
endfunction
" }}}

function! PHPFoldText() " {{{
	let currentLine = v:foldstart
	let lines = (v:foldend - v:foldstart + 1)
	let lineString = getline(currentLine)
	" See if we folded a marker
	if strridx(lineString, "{{{") != -1 " }}}
		" Is there text after the fold opener?
		if (matchstr(lineString, '^.*{{{..*$') == lineString) " }}}
			" Then only show that text
			let lineString = substitute(lineString, '^.*{{{', '', 'g') " }}}
		" There is text before the fold opener
		else
			" Try to strip away the remainder
			let lineString = substitute(lineString, '\s*{{{.*$', '', 'g') " }}}
		endif
	" See if we folded a DocBlock
	elseif strridx(lineString, '#@+') != -1
		" Is there text after the #@+ piece?
		if (matchstr(lineString, '^.*#@+..*$') == lineString)
			" Then show that text
			let lineString = substitute(lineString, '^.*#@+', '', 'g') . ' ' . g:phpDocBlockIncludedPostfix
		" There is nothing?
		else
			" Use the next line..
			let lineString = getline(currentLine + 1) . ' ' . g:phpDocBlockIncludedPostfix
		endif
	" See if we folded an API comment block
	elseif strridx(lineString, "\/\*\*") != -1
		" (I can't get search() or searchpair() to work.., therefore the
		" following loop)
		let s:state = 0
		while currentLine < v:foldend
			let line = getline(currentLine)
			if s:state == 0 && strridx(line, "\*\/") != -1
				" Found the end, now we need to find the first not-empty line
				let s:state = 1
			elseif s:state == 1 && (matchstr(line, '^\s*$') != line)
				" Found the line to display in fold!
				break
			endif
			let currentLine = currentLine + 1
		endwhile
		let lineString = getline(currentLine)
	endif
	
	" Some common replaces...
	" if currentLine != v:foldend
		let lineString = substitute(lineString, '/\*\|\*/\d\=', '', 'g')
		let lineString = substitute(lineString, '^\s*\*\?\s*', '', 'g')
		let lineString = substitute(lineString, '{$', '', 'g')
		let lineString = substitute(lineString, '($', '(..);', 'g')
	" endif

	" Emulates printf("%3d", lines)..
	if lines < 10
		let lines = "  " . lines
	elseif lines < 100
		let lines = " " . lines
	endif

	" Append an (a) if there is PhpDoc in the fold (a for API)
	if currentLine != v:foldstart
		let lineString = lineString . " " . g:phpDocIncludedPostfix . " "
	endif	

	" Return the foldtext
	return "+--".lines." lines: " . lineString
endfunction
" }}}
function! SkipMatch() " {{{
" This function is modified from a PHP indent file by John Wellesz
" found here: http://www.vim.org/scripts/script.php?script_id=1120
	if (!s:synIDattr_exists)
		return 0
	endif
	let synname = synIDattr(synID(line("."), col("."), 0), "name")
	if synname == "phpParent" || synname == "javaScriptBraces" || synname == "phpComment"
		return 0
	else
		return 1
	endif
endfun
" }}}

" Check filetype == php before automatically creating (fast) folds {{{1
function! s:CheckAutocmdEnablePHPFold()
    if &filetype == "php" && ! g:DisableAutoPHPFolding
        call s:EnableFastPHPFolds()
    endif
endfunction
" }}}

" Call CheckAutocmdEnablePHPFold on BufReadPost {{{1
augroup SetPhpFolds
    au!
    au BufReadPost * call s:CheckAutocmdEnablePHPFold()
augroup END
" }}}

" vim:ft=vim:foldmethod=marker:nowrap:tabstop=4:shiftwidth=4
