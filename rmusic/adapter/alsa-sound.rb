# Adaptador para reproducir sonidos en linux, como
# dependencia debe de estar instalada la aplicacion
# Beep, en muchas distribuciones de linux se puede
# instalar usando el manejador de paquetes install beep
# para ubuntu y similares $ sudo apt-get install beep
module Adapter
	def play_sound(freq = 100, time = 500)
		system("beep -f #{freq}")
	end
end
