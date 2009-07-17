all : tunnelgame.swf

DEBUGGING = true

tunnelgame.swf : \
	Bullet.as \
	Controller.as \
	Enemy.as \
	EnemyBullet.as \
	FontCollection.as \
	HUD.as \
	IntersectionResult.as \
	Particle.as \
	ScoreKeeper.as \
	Ship.as \
	ShipBullet.as \
	Tunnel.as \
	World.as \
	tunnelgame.as
	mxmlc -define=CONFIG::debugging,$(DEBUGGING) -default-size 480 480 -default-frame-rate 30 tunnelgame.as

clean :
	rm -fv tunnelgame.swf
