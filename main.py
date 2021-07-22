# ==================================================================
# 	Grupo 4:
# 	- Gabriel Vitor de Jesus Lima
# 	- Marcus Vinicius Castelo Branco Martins
# 	- Pedro Guerra Lourenço
# ==================================================================
#	Funções criadas para teste do banco de dados em aplicação:
#	- 	Criar conta na aplicação (como contratante ou fotógrafo) usando CPF/CNPJ
#	- 	Logar em conta criada apenas com o ( CPF e tipo [contratante ou fotógrafo])
#	- 	Listar ofertas para Fotógrafo
#	- 	Listas fotógrafos para Contratante
# ==================================================================


import psycopg2
from dotenv import load_dotenv
import os
import sys
import re

cur = None  # cursor from db connection
conn = None	# db connection

# Function to connect to database
def dbConnect():
	global cur
	global conn
	try:
		conn = psycopg2.connect(
			host=os.environ['DB_HOST'],
			database=os.environ['DB_DATABASE'],
			user=os.environ['DB_USER'],
			password=os.environ['DB_PASSWORD'],
			port=os.environ['DB_PORT']
		)

		print('[INFO] Conectado ao banco de dados!')
		cur = conn.cursor()
	except:
		print('[ERRO] Erro ao conectar-se ao banco de dados')


# Function that formats documents according to the correct format (for now we have CPF and CNPJ formats)
def formatDocAs(type, userDoc):
	result = ''

	if type == 'cpf':
		# Format: 000.000.000-00
		result = userDoc[0:3] + '.' + userDoc[3:6] + \
			'.' + userDoc[6:9] + '-' + userDoc[9:11]
	elif type == 'cnpj':
		# Format: XX.XXX.XXX/0001-XX
		result = userDoc[0:2] + '.' + userDoc[2:5] + '.' + \
			userDoc[5:8] + '/' + userDoc[8:12] + '-' + userDoc[12:14]
	return result

# Function used to login user as photographer or contractor
def authAs(type):
	if type == 'c':
		userTable = 'Contratante'
		userDocField = 'doc_cont'
	else:
		userTable = 'Fotografo'
		userDocField = 'doc_fot'

	print('========== LOG-IN - {} =========='.format(userTable.upper()))
	userDocInput = input("Digite seu CPF ou CNPJ (somente números):\n>> ")

	# Query to check if user doc is in database. If it is, user can log in
	checkLoginQuery = 'SELECT * FROM {} WHERE {} = %(userDoc)s'.format(userTable, userDocField)
	
	cur.execute(checkLoginQuery, {'userTable': userTable, 'userDoc': userDocInput})
	result = cur.fetchall()
	
	if (len(result) == 0):
		print('CPF ou CNPJ não cadastrado na base de dados.')
		return False
	else:
		return True

# Function used to request user input
# They must choose if they're "fotografo" or "contratante"
def promptUserType(promptMessage):
	# returns c for contractor and f for photographer
	userType = '-'
	while len(userType) < 1 or userType.lower()[0] not in ['c', 'f']:
		userType = input(promptMessage)
	return userType.lower()[0]

# Function used for login in the system
def login():
	userType = promptUserType(
		'Deseja logar como fotógrafo ou como contratante?\n>> ')
	if userType == 'c' or userType == 'f':
		while not authAs(userType):  # while user can't auth itself, repeat the login process
			pass
		return userType
	else:
		return False
# Function used to check user input for phone number and sanitize it
def sanitizePhone(raw_phone):
	# check param passed to function
	if raw_phone is None or len(raw_phone) == 0:
		return False

	phone_parts = raw_phone.split(' ')
	# phone must follow a pattern: two parts divided by a space (' '), country code must begin with + and the phone must have at least 1 digit
	if not (len(phone_parts) == 2 and len(phone_parts[0]) > 1 and phone_parts[0][0] == '+' and len(phone_parts[1]) >= 1 ):
		return False
	
	# applying regex to remove speacial chars that are not wanted
	return phone_parts[0].replace(r'^[-.*() ]$.', '') + ' ' + phone_parts[1].replace(r'^[-.*()+ ].$', '')

