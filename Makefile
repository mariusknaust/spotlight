install:
	install -m755 -D spotlight.sh ${DESTDIR}/bin/spotlight.sh
	install -m644 -D spotlight.service ${DESTDIR}/share/systemd/user/spotlight.service
	install -m644 -D spotlight.timer ${DESTDIR}/share/systemd/user/spotlight.timer
	install -m644 -D spotlight.desktop ${DESTDIR}/share/applications/spotlight.desktop
