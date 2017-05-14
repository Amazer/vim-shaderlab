if exists('+omnifunc')
    if &omnifunc == ""
        setlocal omnifunc=shaderlabcomplete#Complete
    endif
endif

if exists('g:loaded_shaderlab_completion')
    finish
endif
let g:loaded_shaderlab_completion=1

echom 'cyc complete loaded'
" let s:cpo_save=&cpo
" set cpo&vim

let s:cache_name = []
let s:cache_list = []
let s:prepended = ''
let b:omni_syntax_minimum_length=0
let g:omni_syntax_ignorecase=1

function! s:getFiletypeKey()
    let filetype=substitute(&filetype, '\.','_','g')
    return filetype
endfunction

function! shaderlabcomplete#Complete(findstart, base)
    echom 'cyc complete invocated'.a:findstart.','.a:base
    if a:findstart
        " Locate the start of the item 
        let line = getline('.')
        let start = col('.') - 1
        let lastword = -1
        while start > 0
            " \k is keyword
            if line[start-1]=~ '\k'
                let start -=1
                let lastword=a:findstart
            else
                break
            endif
        endwhile

        if lastword == -1
            let s:prepended=''
            echom 'lastword==-1,prepended= '
            return start
        endif

        " 找到从已经输入的字符
        let s:prepended=strpart(line,start,(col('.')-1)-start)
        echom 'lastword=='.lastword.', prepended='.s:prepended
        return start
    endif

    
    let base=s:prepended
"     let matches=['cyc1','cyc2','cyc3']
"     return {'words':matches,'refresh':'always'}

    "以当前文件类型作为key，查看是否已经有缓存列表了
    let filetype = <SID>getFiletypeKey()
    let list_idx = index(s:cache_name, filetype, 0, &ignorecase)

    " 已经由此文件的缓存列表了
    if list_idx > -1
        let compl_list = s:cache_list[list_idx]
    else
        let compl_list   = OmniSyntaxList()
        let s:cache_name = add( s:cache_name,  filetype )
        let s:cache_list = add( s:cache_list,  compl_list )
    endif

    if base != ''
        " let compstr    = join(compl_list, ' ')
        " let expr       = (b:omni_syntax_ignorecase==0?'\C':'').'\<\%('.base.'\)\@!\w\+\s*'
        " let compstr    = substitute(compstr, expr, '', 'g')
        " let compl_list = split(compstr, '\s\+')

        " Filter the list based on the first few characters the user
        " entered
        let expr = 'v:val '.(g:omni_syntax_ignorecase==1?'=~?' : '=~#')." '^".escape(base, '\\/.*$^~[]').".*'"
        let compl_list = filter(deepcopy(compl_list), expr)
    endif

    return compl_list
endfunction

let s:cyc_cache_list=[]
function! OmniSyntaxList(...)
    let list_parms = []
    let saveL = @l
    let filetype = <SID>getFiletypeKey()

    if empty(list_parms)
        let lineCount=line('$')
        while lineCount>0
            let lineStr=getline(lineCount)
            let list_str=split(lineStr,'[^_a-zA-Z]\+')
            let lineCount-=1

            for item in list_str
                if index(s:cyc_cache_list,item) == -1
                    if item =~ '\k' && match(item,'^'.s:prepended)!=-1
                        call add(list_parms,item)
                    endif
                endif
            endfor

        endwhile
    endif
    return list_parms
endfunction


