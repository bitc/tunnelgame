all : tunnelgame.swf

DEBUGGING = true

tunnelgame.swf : \
	Bullet.as \
	Controller.as \
	Enemy.as \
	EnemyBoss1.as \
	EnemyBullet.as \
	FontCollection.as \
	GUIButton.as \
	GUIWindow.as \
	HUD.as \
	IntersectionResult.as \
	MainMenu.as \
	Particle.as \
	PauseMenu.as \
	Preloader.as \
	ScoreKeeper.as \
	Ship.as \
	ShipBullet.as \
	Tunnel.as \
	World.as \
	tunnelgame.as
	mxmlc -define=CONFIG::debugging,$(DEBUGGING) -default-size 480 480 -default-frame-rate 30 tunnelgame.as

clean :
	rm -fv tunnelgame.swf
