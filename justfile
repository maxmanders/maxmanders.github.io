list:
  #!/usr/bin/env bash
  echo -e "Listing all short links:\n"
  column -t -s '->' <<< "$(find _l -type f -name "*.md" | while read -r file; do
    shortlink=$(basename "${file}" .md)
    url=$(grep 'goto:' "${file}" | cut -d ' ' -f2-)
    echo "${shortlink} -> ${url}"
  done)"

add url:
  #!/usr/bin/env bash
  url="{{url}}"

  shortlink="$(echo "${url}" | sha1sum | cut -c 1-8)"

  cat <<EOF > "_l/${shortlink}.md"
  ---
  goto: ${url}
  redirect_to: ${url}
  ---
  EOF

  echo "${url} -> https://maxm.link/l/${shortlink}"

  git add _l
  git commit -m "add: ${url} -> https://maxm.link/l/${shortlink}"
  git push origin main


remove shortlink:
  #!/usr/bin/env bash
  shortlink="{{shortlink}}"
  file="_l/${shortlink}.md"
  if [ -f "${file}" ]; then
    read -p "Are you sure you want to remove the shortlink '${shortlink}'? (y/n): " confirm
    if [[ "${confirm}" =~ ^[Yy]$ ]]; then
      rm "${file}"
      echo "Removed shortlink: ${shortlink}"
      git add "${file}"
      git commit -m "remove: ${shortlink}"
      git push origin main
    fi
  else
    echo "Shortlink not found: ${shortlink}"
  fi
