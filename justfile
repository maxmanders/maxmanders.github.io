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