# Function used to validate user input according to a regex
# A lambda function may be applied to the input in order to fit a specific format
def inputWithValidation(regExPattern, promptText, inputTreatment = lambda x: x):
	ok = False # variable to validate modifications
	while not ok: # while the input is not following the pattern wanted, the user must enter another input
		resp = inputTreatment(input(promptText)) # ask for user's input, showing the message stored at promptText. If needed, a lambda function is executed (inputTreatment) to treat the user's input
		if not (re.match(re.compile(regExPattern), resp)): # regex matching -> input must match the regex to have a valid input
			print('Formato inválido. Tente novamente...')
			ok = False
		else:
			ok = True
	return resp # returning input from user

# Function used by a user to register a new account
def register():
	userType = promptUserType(
		'Deseja registrar como fotógrafo ou como contratante?\n>> ')

	if userType == 'c':
		registerContractorFields()
	elif userType == 'f':
		registerPhotographerFields()
	else:
		return False
	return True

# Function used to register Contractor (used by register())
def registerContractorFields():
	query_params = dict()
	while True: # keep accepting input while there's an invalid entry from the user
		print('\n')
		query_params['doc_cont'] = inputWithValidation(r'^(\d{11}|\d{14})$', 'Digite o seu documento (CPF ou CNPJ):', lambda x: x.replace('.', ''))
		
		query_params['nome'] = input('Digite o nome:')
		query_params['email'] = inputWithValidation(r'^[a-z0-9.\-\_]+@[a-z0-9\-\_]+\.[a-z]+(\.[a-z]+)?$', 'Digite o email: ')
		
		while True:
			sanitized_phone = sanitizePhone(input('Digite o telefone (+<código do país> <número de telefone>):')) 
			if sanitized_phone != False:
				break
			print('Formato de telefone inválido. Tente novamente...')

		query_params['telefone'] = sanitized_phone
		
		query_params['logradouro'] = input('Digite o logradouro (endereço):')
		query_params['numero'] = inputWithValidation(r'^\d+$','Digite o numero (endereço):')
		query_params['complemento'] = inputWithValidation(r'^\d+$','Digite o complemento (endereço):')
		query_params['cep'] = inputWithValidation(r'^\d+$', 'Digite o CEP:', lambda cep: cep.replace(r'[-. ]+', ''))
		query_params['cidade'] = input('Digite a cidade:')
		query_params['estado'] = input('Digite o estado:')
		query_params['pais'] = input('Digite o pais:')
		
		try:
			# Inserting only some fields, other fields have default values.
			cur.execute('''
				INSERT INTO Contratante (doc_cont,nome,email,telefone,logradouro,numero,complemento,cep,cidade,estado,pais) 
				VALUES (%(doc_cont)s,%(nome)s,%(email)s,%(telefone)s,%(logradouro)s,%(numero)s,%(complemento)s,%(cep)s,%(cidade)s,%(estado)s,%(pais)s)
			''', query_params)
			conn.commit()
			return True
		except Exception as e:
			print("[ERRO] Erro ao cadastrar contratante...")
			# print(e, file=sys.stderr) -> avoid giving too much info

