require 'win32/sound'
include Win32

# Adaptador para reproducir sonidos en windows, como
# dependencia debe de estar instalada la gema win32-sound
# la cual se puede instalar con gem install win32-sound
module Adapter
	def play_sound(freq = 100, time = 500)
		Sound.beep(freq, time) 
	end
end
