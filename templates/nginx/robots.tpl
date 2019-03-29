	# Automagic response to robots.txt requests
	location ~ (.*)robots.txt {
		access_log off;
		expires max; log_not_found off;
		add_header Content-Type "text/plain";
		if (!-f $request_filename) {
			return 200 "# Automatically generated robots.txt\nUser-agent: *\nDisallow: $1\n";
		}
	}
