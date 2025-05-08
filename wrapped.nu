
def --wrapped 'adb d' [ ...rest ] {
  adb devices ...$rest
}

def --wrapped 'adb c' [ ...rest ] {
  adb connect ...$rest
}

def --wrapped 'adb p' [ ...rest ] {
  adb pair ...$rest
}

def gradlew_tasks [] {
  let script = ($env.PWD | path join gradlew)
  if ($script | path exists) {
    return (bash $script tasks | rg ' - ' | parse '{value} - {description}')
  }
  return []
}

def --wrapped gradlew [ task: string@gradlew_tasks, ...rest ] {
  let script = ($env.PWD | path join gradlew)
  if ($script | path exists) {
    bash $script $task ...$rest
  } else {
    print "Gradlew script not found"
  }
}

def --wrapped sail  [...rest ] {
  let script = ($env.PWD | path join vendor/bin/sail)
  if ($script | path exists) {
    bash $script ...$rest
  } else {
    print "Sail script not found"
  }
}

def tunnel [port: int] {
  cloudflared tunnel --url http://localhost:($port)
}
