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
