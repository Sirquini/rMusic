require 'socket'
require_relative 'rmusic/conexiones'

class Server
	# Utilidad para poder leer el perto al que escucha
	# el servidor.
	attr_reader :port, :server

	# Creamos un nuevo socket con el protocolo TCP/IP
	# El puerto de escucha del servidor es el puerto port
	def initialize(server="127.0.0.1", port = 2701, share_server = false)
		@serverSocket = TCPServer.new(server, port)
		@serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
		@server = server
		@port = port
		@master = server == Connections::SERVER_IP[0]
		@sync = share_server
		@arry_ips = Connections::SERVER_IP
		@clients = []
		puts "Server started on port #{port}"
		send_servers
		listen_servers
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
				conection.puts "i Conexion establecida"
				# Enviamos la lista de servidores
				conection.puts "m " << Connections::SERVER_IP.join(" ") if @master
				conection.puts "s " << @arry_ips.join(" ") unless @master
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
			# Revisamos si es un mensaje
			if message[0] == "r"
				broadcast_message(message, client)
			else
				# lo retransmitimos a todos los demas clientes
				broadcast(message)
			end
		end
	end

	# Evia un message a todos los clientes conectados hasta el momento
	def broadcast(message)
		@clients.each do |client|
			client.puts message
		end
	end

	# Envia un mensaje a todos menos al usuario que envio el mensaje
	def broadcast_message(message, rclient)
		@clients.each do |client|
			client.puts message unless client == rclient
		end
	end

	# Envia a todos los servidores esclavos su lista de servidores
	def send_servers
		if @master && @sync
			puts "Sincronizando lista de servidores"
			# Abrimos un nuevo socket para sincronizar las listas de servidores
			miniSocket = TCPServer.new(@server, @port+1)
			miniSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
			slavesNum = Connections::SERVER_IP.length - 1
			slavesNum.times do
				res = IO.select([miniSocket], nil, nil, 10)
				if res != nil
					# Aceptamos el socket
					slave_server = miniSocket.accept
					# Enviamos la lista de servidores
					slave_server.puts(Connections::SERVER_IP.join(" "))
					# Cerramos la conexion
					slave_server.close
				end
			end
			puts "Sincronizacion terminada"
		end	
	end

	# Recibe una lista de servidores del servidor maestro
	def listen_servers
		unless @master && !@sync
			puts "Sincronizando lista de servidores"
			miniSocket = TCPSocket.new(Connections::SERVER_IP[0], @port+1)
			# Resivimos la lista de Servidores
			res = IO.select([miniSocket], [miniSocket], nil, 10)
			if res != nil
				@arry_ips = miniSocket.gets.chomp.split(" ")
			end
			puts "Sincronizacion terminada"
		end
	end
end

# Pedimos al usuario que ingrese la ip
user_ip = nil
user_sync = false
puts "Por Favor ingrese una ip o df:"
user_input = gets.chomp
user_ip = user_input unless user_input == "df"
user_ip ||= "127.0.0.1"

puts "Desea sincronizar servidores, solo funciona en el servidor maestro [y/n]:"
user_input = gets.chomp
user_sync = true if user_input == "y"

# Inicialmente el puerto a escuchar, por defecto es el 2701
servidor = Server.new(user_ip, Connections::SERVER_PORT, user_sync)
# Corremos el servidor
servidor.run
