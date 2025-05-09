
def 'chmod nu_base' [] {
  chmod '+x' sh/shell.sh
  chmod '+x' sh/install.sh

  fd --type file --exec chmod 666 {}
  fd --type dir --exec chmod 755 {}
}

def trans [ ...text: string, --en(-e)] {
  let lang = if $en { ':en' } else { ':es' }
  docker run -it --rm soimort/translate-shell -b $lang ($text | str join ' ')
}

def 'nu gitignore list' [] {
  http get 'https://www.toptal.com/developers/gitignore/api/list?format=lines' | lines
}

def gitignore [lang: string@'nu gitignore list'] {
  http get $'https://www.toptal.com/developers/gitignore/api/($lang)' | save .gitignore
}

def help! [cmd?: string] {
  let pipe = $in

  if $pipe != null {
    $pipe | bat --plain --language help
    return
  }

  if $cmd != null {
    if (which bat | is-empty) {
      ^$cmd --help
    } else {
      (^$cmd --help | bat --plain --language help)
    }
    return
  }
}

def --env scd [] {
  let path = gum file --file --directory
  if ($path | path type) == 'file' {
    hx $path
  } else if ($path | path type) == 'dir' {
    cd $path
  }
}

def "kill ps" [name = ""] {
  let list = (ps | where name =~ $name)
  let name = ($list | get name | gum filter --select-if-one ...$in)
  if ($name | is-empty) {
    return
  }
  let process = ($list | where name == $name)
  if ($process | is-empty) {
    return
  }
  kill --force ($process | first | get pid)
}

def "kill port" [port: int] {
  let list = (lsof -i :($port) | from ssv -m 1)
  if ($list | is-empty) {
    return
  }
  let name = ($list | get COMMAND | gum filter --select-if-one ...$in)
  if ($name | is-empty) {
    return
  }
  let process = ($list | where COMMAND == $name)
  if ($process | is-empty) {
    return
  }
  kill --force ($process | first | get PID | into int)
}

def sqlite [database: string] {
   litecli $database --auto-vertical-output
}

def mysql [] {
  let dsn = $'mysql://($env.SQL_USER):($env.SQL_PASS)@($env.SQL_HOST):($env.SQL_PORT)/($env.SQL_NAME)'
  print $dsn
  mycli $dsn --auto-vertical-output
}

def redis [...cmd: string] {
  let url = $"redis://:($env.REDIS_PASS)@($env.REDIS_HOST):($env.REDIS_PORT)"
  if ($cmd | is-empty) {
    iredis --url $url
  } else {
    iredis --url $url --raw ($cmd | str join ' ')
  }
}

def harsql [] {
  harlequin -a mysql -h $env.SQL_HOST -p $env.SQL_PORT -U $env.SQL_USER --password $env.SQL_PASS --database $env.SQL_NAME
}

def redis_del [cmd: string] {
   redis DEL (redis KEYS $cmd | lines | str join ' ')
}

def pastes [input: string, --save(-s): string] {
  if $input =~ "https://pastes.dev" {
    let path = ($input | url parse | get path)
    let url = ("https://api.pastes.dev" + $path)
    let body = http get $url
    if ($save | is-empty) {
      $body
    } else {
      $body | save -f $save
    }
  } else {
    curl -s -T $input https://api.pastes.dev/post
  }
}

def git-commit [...rest: string] {
  git commit -m ($rest | str join ' ')
}

def git-history [file: string] {
  let logs = (git log --pretty=format:"%h" -- $file | lines)
  for $commit in $logs {
    git show $"($commit):($file)" | bat -l go
  }
}

def --env git-show-filter [filter: string] {
  $env.GIT_EXTERNAL_DIFF = "difft --skip-unchanged --display inline"
  let commit_hash = git log -1 --pretty=format:"%H"
  git show --ext-diff  $commit_hash -- $"*($filter)*"
}

def "android debug start" [] {
  watch . --glob=**/*.kt {||
    sh gradlew assembleDebug
    sh gradlew installDebug
    adb shell am start -a android.intent.action.MAIN -c android.intent.category.LAUNCHER -n com.example.myapplication/.MainActivity
  }
}

def "android debug restart" [] {
  watch . --glob=**/*.kt {||
    sh gradlew assembleDebug
    adb install -r app/build/outputs/apk/debug/app-debug.apk
    adb shell am force-stop com.example.myapplication
    adb shell am start -n com.example.myapplication/.MainActivity
  }
}

