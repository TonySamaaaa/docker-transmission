# docker-transmission

### How to run

	docker run -d --restart always \
	  -p 127.0.0.1:9091:9091 -p 51413:51413 -p 51413:51413/udp \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /data/transmission/watch:/watch \
	  -v /data/transmission/downloads:/downloads \
	  --name transmission tonysamaaaa/transmission

#### or

	curl -L "https://raw.githubusercontent.com/TonySamaaaa/docker-transmission/master/config/settings.json" \
	  -o /data/docker/transmission/config/settings.json
	docker run -d --restart always \
	  -v /etc/localtime:/etc/localtime:ro \
	  -v /data/docker/transmission:/config \
	  -v /data/transmission/watch:/watch \
	  -v /data/transmission/downloads:/downloads \
	  --network host --name transmission tonysamaaaa/transmission

### References

 - https://www.v2ex.com/t/341132?p=1#r_4053423
 - https://blog.zscself.com/posts/66b00f02/