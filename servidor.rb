require 'socket'
require_relative 'rmusic/conexiones'

class Server
	# Utilidad para poder leer el perto al que escucha
	# el servidor.
	attr_reader :port, :server

	# Creamos un nuevo socket con el protocolo TCP/IP
	# El puerto de escucha del servidor es el puerto port
	def initialize(server="127.0.0.1", port = 2701)
		@serverSocket = TCPServer.new(server, port)
		@serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
		@server = server
		@port = port
		@clients = []
		puts "Server started on port #{port}"
	end

	# Loop principal que indica como tratar las 
	# conexiones aceptadas en un proceso distinto para
	# permitir concurrencia.
	def run
		puts "Server waiting for conncetions"
		loop do
			Thread.start(@serverSocket.accept) do |conection|
				# Agregamos al cliente a la lista de conectados si este no
				# esta en la lista
				(@clients <<  conection) unless @clients.include? conection
				# Registramos la conexion por consola
				puts "Conexion #{conection}"
				# Avisamos de la conexion exitosa
				conection.puts "m Conexion establecida"
				# Escuchamos los mensajes de la conexion
				listen_user(conection)
				# Quitamos la conexion
				@clients.delete(conection)
				# Avisamos en consola de la desconeccion
				puts "Desconexion #{conection}"
				# Cerramos el socket
				conection.close
			end
		end.join
	end

	# Escuchamos cualquier mensaje de un client
	def listen_user(client)
		loop do
			# Revisamos si la conexion se cerro
			break if client.eof?
			# optenemos el mensaje del cliente
			message = client.gets.chomp
			puts message
			# lo retransmitimos a todos los demas clientes
			broadcast(message)
		end
	end

	# Evia un message a todos los clientes conectados hasta el momento
	def broadcast(message)
		@clients.each do |client|
			client.puts message
		end
	end
end

# Inicialmente el puerto a escuchar, por defecto es el 2701
servidor = Server.new("localhost", Connections::SERVER_PORT)
# Corremos el servidor
servidor.run