def saup [] {
  sudo apt update -y;
  sudo apt upgrade -y
}

def confirm [...prompt: string] {
  try {
    gum confirm ($prompt | str join ' ')
  } catch {
    return false
  }
  return true
}

def select-file [] {
  let preview = 'bat --plain --number --color=always {}'
  return (fd --type file | fzf --layout reverse --border --preview $preview | str trim)
}

$env.SHOW_PATH = ($env.HOME | path join .show.txt)

def show [...filter: path] {
  if ($filter | is-empty) { return }
  $filter | save -f $env.SHOW_PATH
  bat --paging never --style header ...$filter
}

def showf [] {
  let filter = (fd --type file | gum filter --no-limit | lines)
  if ($filter | is-empty) { return }
  show ...$filter
}

def showd [dir: path] {
  let filter = (fd --type file . $dir | lines)
  if ($filter | is-empty) { return }
  show ...$filter
}

def showc [] {
  let filter = (open $env.SHOW_PATH | lines)
  if ($filter | is-empty) { return }
  show ...$filter
}

def showe [] {
  hx $env.SHOW_PATH
}

def "create camare" [] {
  # https://adityatelange.in/blog/android-phone-webcam-linux/
  sudo apt install v4l2loopback-dkms v4l2loopback-utils
  sudo modprobe -v v4l2loopback exclusive_caps=1 card_label="Android Webcam"
  let n = (ls /dev/video* | length)
  v4l2-ctl --list-devices
  scrcpy --no-video --no-playback --video-source=camera --camera-id=0 --camera-size=1920x1080 --v4l2-sink=/dev/video0
}

def --env y [...args] {
	let tmp = (mktemp -t "yazi-cwd.XXXXXX")
	yazi ...$args --cwd-file $tmp
	let cwd = (open $tmp)
	if $cwd != "" and $cwd != $env.PWD {
		cd $cwd
	}
	rm -fp $tmp
}

def gic [lang: string] {
  let output = 'clipboard.png'
  wl-paste | freeze --output $output --theme dracula --language $lang
  open $output | wl-copy
  rm $output
}

def mdns-scan [resolve: string] {
  let columns = [type interface protocol 'service name' 'service type' 'host name' scope ip port info]
  avahi-browse -p -t -r $resolve | rg '=' | from csv --noheaders --separator ';' | rename ...$columns
}

def 'adbx c' [] {
  let devices = (mdns-scan _adb-tls-connect._tcp)
  if ($devices | length) > 0 {
    let device = ($devices | where protocol == IPv4 | first)
    adb connect $"($device.ip):($device.port)"
  }
}

def 'adbx p' [] {
  let nameId = random chars -l 10;
  let password = random chars -l 10;
  let name = $'ADB_WIFI_($nameId)';

  $'WIFI:T:ADB;S:($name);P:($password);;' | qrencode -t ANSI -m 1

  loop {
    let devices = (mdns-scan _adb-tls-pairing._tcp)
    if ($devices | length) > 0 {
      let device = ($devices | where protocol == IPv4 | where 'service name' == $name | first)
      adb pair $"($device.ip):($device.port)" $password
      adbx c
      break
    }
    sleep 1sec
  }
}

def __zellij_sessions [] {
  zellij list-sessions | lines | parse "{value} {desc}"
  | update value {ansi strip}
}

def 'zellij drop' [ ...session: string@__zellij_sessions, --all(-a) ] {
  let select_sessions = if ($session | is-not-empty) {
    __zellij_sessions | where value in $session
  } else if $all {
    __zellij_sessions
  } else { [] }

  if ($select_sessions | length) == 0 {
    return
  }

  let active_sessions = ($select_sessions | where desc !~ 'EXITED' | get value)
  for $session in $active_sessions {
    zellij kill-session $session
  }

  let exited_sessions = ($select_sessions | get value)
  for $session in $exited_sessions {
    zellij delete-session --force $session
  }
}

