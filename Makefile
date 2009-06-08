all : tunnelgame.swf

DEBUGGING = true

tunnelgame.swf : \
	tunnelgame.as \
	Controller.as \
	Ship.as \
	ShipBullet.as \
	Tunnel.as \
	World.as
	mxmlc -define=CONFIG::debugging,$(DEBUGGING) -default-size 480 480 -default-frame-rate 30 tunnelgame.as

clean :
	rm -fv tunnelgame.swf
