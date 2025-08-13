shortlink_domain := `echo "https://$(head -n1 CNAME)"`
shortlink_url_path := `yq '.collections | keys[0]' < _config.yml`
shortlink_dir := "_" + shortlink_url_path

default:
  @echo "Available commands:"
  @echo "  list: List all shortlinks"
  @echo "  add <url>: Add a new shortlink"
  @echo "  rm <shortlink>: Remove a shortlink"

list:
  #!/usr/bin/env bash
  column -t -s '|' <<< "$(find {{shortlink_dir}} -type f -name "*.md" | while read -r file; do
    shortlink="$(basename "${file}" .md)"
    url="$(grep 'goto:' "${file}" | cut -d ' ' -f2-)"
    shortlink_url="{{shortlink_domain}}/{{shortlink_url_path}}/${shortlink}"

    echo "${url} | ${shortlink_url} | ${shortlink}"
  done)"

search needle:
  #!/usr/bin/env bash
  needle="{{needle}}"

  if [ -z "${needle}" ]; then
    echo "Usage: just search <needle>"
    exit 1
  fi

  just list | grep -i "${needle}" || echo "No shortlinks found for '${needle}'"


add url:
  #!/usr/bin/env bash
  url="{{url}}"

  if [ -z "${url}" ]; then
    echo "Usage: just add <url>"
    exit 1
  fi

  shortlink="$(cat /dev/urandom | tr -dc 'a-z' | fold -w 6 | head -n 1)"
  shortlink_url="{{shortlink_domain}}/{{shortlink_url_path}}/${shortlink}"
  shortlink_file="{{shortlink_dir}}/${shortlink}.md"

  if [ -f "${shortlink_file}" ]; then
    echo "Shortlink ${shortlink_file} already exists. Please try again."
    exit 1
  fi

  cat <<EOF > "${shortlink_file}"
  ---
  goto: ${url}
  redirect_to: ${url}
  ---
  EOF

  echo "${url} -> ${shortlink_url}"

  git add {{shortlink_dir}}
  git commit -m "add: ${url} -> ${shortlink_url}"
  git push origin main


rm shortlink:
  #!/usr/bin/env bash
  shortlink="{{shortlink}}"

  if [ -z "${shortlink}" ]; then
    echo "Usage: just rm <shortlink>"
    exit 1
  fi

  shortlink_file="{{shortlink_dir}}/${shortlink}.md"
  if [ -f "${shortlink_file}" ]; then
    read -p "Are you sure you want to remove the shortlink '${shortlink}'? (y/n): " confirm
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
      rm "${shortlink_file}"
      echo "Removed shortlink: ${shortlink}"
      git add "${shortlink_file}"
      git commit -m "remove: ${shortlink} -> ${shortlink_file}"
      git push origin main
    fi
  else
    echo "Shortlink not found: ${shortlink}"
  fi
