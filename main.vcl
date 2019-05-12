
# TODO: brotli etc
# TODO: table for url redirects
# TODO: table (edge dictionary?) to proxy dynamic stuff to some origin server
# TODO: suitable hash key + shielding + purge all on update

table type {
  "html": "text/html",
  "txt":  "text/plain",
  "css":  "text/css",
  "js":   "text/javascript",
}

sub vcl_recv {
#FASTLY recv

  error 200 "OK";
}

sub vcl_error {
  if (obj.status == 200) {
	declare local var.url STRING;
	declare local var.index STRING;
	set var.url = urldecode(req.url.path);
	set var.index = regsub(var.url, "/?$", "/index.html");
    set obj.http.content-type = table.lookup(type, req.url.ext, "text/html") "; charset=utf8";
    synthetic table.lookup(body, var.url,
      table.lookup(body, var.index,
        table.lookup(body, "/404.html", "404")));
    return (deliver);
  }
}