# Function used to register photographer (used by register())
def registerPhotographerFields():
	query_params = dict()
	languages = []
	while True:
		
		query_params['doc_fot'] = inputWithValidation(r'^(\d{11}|\d{14})$', 'Digite o seu documento (CPF ou CNPJ):', lambda x: x.replace('.', ''))
		
		query_params['nome'] = input('Digite o nome: ')
		query_params['email'] = inputWithValidation(r'^[a-z0-9.\-\_]+@[a-z0-9\-\_]+\.[a-z]+(\.[a-z]+)?$', 'Digite o email: ')
		
		while True:
			sanitized_phone = sanitizePhone(input('Digite o telefone (+<código do país> <número de telefone>):')) 
			if sanitized_phone != False:
				break
			print('Formato de telefone inválido. Tente novamente...')

		query_params['telefone'] = sanitized_phone

		query_params['nacionalidade'] = inputWithValidation(r'^[A-Za-z]{3}$', 'Digite o nacionalidade: ')
		query_params['data_nasc'] = inputWithValidation(r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d$', 'Digite a data de nascimento (dd/mm/aaaa): ')
		
		# Uses ISO 639-2 for language codes
		raw_languages = inputWithValidation(r'^(?:\s*[a-zA-Z]{3}\s*[,]?\s*)*(?:\s*[a-zA-Z]{3}\s*)$', "Digite os idiomas falados (3 digitos por idioma: ISO 639-2), separados por vírgula: ")
		languages = map(lambda s: s.strip(), raw_languages.split(','))

		try:
			# Inserting only some fields, other fields have default values.
			cur.execute('''
				INSERT INTO Fotografo (doc_fot,nome,email,telefone,nacionalidade,data_nasc) 
				VALUES (%(doc_fot)s,%(nome)s,%(email)s,%(telefone)s,%(nacionalidade)s,TO_DATE(%(data_nasc)s, 'DD/MM/YYYY'))
			''', query_params)

			languages = list(set(languages)) # Remove repeated languages

			for lang in languages:
				cur.execute('''
					INSERT INTO IdiomaFotografo (doc_fot, idioma)
					VALUES (%(doc_fot)s, %(idioma)s)
				''', { "doc_fot": query_params["doc_fot"], "idioma": lang })

			conn.commit()

			return True
		except Exception as e:
			print("[ERRO] Erro ao cadastrar fotógrafo...")
			# print(e, file=sys.stderr) # -> avoid giving too much info

# Function used to show all offers (used in main after photographer has logged in) 
def showOffers():
	offersList = ''

	# listing all offers from the db
	cur.execute('SELECT titulo, local, descricao, tipo_servico, formas_pag from Oferta ORDER BY titulo')
	queryResult = cur.fetchall()

	# creating string with all offers (offers list)
	for index, row in enumerate(queryResult):
		offersList += '\n== Oferta {} ==\n'.format(str(index+1))
		offersList += 'Título: {}\n'.format(row[0])
		offersList += 'Local: {} \n'.format(row[1])
		offersList += 'Descrição: {}\n'.format(row[2])
		offersList += 'Tipo de serviço: {}\n'.format(row[3])
		offersList += 'Formas de pagamento: {}\n'.format(row[4])

	print(offersList)

# Function used to show all photographers (used in main after contractor has logged in) 
def showPhotographers():
	photList = ''

	# listing all photographers from the db
	cur.execute('SELECT nome, email, telefone, rating, qtd_aval, nacionalidade, visualizacoes, nb_servicos FROM Fotografo ORDER BY nome')
	queryResult = cur.fetchall()

	# creating string with relevant data from photographers
	for index, row in enumerate(queryResult):
		photList += '\n== Fotógrafo {} ==\n'.format(str(index+1))
		photList += 'Nome: {}\n'.format(row[0])
		photList += 'Email: {}\n'.format(row[1])
		photList += 'Telefone: {}\n'.format(row[2])
		photList += 'Rating: {} ({} avaliações)\n'.format((str(row[3]) if row[3] is not None else '-'), str(row[4]))
		photList += 'Nacionalidade: {}\n'.format(row[5])
		photList += 'Qtd. de serviços realizados: {}\n'.format(str(row[7]))
		photList += 'Visualizações no portifólio: {}\n'.format(str(row[6]))

	print(photList)

	
	
## DEBUG FUNCTIONS

def dbg_listcont():
	print("\n\nCont: ")
	cur.execute("select * from Contratante")
	print(cur.fetchall())

def dbg_listfot():
	print("\n\nFot: ")
	cur.execute("select * from Fotografo")
	print(cur.fetchall())
	

def main():
	load_dotenv()  # loading .env file

	# "Server-side"
	dbConnect()  # Connect

	# After connection has been made, cur is the cursor and conn is the connection
	# If the connection has failed, they will both be None.
	assert cur != None, "Database cursor is None!"
	assert conn != None, "Database connection is None!"

	# dbg_listcont()
	# dbg_listfot()
	
	# "Client-side"
	option = ''
	print('\
	****************************************************************************\n \
	*                                                                          *\n \
	*      Bem-vindo ao seu portal (via terminal) de turismo fotográfico!      *\n \
	*                                                                          *\n \
	****************************************************************************\n\n')

	while option not in ['r', 'l']:
		option = input(
			'[!] Escolha uma opção (r/l):\n\t[r] Registrar nova conta\n\t[l] Logar em conta existente\n\n>> '
			) + ' '
		option = option.lower()[0]
	if option == 'r':
		register()
	elif option == 'l':
		userType = login()
		
		if (userType):
			if (userType == 'c'): # login as Contratante
				showPhotographers()
			elif (userType == 'f'): # login as Fotografo
				showOffers()


if __name__ == "__main__":
	main()
