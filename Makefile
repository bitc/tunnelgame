all : tunnelgame.swf

tunnelgame.swf : tunnelgame.as Tunnel.as Controller.as Ship.as
	mxmlc -default-size 480 480 -default-frame-rate 30 tunnelgame.as

clean :
	rm -fv tunnelgame.swf
