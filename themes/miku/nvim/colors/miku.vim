highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "miku"
let s:teal    = "#39c5bb"
let s:teal_lt = "#6fe0d9"
let s:blue    = "#5b8dff"
let s:blue_lt = "#84acff"
let s:purple  = "#c58aff"
let s:pink    = "#ff7d9c"
let s:yellow  = "#ffd866"
let s:cyan    = "#7df0c8"
let s:bg      = "#0b1226"
let s:bg_alt  = "#101a33"
let s:fg      = "#dcebff"
let s:dim     = "#7588ad"
let s:comment = "#56688c"

function! s:h(group, fg, bg, attr)
  let l:guifg = a:fg == "" ? "NONE" : a:fg
  let l:guibg = a:bg == "" ? "NONE" : a:bg
  let l:gui   = a:attr == "" ? "NONE" : a:attr
  exec "highlight " . a:group
        \ . " guifg=" . l:guifg
        \ . " guibg=" . l:guibg
        \ . " gui=" . l:gui
endfunction

call s:h("Normal",       s:fg,      s:bg,      "")
call s:h("NormalNC",     s:fg,      s:bg_alt,  "")
call s:h("EndOfBuffer",  s:bg,      s:bg,      "")
call s:h("Cursor",       s:bg,      s:teal,    "")
call s:h("CursorLineNr", s:teal,    s:bg,      "")
call s:h("LineNr",       s:dim,     s:bg,      "")
call s:h("Comment",      s:comment, "",        "italic")
call s:h("Constant",     s:cyan,    "",        "")
call s:h("String",       s:teal_lt, "",        "")
call s:h("Character",    s:teal_lt, "",        "")
call s:h("Number",       s:yellow,  "",        "")
call s:h("Float",        s:yellow,  "",        "")
call s:h("Boolean",      s:purple,  "",        "bold")
call s:h("Identifier",   s:blue,    "",        "")
call s:h("Function",     s:blue_lt, "",        "")
call s:h("Statement",    s:pink,    "",        "")
call s:h("Conditional",  s:pink,    "",        "")
call s:h("Repeat",       s:pink,    "",        "")
call s:h("Label",        s:purple,  "",        "")
call s:h("Operator",     s:teal,    "",        "")
call s:h("Keyword",      s:purple,  "",        "")
call s:h("Exception",    s:pink,    "",        "")
call s:h("PreProc",      s:purple,  "",        "")
call s:h("Include",      s:purple,  "",        "")
call s:h("Define",       s:purple,  "",        "")
call s:h("Macro",        s:purple,  "",        "")
call s:h("Type",         s:cyan,    "",        "")
call s:h("StorageClass", s:pink,    "",        "")
call s:h("Structure",    s:cyan,    "",        "")
call s:h("Typedef",      s:cyan,    "",        "")
call s:h("Special",      s:yellow,  "",        "")
call s:h("SpecialChar",  s:yellow,  "",        "")
call s:h("Tag",          s:teal_lt, "",        "")
call s:h("Delimiter",    s:dim,     "",        "")
call s:h("SpecialComment", s:comment, "", "italic")
call s:h("Debug",        s:yellow,  "",        "")
call s:h("Underlined",   s:blue_lt, "",        "underline")
call s:h("Ignore",       s:dim,     "",        "")
call s:h("Error",        s:bg,      s:pink,    "bold")
call s:h("Todo",         s:bg,      s:yellow,  "bold")
call s:h("Search",       s:bg,      s:teal,    "bold")
call s:h("MatchParen",   s:bg,      s:teal,    "bold")
call s:h("Visual",       s:fg,      "#1b2a4d", "")
call s:h("Directory",    s:teal_lt, "",        "")
call s:h("Title",        s:teal,    "",        "bold")
call s:h("Conceal",      s:dim,     "",        "")
call s:h("StatusLine",   s:bg,      s:teal,    "")
call s:h("StatusLineNC", s:dim,     s:bg_alt,  "")
call s:h("TabLineFill",  s:dim,     s:bg_alt,  "")
call s:h("TabLineSel",   s:bg,      s:teal,    "")
call s:h("TabLine",      s:dim,     s:bg_alt,  "")
call s:h("Pmenu",        s:fg,      s:bg_alt,  "")
call s:h("PmenuSel",     s:bg,      s:teal,    "")
call s:h("Folded",       s:dim,     s:bg_alt,  "italic")
call s:h("FoldColumn",   s:dim,     s:bg,      "")
call s:h("SignColumn",   s:dim,     s:bg,      "")
call s:h("ErrorMsg",     s:pink,    "",        "")
call s:h("WarningMsg",   s:yellow,  "",        "")
call s:h("VertSplit",    s:bg_alt,  s:bg_alt,  "")
call s:h("NonText",      s:bg_alt,  "",        "")
call s:h("SpecialKey",   s:bg_alt,  "",        "")
call s:h("CursorLine",   "",        s:bg_alt,  "")
call s:h("ColorColumn",  "",        s:bg_alt,  "")
call s:h("WildMenu",     s:bg,      s:purple,  "")
call s:h("MoreMsg",      s:teal_lt, "",        "")
call s:h("Question",     s:teal_lt, "",        "")
call s:h("ModeMsg",      s:teal,    "",        "")

call s:h("DiffAdd",    s:cyan,   s:bg_alt, "")
call s:h("DiffChange", s:yellow, s:bg_alt, "")
call s:h("DiffDelete", s:pink,   s:bg_alt, "")
call s:h("DiffText",   s:bg,     s:teal,   "")

call s:h("SpellBad",   s:pink,    "", "undercurl")
call s:h("SpellCap",   s:yellow,  "", "undercurl")
call s:h("SpellLocal", s:teal_lt, "", "undercurl")
call s:h("SpellRare",  s:purple,  "", "undercurl")

set termguicolors
if exists('*nvim_set_hl') || has('nvim')
  let g:terminal_color_0 = "#202640"
  let g:terminal_color_1 = "#ff7d9c"
  let g:terminal_color_2 = "#7df0c8"
  let g:terminal_color_3 = "#ffd866"
  let g:terminal_color_4 = "#5b8dff"
  let g:terminal_color_5 = "#c58aff"
  let g:terminal_color_6 = "#39c5bb"
  let g:terminal_color_7 = "#dcebff"
else
  let g:terminal_color_0  = "#202640"
  let g:terminal_color_1  = "#ff7d9c"
  let g:terminal_color_2  = "#7df0c8"
  let g:terminal_color_3  = "#ffd866"
  let g:terminal_color_4  = "#5b8dff"
  let g:terminal_color_5  = "#c58aff"
  let g:terminal_color_6  = "#39c5bb"
  let g:terminal_color_7  = "#dcebff"
endif