def 'rfzf' [query: string = ''] {
  rm -f /tmp/rg-fzf-{r,f}
  let RG_PREFIX = "rg --column --line-number --no-heading --color=always --smart-case "
  let INITIAL_QUERY = "${*:-}"
  let args = [
    --ansi --disabled --query $"($query)"
    --bind $"start:reload:($RG_PREFIX) {q}"
    --bind $"change:reload:sleep 0.1; ($RG_PREFIX) {q} || true"
    --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
      echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
      echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"'
    --color "hl:-1:underline,hl+:-1:underline:reverse"
    --prompt '1. ripgrep> '
    --delimiter :
    --header 'CTRL-T: Switch between ripgrep/fzf'
    --preview 'bat --color=always {1} --highlight-line {2}'
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
    --bind 'enter:become(vim {1} +{2})'
  ]
  fzf ...$args
}

def list-images [
  ...images: string
  --pixelation(-p): string = "sixel"
  --search(-s): string = "."
  --max-depth(-m): int = 1
  --columns(-c): int
  --dir(-d): path = "."
] {
  let images = if ($images | is-not-empty) { $images } else {
    fd -e png -e jpg -e jpeg -d $max_depth $search $dir | lines
  }

  if ($images | is-empty) {
    return
  }

  let terminal_width = (term size | get columns)
  let is_wide_terminal = $terminal_width > 110
  let image_count = ($images | length)
  
  let grid_columns = if $columns != null { $columns } else {
    let max_images_per_row = if $image_count <= 2 { $image_count } else { 2 }
    if $is_wide_terminal { $max_images_per_row * 2 } else { $max_images_per_row }
  }

  timg --title --pixelation $pixelation --grid $grid_columns ...$images
}

def --wrapped dockerctl [...rest] {
  if (ps | where name =~ dockerd | is-empty) {
    sudo ($env.DOCKER_BIN | path join dockerd)
  }
  if ($env.DOCKER_BIN | path join docker | path exists) {
    bash -c ($env.DOCKER_BIN | path join docker) ...$rest
  }
}

def ventoy [] {
  bash -c $"($env.VENTOY_PATH | path join VentoyGUI.x86_64)"
}

def remote-mouse [] {
  bash -c $"($env.REMOTE_MOUSE_PATH | path join RemoteMouse)"
}

def ftpd [] {
  ftpserver -conf ~/.config/ftpserver/ftpserver.json
}

def cosmic-config-backup [] {
  let cosmic = ($env.HOME | path join cosmic)
  mkdir $cosmic

  for file in (git -C ($env.HOME | path join .config/cosmic) status --short  | parse "{_}  {files}" | get files) {
    let dirname = ($file | path dirname)
    let basename = ($file | path basename)
    mkdir ($cosmic | path join $dirname)
    cp $file ($cosmic | path join $dirname $basename)
  }
}

def create-phone-backup [] {
  rclone copy --multi-thread-streams 1 -P -M anthony-android-work:/DCIM/Camera ~/Backup/
  rclone copy --multi-thread-streams 1 -P -M anthony-android-work:/Backup/ ~/Backup/

  rclone copy --multi-thread-streams 1 -P -M anthony-android-home:/DCIM/ ~/Backup/DCIM/
  rclone copy --multi-thread-streams 1 -P -M anthony-android-home:/Backup/Apps/ ~/Backup/Apps/
}

def create-commit [] {
  let prompt = "Generate a git commit message following this structure:
1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Examples:
feat: add user auth system

- Add JWT tokens for API auth
- Handle token refresh for long sessions

fix: resolve memory leak in worker pool

- Clean up idle connections
- Add timeout for stale workers

Simple change example:
fix: typo in README.md

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

Here's the diff:"

  let diff = git diff --cached --diff-algorithm=minimal
  git commit -e -m ($diff | mods --no-cache $prompt)
}

def transfer [path: path] {
  if not ($path | path exists) {
    return
  }
  let filename = if ($path | path type) == "file" { $path } else {
    let basename = ($path | path basename) + ".zip"
    let dirname = ($env.TMP_PATH_DIR | path join $basename)
    ^zip -q -r $dirname $path
    $dirname
  }
  let url = (open $filename | curl --silent --show-error --progress-bar --upload-file - $"https://transfer.sh/($filename)")
  echo $url
}

def nf [name: string] {
  let dir = (fd -t d | fzf)
  hx ($dir | path join $name)
}

def nd [name: string] {
  let dir = (fd -t d | fzf)
  mkdir ($dir | path join $name)
}

