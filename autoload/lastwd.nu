
let wd = ($env.HOME | path join '.last.wd')

$env.config = ($env.config | update hooks.env_change.PWD ($env.config.hooks.env_change.PWD | append {|_, dir|
  $dir | save -f $wd
}))

if ($env.ZELLIJ? | is-empty) {
  if ($wd | path exists) {
    let path = (open $wd | to text)
    if ($path | path exists) {
      cd $path
    }
  }
}
