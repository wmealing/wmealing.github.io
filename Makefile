all:
	pipx install sitemap_maker
	sitemap_maker --url https://wmealing.bluegum.systems/ \
    		--sitemap output.xml \
	    	--depth 2 \
 		--max 500 \
	   	--no_pound \
   		--verbose
	# sitemap_maker joins the base URL (trailing slash) with paths that
	# also lead with a slash, emitting https://wmealing.bluegum.systems//page.html.
	# Those are distinct URLs to Google and are not the ones we link, so
	# collapse them back before publishing.
	sed -i '' 's#<loc>https://wmealing.bluegum.systems//#<loc>https://wmealing.bluegum.systems/#g' output.xml
	mv output.xml sitemap.xml
	escript generate-rss.escript
