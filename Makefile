
all:
	pipx install sitemap_maker
	sitemap_maker --url https://wmealing.github.io/ \
    		--sitemap output.xml \
	    	--depth 2 \
 		--max 500 \
	   	--no_pound \
   		--verbose
	mv output.xml sitemap.xml
	escript generate-rss.escript


