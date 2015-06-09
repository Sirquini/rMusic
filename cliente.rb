require 'socket'
require_relative 'rmusic/conexiones'
require_relative 'rmusic/sound'
include RMSound

class Client
	def initialize(server)
		@server = server
		@arry_ips = Connections::SERVER_IP
		@ip_integrity = "d"
		@request = nil
		@response = nil
		# Empezamos a escuchar al servidor
		listen
		# Empezamos a enviar al servidor
		send
		# Al terminar cerramos los Threads
		@request.join if @request.alive?
		@response.join if @response.alive?
		@server.close
	end

	# Metodo para enviar informacion al servidor
	def send
		@request = Thread.new do
			loop do
				# Optemenos la nota del teclado
				message = $stdin.gets.chomp
				# Revisamos si es un comando de salir
				if  message == "exit"
					@response.kill
					break
				end
				# Adicionamos que es una nota y lo enviamos al servidor
				@server.puts("n " << message) unless message.empty?
			end
		end
	end

	# Metodo para recivir informacion del servidor
	def listen
		@response = Thread.new do
			loop do
				# Optenemos el mensaje del servidor
				message = @server.gets.chomp
				# Optenemos el tipo
				message_t = message[0]
				# Quitamos los dos primeros caracteres
				message.slice!(0..1)
				# Revisamos si es un mensaje o una nota a reproducir
				if message_t == "i"
					# Mostramos el mensaje en consola
					puts message
				elsif message_t == "n"
					# Tomamos solo la nota y reproducimos su equivalente
					# Reproducimos la nota musical
					puts "Nota no valida [q-p][a-l]!" unless RMSound::note_play(message[0])
				elsif message_t == "s"
					# Resivimos una lista de ips de un esclavo
					# Actualizamos la lista interna si esta por defecto
					if @ip_integrity == "d"
						puts "Lista de IPs actualizada"
						@ip_integrity = "s"
						@arry_ips = message.split(' ')
					end
				elsif message_t == "m"
					# Resivimos una lista de ips de un maestro
					# Actualizamos la lista interna si esta por defecto
					if @ip_integrity != "m"
						puts "Lista de IPs actualizada"
						@ip_integrity = "m"
						@arry_ips = message.split(' ')
					end
				else
					# Mostramos el mensaje en consola
					puts "Desconocido: " << message
				end
			end
		end
	end
end

# Creamos el sockect de conexion
server = TCPSocket.new(Connections::SERVER_IP[0], Connections::SERVER_PORT)
# Corremos el cliente
cliente = Client.new server
