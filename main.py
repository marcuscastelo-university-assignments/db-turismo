import psycopg2
from dotenv import load_dotenv
import os
import sys
import re

# Funções criadas para teste do banco de dados em aplicação:
	# Criar conta na aplicação (como contratante ou fotógrafo) usando CPF/CNPJ
	# Logar em conta criada apenas com o ( CPF e tipo [contratante ou fotógrafo])
	# Listar ofertas para Fotógrafo
	# Listas fotógrafos para Contratante
	# Criar nova oferta

cur = None  # cursor from db connection
conn = None

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
		

def sanitizePhone(raw_phone):
	if raw_phone is None or len(raw_phone) == 0:
		print(1)
		return False

	phone_parts = raw_phone.split(' ')
	if not (len(phone_parts) == 2 and len(phone_parts[0]) > 1 and phone_parts[0][0] == '+' and len(phone_parts[1]) >= 1 ):
		print(2)
		return False

	return phone_parts[0].replace(r'^[-.*() ]$.', '') + ' ' + phone_parts[1].replace(r'^[-.*()+ ].$', '')


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

def inputWithValidation(regExPattern, promptText, inputTreatment = lambda x: x):
	ok = False
	while not ok:
		resp = inputTreatment(input(promptText))
		print(resp)
		if not (re.match(re.compile(regExPattern), resp)):
			print('Formato inválido. Tente novamente...')
			ok = False
		else:
			ok = True
	return resp

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


def registerContractorFields():
	query_params = dict()
	while True:
		print('\n')
		query_params['doc_cont'] = inputWithValidation(r'^(\d{11}|\d{14})$', 'Digite o seu documento (CPF ou CNPJ):', lambda x: x.replace('.', ''))
		
		query_params['nome'] = input('Digite o nome:')
		query_params['email'] = inputWithValidation(r'^[a-z0-9.\-\_]+@[a-z0-9\-\_]+\.[a-z]+(\.[a-z]+)?$/', 'Digite o email: ')
		
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
			print("[ERROR] Erro ao cadastrar contratante:")
			print(e, file=sys.stderr)

def registerPhotographerFields():
	query_params = dict()
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

		query_params['nacionalidade'] = input('Digite o nacionalidade: ')
		query_params['data_nasc'] = inputWithValidation(r'^(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[012])\/(19|20)\d\d$', 'Digite a data de nascimento (dd/mm/aaaa): ')
		
		try:
			# Inserting only some fields, other fields have default values.
			cur.execute('''
				INSERT INTO Fotografo (doc_fot,nome,email,telefone,nacionalidade,data_nasc) 
				VALUES (%(doc_fot)s,%(nome)s,%(email)s,%(telefone)s,%(nacionalidade)s,TO_DATE(%(data_nasc)s, 'DD/MM/YYYY'))
			''', query_params)
			conn.commit()
			return True
		except Exception as e:
			print("[ERROR] Erro ao cadastrar contratante:")
			print(e, file=sys.stderr)
	
def showOffers():
	offersList = ''

	# listing all offers from the db
	cur.execute('SELECT titulo, local, descricao, tipo_servico, formas_pag from Oferta ORDER BY titulo')
	queryResult = cur.fetchall()
	for index, row in enumerate(queryResult):
		offersList += '\n== Oferta ' + str(index+1) + ' ==\n'
		offersList += 'Título: ' + row[0] + '\n'
		offersList += 'Local: ' + row[1] + '\n'
		offersList += 'Descrição: ' + row[2] + '\n'
		offersList += 'Tipo de serviço: ' + row[3] + '\n'
		offersList += 'Formas de pagamento: ' + row[4] + '\n'

	print(offersList)

def showPhotographers():
	photList = ''

	# listing all photographers from the db
	cur.execute('SELECT nome, email, telefone, rating, qtd_aval, nacionalidade, visualizacoes, nb_servicos FROM Fotografo ORDER BY nome')
	queryResult = cur.fetchall()
	for index, row in enumerate(queryResult):
		photList += '\n== Fotógrafo ' + str(index+1) + ' ==\n'
		photList += 'Nome: ' + row[0] + '\n'
		photList += 'Email: ' + row[1] + '\n'
		photList += 'Telefone: ' + row[2] + '\n'
		photList += 'Rating: ' + (str(row[3]) if row[3] is not None else '-') + ' (' + str(row[4]) + ' avaliações)\n'
		photList += 'Nacionalidade: ' + row[5] + '\n'
		photList += 'Qtd. de serviços realizados: ' + str(row[7]) + '\n'
		photList += 'Visualizações no portifólio: ' + str(row[6]) + '\n'

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

	# Server-side
	dbConnect()  # Connect
	assert cur != None, "Database cursor is None!"
	assert conn != None, "Database connection is None!"

	dbg_listcont()
	dbg_listfot()
	
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
			elif (userType == 'f'): # login as Fotografo
				showOffers()


if __name__ == "__main__":
	main()
