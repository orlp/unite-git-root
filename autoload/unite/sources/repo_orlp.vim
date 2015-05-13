let s:save_cpo = &cpo
set cpo&vim

" We call this to make sure g:unite_source_rec_git_command exists.
call unite#sources#rec#define()

let s:git_repo = {
  \ 'name' : 'file_rec/git_repo',
  \ 'description' : 'candidates from git repository, recursive',
  \ 'hooks' : {},
  \ 'default_kind' : 'file',
  \ 'max_candidates' : 50,
  \ 'ignore_globs' : [
  \         '.', '*~', '*.o', '*.exe', '*.bak',
  \         'DS_Store', '*.pyc', '*.sw[po]', '*.class',
  \         '.hg/**', '.git/**', '.bzr/**', '.svn/**',
  \         'tags', 'tags-*'
  \ ],
  \ 'matchers' : ['matcher_default', 'matcher_hide_hidden_files'],
  \ }

function! s:git_repo.gather_candidates(args, context)
    let a:context.is_async = 0

    if !unite#util#has_vimproc()
        call unite#print_source_message('vimproc plugin is not installed.', self.name)
        return []
    endif

    let git_dir = finddir('.git', ';')
    if git_dir == ''
        " Not in git directory.
        call unite#print_source_message('Not in git repository.', self.name)
        return []
    endif

    let directory = fnamemodify(git_dir, ':p:h:h')
    let directory_normpath = unite#util#substitute_path_separator(directory)
    let a:context.source__directory = directory_normpath . '/'

    call unite#print_source_message('repository: ' . directory_normpath, self.name)

    let command = g:unite_source_rec_git_command .
              \ ' ls-files --full-name ' . join(a:args) . ' ' . shellescape(directory)
    let paths = split(vimproc#system2(command), '\n')

    return map(paths, "{
           \   'word' : v:val,
           \   'action__path' : a:context.source__directory . v:val,
           \ }")
endfunction

function! unite#sources#repo_orlp#define()
    return s:git_repo
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo