import psycopg2
from dotenv import load_dotenv
import os
import sys

# Criar conta na aplicação (como contratante ou fotógrafo)
# Logar em conta criada apenas com o ( CPF e tipo [contratante ou fotógrafo])
# Listar ofertas para Fotógrafo
# Listas fotógrafos para Contratante
# Criar nova oferta

cur = None  # cursor from db connection


def dbConnect():
	global cur
	try:
		con = psycopg2.connect(
			host=os.environ['DB_HOST'],
			database=os.environ['DB_DATABASE'],
			user=os.environ['DB_USER'],
			password=os.environ['DB_PASSWORD'],
			port=os.environ['DB_PORT']
		)

		print('[INFO] Conectado ao banco de dados!')
		cur = con.cursor()
	except:
		print('[ERRO] Erro ao conectar-se ao banco de dados')
		

def formatAs(type, userDoc):
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


def authAs(type):
	if type == 'c':
		userTable = 'Contratante'
		userDocField = 'doc_cont'
	else:
		userTable = 'Fotografo'
		userDocField = 'doc_fot'

	print('========== LOG-IN - {} =========='.format(userTable.upper()))
	userDocInput = input("Digite seu CPF ou CNPJ (somente números):\n>> ")

	if (len(userDocInput) == 11):  # CPF has 11 numbers
		userDocInput = formatAs('cpf', userDocInput)
	elif (len(userDocInput) == 14):  # CNPJ has 14 numbers
		userDocInput = formatAs('cnpj', userDocInput)
	else:
		print('Formato de CPF ou CNPJ inválido. Tente novamente...')
		return False

	# Query to check if user doc is in database. If it is, user can log in
	checkLoginQuery = 'SELECT * FROM {} WHERE {} = %(userDoc)s'.format(userTable, userDocField)
	# print(checkLoginQuery)
	cur.execute(checkLoginQuery, {'userTable': userTable, 'userDoc': userDocInput})
	result = cur.fetchall()
	
	if (len(result) == 0):
		print('CPF ou CNPJ não cadastrado na base de dados.')
		return False
	else:
		return True


def promptUserType(promptMessage):
	'''returns c for contractor and f for photographer'''
	userType = '-'
	while userType.lower()[0] not in ['c', 'f']:
		userType = input(promptMessage)
	return userType.lower()[0]


def login():
	userType = promptUserType(
		'Deseja logar como fotógrafo ou como contratante?\n>> ')
	if userType == 'c' or userType == 'f':
		while not authAs(userType):  # while user can't auth itself, repeat the login process
			pass
		return userType
	else:
		return False


def register():
	userType = promptUserType(
		'Deseja registrar como fotógrafo ou como contratante?\n>> ')

	if userType == 'c':
		registerContractorFields()
	elif userType == 'f':
		registerPhotographerFields()
	pass


def registerContractorFields():
	while True:
		query_params = dict()
		query_params['doc_cont'] = input('Digite o seu documento (CPF ou CNPJ):')
		query_params['nome'] = input('Digite o nome:')
		query_params['email'] = input('Digite o email:')
		query_params['telefone'] = input('Digite o telefone:')
		query_params['logradouro'] = input('Digite o logradouro (endereço):')
		query_params['numero'] = input('Digite o numero (endereço):')
		query_params['complemento'] = input('Digite o complemento (endereço):')
		query_params['cep'] = input('Digite o CEP:')
		query_params['cidade'] = input('Digite a cidade:')
		query_params['estado'] = input('Digite o estado:')
		query_params['pais'] = input('Digite o pais:')
		
		try:
			cur.execute('''
				INSERT INTO Contratante (doc_cont,nome,email,telefone,logradouro,numero,complemento,cep,cidade,estado,pais) 
				VALUES (%(doc_cont)s,%(nome)s,%(email)s,%(telefone)s,%(logradouro)s,%(numero)s,%(complemento)s,%(cep)s,%(cidade)s,%(estado)s,%(pais)s)
			''', query_params)
			return True
		except Exception as e:
			print("[ERROR] Erro ao cadastrar contratante:")
			print(e, file=sys.stderr)
			# Continue loop, asking again all parameters

def registerPhotographerFields():
	doc_fot = input('Digite o seu documento (CPF ou CNPJ):')
	nome = input('Digite o nome: ')
	email = input('Digite o email: ')
	telefone = input('Digite o telefone: ')
	nacionalidade = input('Digite o nacionalidade: ')
	data_nasc = input('Digite a data de nascimento (dd/mm/aaaa): ')
	# TODO: convert data_nasc from str to date inside query
	
def showOffers():
	offersList = ''

	# listing all offers from the db
	cur.execute('SELECT (titulo, formas_pag, local, descricao, tipo_servico) from Oferta ORDER BY titulo')
	queryResult = cur.fetchall()
	for row in queryResult:
		offersList += '|' row[0] + ''

def main():
	load_dotenv()  # loading .env file

	# Server-side
	dbConnect()  # Connect
	assert cur != None, "Database cursor is none!"

	
	# Client-side
	option = ''
	print('\
	****************************************************************************\n \
	*                                                                          *\n \
	*      Bem-vindo ao seu portal (via terminal) de turismo fotográfico!      *\n \
	*                                                                          *\n \
	****************************************************************************\n\n')
	while option not in ['r', 'l']:
		option = input(
			'[!] Escolha uma opção (r/l):\n\t[r] Registrar nova conta\n\t[l] Logar em conta existente\n\n>> ').lower()[0]

	if option == 'r':
		register()
	elif option == 'l':
		userType = login()
		
		if (userType):
			if (userType == 'c'): # login as Contratante
				showPhotographers()
			elif (userType == 'c'): # login as Fotografo
				showOffers()


if __name__ == "__main__":
	main()
