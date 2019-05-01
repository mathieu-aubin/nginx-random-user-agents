	# Automagic response to robots.txt requests
	location ~* (.*)/robots.txt {
		expires max;
		access_log off;
		log_not_found off;
		add_header Content-Type "text/plain";
		if (!-f $request_filename) {
			return 200 "# Automatically generated robots.txt ($date_gmt)\nUser-agent: *\nDisallow: $1/*\n\nHost: $scheme://$host\nCrawl-delay: 5\n";
		}
	}
