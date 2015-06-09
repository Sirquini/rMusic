require_relative 'platform'
include PlatformrM
require_relative "adapter/#{LIB}"
include Adapter

module RMSound
	NOTES_KEYS = {
		q: 1000,
		w: 1100,
		e: 1200,
		r: 1300,
		t: 1400,
		y: 1500,
		u: 1600,
		i: 1700,
		o: 1800,
		p: 1900,
		a: 100,
		s: 200,
		d: 300,
		f: 400,
		g: 500,
		h: 600,
		j: 700,
		k: 800,
		l: 900
	}

	def note_play(char)
		freq = nil
		freq = NOTES_KEYS[char.to_sym] unless NOTES_KEYS[char.to_sym] == nil
		Adapter::play_sound(freq) unless freq == nil
		freq != nil
	end

end
