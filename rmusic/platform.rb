module PlatformrM
	# Permite cargar el manejador de sonido dependiendo de
	# la plataforma (windows o linux)
	# Basado en el script de arirusso para unimidi
	LIB = case RUBY_PLATFORM
        when /linux/ then "alsa-sound"
        when /mingw/ then "win-sound"
    end
    LIB ||= "win-sound"
end
