
alias toj = to-json
alias toc = to-csv

alias la = ls -la
alias tk = taskell
alias btop = btop -lc
alias fdd = fd --type dir
alias fdf = fd --type file

alias top = btm --basic
alias stop = sudo btm --basic

alias cpu = btm --rate 500ms --expanded --default_widget_type cpu
alias mem = btm --rate 500ms --expanded --default_widget_type mem
alias net = btm --rate 500ms --expanded --default_widget_type net
alias proc = btm --rate 500ms --expanded --default_widget_type proc
alias temp = btm --rate 500ms --expanded --default_widget_type temp
alias disk = btm --rate 500ms --expanded --default_widget_type disk
alias batt = btm --rate 500ms --expanded --default_widget_type batt

alias sas = apt search
alias sai = sudo apt install -y
alias sar = sudo apt reinstall -y
alias saR = sudo apt remove -y
alias saa = sudo apt autoremove
alias sau = sudo apt update -y
alias saU = sudo apt upgrade -y
alias saf = sudo apt install --fix-broken
alias sal = sudo apt list --upgradable
alias sdc = sudo dpkg --configure -a
alias sdi = sudo dpkg --install

alias snap = sudo nala autopurge
alias snar = sudo nala autoremove
alias snf = sudo nala full-upgrade
alias snF = sudo nala full-upgrade -y
alias snh = sudo nala history
alias sni = sudo nala install -y
alias snl = sudo nala list
alias snp = sudo nala purge
alias snr = sudo nala remove
alias sns = sudo nala search
alias snS = sudo nala show
alias snu = sudo nala update
alias snU = sudo nala upgrade

alias ssS = sudo systemctl status
alias ssX = sudo systemctl stop
alias ssT = sudo systemctl start
alias ssE = sudo systemctl enable
alias ssD = sudo systemctl disable
alias ssR = sudo systemctl restart
alias ssZ = sudo systemctl suspend

alias suS = systemctl --user status
alias suX = systemctl --user stop
alias suT = systemctl --user start
alias suE = systemctl --user enable
alias suD = systemctl --user disable
alias suR = systemctl --user restart
alias suZ = systemctl --user suspend

alias pyi = uv tool install
alias jsi = pnpm install --global
alias rsi = cargo install --locked
alias goi = go install

alias dcu = docker compose up
alias dcU = docker compose up --detach
alias dcd = docker compose down
alias dcD = docker compose down --volumes
alias dcl = docker compose logs
alias dcL = docker compose logs --follow
alias dcp = docker compose pull

alias lzg = lazygit
alias lzd = lazydocker

def completions [t] {
  {
    options: {
      case_sensitive: false,
      completion_algorithm: prefix,
      positional: false,
      sort: false,
    },
    completions: $t
  }
}

alias mo = mods

alias mos = mods --show-last
alias mor = mods --show-last --raw
alias moe = tempeditor --suffix .md (mor)
alias moc = mods --continue-last

def mop [...rest] { wl-paste | mo ...$rest }
def mocp [...rest] { wl-paste | moc ...$rest }

def molr [] { mods --list --raw }
def molc [] { completions (molr | parse "{value}\t{description}\t{time}") }

def moS [id: string@molc] { mods --show $id }
def moR [id: string@molc] { mods --show $id --raw }
def moE [id: string@molc] { tempeditor --suffix .md (moR $id) }
def moC [id: string@molc, ...rest] { mods --continue $id ...$rest }
def moP [id: string@molc, ...rest] { wl-paste | mods --continue $id ...$rest }

alias xcp = xclip -i -selection clipboard
alias xps = xclip -o -selection clipboard

alias wcp = wl-copy
alias wps = wl-paste


alias vieb = browser vieb
alias brave = browser brave
alias chrome = browser chrome

alias vle = vieb --left
alias vri = vieb --right

alias bra = brave --dir a
alias brb = brave --dir b

alias dn = dir new
alias fn = file new
alias fo = file open
alias frn = file rn
alias frm = file rm
alias fmv = file mv

alias suk = srv user kanata
alias srm = srv root mouseless

alias snips = ssh snips.sh

alias unzipd = ^unzip -d
alias unrarx = ^unrar x

alias untar = ^tar -xvf
alias untargz = ^tar -xzvf
alias untarbz2 = ^tar -xjvf
alias untarxz = ^tar -xJvf

alias zipdir = ^zip -r
alias targz = ^tar -czvf
alias tarbz2 = ^tar -cjvf
alias tarxz = ^tar -cJvf

alias lih = list-images -p half
alias liq = list-images -p quarter
alias lik = list-images -p kitty
alias lii = list-images -p iterm2
alias lis = list-images -p sixel

alias gru = ghub repos update
alias grU = ghub repo update
alias gis = ghub index-set

alias nvchad = neovim run NvChad

alias cnc = connect cmd
alias cnj = connect jump
alias cns = connect shell
alias cnf = connect copy-files
alias cnk = connect copy-key
alias cnm = connect mount
alias cnu = connect umount
alias cnS = connect setup

alias cbr = clipboard receiver
alias cbw = clipboard watch

alias htg = http get
alias htp = http post
alias htu = http put
alias htc = http patch
alias htD = http delete
alias hth = http head
alias hto = http options
alias htd = http download

alias cho = chown
alias chm = chmod
alias chx = chmod '+x'

alias ytf = yt-dlp -N 100
alias ytd = yt-dlp -N 100 --paths temp:"/tmp/yt-dlp" --batch-file

alias rcs = rclone copy --transfers=1 --size-only --progress
alias rcm = rclone copy --transfers=1 --size-only --progress --metadata
alias rcopy = rclone copy --size-only --progress --metadata

def mpvc [video: path, --crop(-c): string = "200:0"] {
  mpv --audio-channels=stereo --sub-visibility=no --video-crop=($crop) $video
}

def mpvz [video: path, --zoom(-z): float = 0.2] {
  mpv --audio-channels=stereo --sub-visibility=no --video-zoom=($zoom) $video
}

alias fuzzy = fzf --reverse --style full --preview "bat --color=always --style=numbers --line-range=:500 {}"

alias irc = input-remapper-control --command autoload
