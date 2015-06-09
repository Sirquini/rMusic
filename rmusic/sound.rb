module WinSound
	require 'win32/sound'
	include Win32

	def play_sound(freq = 100, time = 500)
		Sound.beep(freq, time) 
	end

	NOTES_KEYS = {
		q: 100,
		w: 200,
		e: 300,
		r: 400,
		t: 500,
		y: 600,
		u: 700,
		i: 800,
		o: 900,
		p: 1000,
		a: 1100,
		s: 1200,
		d: 1300,
		f: 1400,
		g: 1500,
		h: 1600,
		j: 1700,
		k: 1800,
		l: 1900
	}

	def note_play(char)
		freq = nil
		freq = NOTES_KEYS[char.to_sym] unless NOTES_KEYS[char.to_sym] == nil
		play_sound(freq) unless freq == nil
		freq != nil
	end

end