def paths [
  --path(-p): string = ".",
  --search(-s): string
  --type(-t): string
  ] {
  mut paths = []
  if ($search != null) {
    $paths = if ($type != null) {
      fd  --hidden --type $type $search --full-path $path | lines
    } else { fd  --hidden  $search --full-path $path | lines }
  } else {
    let list = ls -la $path
    $paths = if ($type != null) {
      $list | where type == $type | get name
    } else { $list | get name }
  }
  return $paths
}

def tempeditor [data: any, --suffix(-s): string = "", --output(-o)] {
  if ($data | str trim | is-empty) {
    return
  }

  let temp = mktemp --tmpdir --suffix $suffix
  $data | str trim | save --force $temp
  hx $temp

  if $output {
    return (open $temp | str trim)
  }
}

def rn [
  path: string = ".",
  basename?: string,
  --search(-s): string,
  --file(-f),
  --dir(-d),
] {
  if not ($path | path exists) {
    print "La ruta especificada no existe."
    return
  }

  let type = if $file { "file" } else if $dir { "dir" } else { null }
  if ($path != ".") and ($search == null) and ($type == null) {
    let destination_path = if ($basename | is-empty) {
      gum input --header "Rename" --value ($path | path basename)
    } else {
      ($path | path dirname | path join $basename)
    }
    mv $path $destination_path
    return
  }

  let list_paths = paths -p $path -s $search -t $type
  if ($list_paths | is-empty) {
    print "No hay elementos para renombrar."
    return
  }

  let renamed_paths = (tempeditor $list_paths --suffix .txt --output | lines)
  if ($renamed_paths | length) != ($list_paths | length) {
    print "No hay el mismo numero de elementos para renombrar."
    return
  }

  for index in ($list_paths | enumerate | get index) {
    let source = ($list_paths | get $index)
    let destination = ($renamed_paths | get $index)
    if $source != $destination {
      mv -i $source $destination
    }
  }
}

def xrm [
  path: string = ".",
  --search(-s): string,
  --file(-f),
  --dir(-d),
] {
  if not ($path | path exists) {
    print "La ruta especificada no existe."
    return
  }

  let type = if $file { "file" } else if $dir { "dir" } else { null }
  let list_paths = paths -p $path -s $search -t $type
  if ($list_paths | is-empty) {
    print "No hay elementos para eliminar."
    return
  }

  let selected_paths = (tempeditor $list_paths --suffix .txt --output | lines)
  if ($selected_paths | length) == ($list_paths | length) {
    print "Hay el mismo numero de elementos no se eliminara nada."
    return
  }

  let deleted_paths = ($list_paths | where { |it| $it not-in $selected_paths })
  for path in $deleted_paths {
    rm -rf $path
  }
  return $deleted_paths
}

def asr [] {
  job spawn {|| audiosource run}
}

export def sshkeygen [] {
  ssh-keygen -t ed25519
}

export def xpaint [--deps(-d)] {

  if $deps {
    pip3 install torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121
    # pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121


    # sudo ubuntu-drivers autoinstall
    # ubuntu-drivers devices
    # 


    pip3 install iopaint
    pip3 install onnxruntime
    pip3 install rembg
    pip3 install gfpgan
    pip3 install realesrgan
    pip3 install realesrgan
  }

  # ^iopaint install-plugins-packages

  let args = [
    --model=Sanster/PowerPaint-V1-stable-diffusion-inpainting
    --device=cuda

    # --enable-interactive-seg
    # --interactive-seg-model=sam2_1_base
    # --interactive-seg-device=cuda

    # --enable-gfpgan
    # --gfpgan-device=cuda

    # --enable-realesrgan
    # --realesrgan-model=RealESRGAN_x4plus
    # --realesrgan-device=cuda

    # --enable-remove-bg
    # --remove-bg-model=briaai/RMBG-1.4
    # --remove-bg-device=cuda

    # --enable-restoreformer
    # --restoreformer-device=cuda

    --host=0.0.0.0
    # --port=8080
  ]
  CUDA_VISIBLE_DEVICES="0,1,2" ^iopaint start ...$args
}

def rain-watch [] {
  mut last_clipboard = ""
  loop {
    let clipboard = (wl-paste | str trim)
    if ($clipboard != $last_clipboard) and ($clipboard | str contains "magnet") {
      print "Se detectó un enlace magnet."
      rain client add --stop-after-download --torrent $clipboard
      $last_clipboard = $clipboard
    }
    sleep 5sec
  }
}

def to-repo [] {
  url parse | get path | path split | skip | first 2 | path join
}
