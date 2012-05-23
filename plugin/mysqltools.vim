com! -nargs=? Dbopen :call DbOpen("<args>")
if (!exists("g:db_window_count"))
	let db_window_count = 0
endif

" open a database session with a particular server
fun! DbOpen(which)
	if a:which == ''
		let which = 'default'
	else
		let which = a:which
	end
	exe "tabe DB-".l:which
	call DbInstall()
	let b:which = l:which
	if has_key(g:db_credentials[b:which],'qFile')
		exe "r ".g:db_credentials[b:which]['qFile']
	endif
endfunction

" open a new query result window and execute a query in the session window
" Called when you hit ENTER in a query window.
fun! DbExecute()
	let query = getline('.')
	call DbExecuteQuery(l:query)
endfunction

" open a new query result window and execute a query highlighted in the session window
" Called when you hit ENTER in a query window.
fun! DbExecuteV() range
	let query = join(getline(a:firstline,a:lastline),' ')
	call DbExecuteQuery(l:query)
endfunction

" refresh a query result window
" Called when you hit ENTER in a result window.
fun! DbExecuteQ()
	normal ggdG
	call DbSendQuery(b:query)
endfunction

" open a new query result window and execute query
fun! DbExecuteQuery(query)
	let g:db_window_count = g:db_window_count + 1
	let which = b:which
	exe 'new DB-'.g:db_window_count
	call DbInstall()
	nmap <buffer> <CR> :call DbExecuteQ()<CR>
	let b:which = l:which
	let b:query = a:query
	normal J
	setl buftype=nofile
	setl nowrap
	setfiletype mysqlresult
	call DbSendQuery(a:query)
endfunction

" execute query
fun! DbSendQuery(query)
	let escapeChars = '%!#&'
	let db_user = g:db_credentials[b:which]['user']
	let db_pass = g:db_credentials[b:which]['pass']
	let db_host = g:db_credentials[b:which]['host']
	let query = escape(shellescape('use '.g:db_credentials[b:which]['db'].'; '.a:query),l:escapeChars)
	"let @z = "Query:\n".a:query."\n\nResult:"
	let @z = "Result:"
	normal "zPG
	exe "r !mysql -u ".db_user." -h ".db_host." --password=".escape(db_pass,l:escapeChars)." -t -v -v -v -e ".l:query
	normal gg
endfunction

" 'install' shortcuts for mysql windows
fun! DbInstall()
	setl filetype=mysql
	setl buftype=nofile
	nmap <buffer> <leader>md :call DbExecuteQuery('desc '.expand('<cword>'))<CR>
	nmap <buffer> <CR> :call DbExecute()<CR>
	vmap <buffer> <CR> :call DbExecuteV()<CR>
endfunction
