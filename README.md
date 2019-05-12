# Kate's static website generator

I don't want to run a web server because my sites are such low traffic that they'd always
be absent from cache, and need fetching every time. But code is free, so I made a static
site generator to convert a directory of files to a VCL table, and index it by URL.

This isn't a generator so much as an uploader. You need to provide your own directory
of files.

## Features

- 404 page
- Default to /index.html
- Binary content not supported
- You need `<base href="..."/>`

## What to do

1. Make a service, make an API key for that service
2. [Make a non-dynamic snippet](//docs.fastly.com/vcl/vcl-snippets/using-regular-vcl-snippets/#creating-a-regular-vcl-snippet) for [main.vcl](/main.vcl)
2. [Create a dynamic snippet](//docs.fastly.com/api/config#snippet) for the data:
```
; export SID= # service ID
; export KEY= # API key
; export VER= # unlocked (not yet activated) version
; curl -X POST -s https://api.fastly.com/service/$SID/version/$VER/snippet \
  -H "Fastly-Key:$KEY" -H 'Content-Type: application/x-www-form-urlencoded' \
  --data $'name=data&type=init&dynamic=1&content=table body {}\n'
{"name":"synth","type":"init","dynamic":1,"content":null,"service_id":"...",
 "version":"...","deleted_at":null,"id":"...","updated_at":"...","priority":100,
 "created_at":"..."}
```

   Remember the snippet ID there - you'll need it for updates.

3. Activate the service
4. Update whenever you feel like it:
```
; KEY=... SID=... SNIPPET=... ./update.sh /path/to/htdocs
```

## FAQ

Q. Why not use edge dictionaries?  
A. [The API](//docs.fastly.com/api/config#dictionary) doesn't provide a “replace everything in one go” operation.
   Also they render to VCL anyway; here I can generate the same VCL in the first place.

