
all:
	pipx install sitemap_maker
	sitemap_maker --url https://wmealing.github.io/ \
    		--sitemap output.xml \
	    	--depth 1 \
 		--max 5 \
	   	--no_pound \
   		--verbose
	mv output.xml sitemap.xml 


