"""Gera fontes draw.io editáveis; não renderiza nem simula capturas da aplicação.

Requer apenas Python 3 (biblioteca padrão). A exportação PNG é feita separadamente
pelo draw.io Desktop, conforme exportar-modelos.ps1. As fontes podem ser editadas
diretamente no draw.io; reexecutar este gerador substitui somente seus oito modelos.
"""
from pathlib import Path
import html
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
GREEN, INK, MUTED, LINE = '#194e43', '#243b35', '#63736c', '#dce4da'


class Diagram:
    def __init__(self, name, width, height):
        self.name, self.width, self.height = name, width, height
        self.file = ET.Element('mxfile', host='app.diagrams.net', agent='Controle-Livros-Modelagem', version='32.6.10')
        diagram = ET.SubElement(self.file, 'diagram', id=name, name=name)
        model = ET.SubElement(diagram, 'mxGraphModel', dx=str(width), dy=str(height), grid='1', gridSize='10', guides='1', tooltips='1', connect='1', arrows='1', fold='1', page='1', pageScale='1', pageWidth=str(width), pageHeight=str(height), math='0', shadow='0', background='#ffffff')
        self.root = ET.SubElement(model, 'root')
        ET.SubElement(self.root, 'mxCell', id='0')
        ET.SubElement(self.root, 'mxCell', id='1', parent='0')
        self.counter = 1

    def box(self, value, x, y, w, h, style='', ident=None):
        self.counter += 1
        ident = ident or f'v{self.counter}'
        default = f'rounded=0;whiteSpace=wrap;html=1;fillColor=#ffffff;strokeColor={LINE};fontColor={INK};fontFamily=Arial;fontSize=18;'
        cell = ET.SubElement(self.root, 'mxCell', id=ident, value=value, style=default+style, vertex='1', parent='1')
        ET.SubElement(cell, 'mxGeometry', x=str(x), y=str(y), width=str(w), height=str(h), **{'as': 'geometry'})
        return ident

    def text(self, value, x, y, w, h, size=18, color=INK, bold=False, align='left'):
        return self.box(value, x, y, w, h, f'text;strokeColor=none;fillColor=none;align={align};verticalAlign=middle;spacing=0;fontSize={size};fontColor={color};fontStyle={1 if bold else 0};')

    def line(self, x1, y1, x2, y2, label='', style='', points=None):
        self.counter += 1
        cell = ET.SubElement(self.root, 'mxCell', id=f'e{self.counter}', value=label, style=f'html=1;rounded=0;endArrow=none;strokeColor={INK};strokeWidth=1.5;fontFamily=Arial;fontSize=17;labelBackgroundColor=#ffffff;'+style, edge='1', parent='1')
        g = ET.SubElement(cell, 'mxGeometry', relative='1', **{'as': 'geometry'})
        if label:
            ET.SubElement(g, 'mxPoint', x='0', y='-16', **{'as': 'offset'})
        ET.SubElement(g, 'mxPoint', x=str(x1), y=str(y1), **{'as': 'sourcePoint'})
        ET.SubElement(g, 'mxPoint', x=str(x2), y=str(y2), **{'as': 'targetPoint'})
        if points:
            arr = ET.SubElement(g, 'Array', **{'as': 'points'})
            for x, y in points:
                ET.SubElement(arr, 'mxPoint', x=str(x), y=str(y))
        return cell

    def heading(self, title, subtitle):
        self.text('CONTROLE DE LIVROS USADOS / DOCUMENTAÇÃO TÉCNICA', 40, 25, self.width-80, 25, 14, GREEN, True)
        self.text(title, 40, 65, self.width-80, 55, 34, INK, True)
        self.text(subtitle, 40, 123, self.width-80, 35, 17, MUTED)

    def save(self, relative):
        path = ROOT / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        ET.indent(self.file, space='  ')
        ET.ElementTree(self.file).write(path, encoding='utf-8', xml_declaration=True)
        print(relative)


def use_cases():
    d = Diagram('Casos de uso', 1420, 1090)
    d.heading('Casos de uso', 'Papel de operação local; não existe autenticação ou gestão de usuários.')
    d.box('', 340, 200, 1020, 770, 'fillColor=#f9fbf7;strokeColor=#93aa9b;')
    d.text('Sistema de Controle de Livros Usados', 375, 215, 930, 40, 23, GREEN, True, 'center')
    d.box('Responsável<br>pelo acervo', 65, 450, 160, 180, 'shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;fillColor=#ffffff;strokeColor=#194e43;fontSize=20;')
    names = ['CU01 · Cadastrar livro', 'CU02 · Consultar e pesquisar livros', 'CU03 · Editar livro', 'CU04 · Registrar movimentação', 'CU05 · Consultar histórico']
    for i, name in enumerate(names):
        y = 290 + i*127
        d.box(name, 600, y, 590, 88, 'ellipse;fillColor=#ffffff;strokeColor=#668e7a;fontSize=21;')
        d.line(145, 535, 600, y+44)
    d.text('Associação simples entre ator e operação. Sem relações include/extend não implementadas.', 50, 1005, 1320, 35, 16, MUTED, align='center')
    d.save('docs/diagramas/casos-de-uso.drawio')


def class_box(d, name, attrs, methods, x, y, w, h):
    d.box('', x, y, w, h, 'strokeColor=#6e8e7a;')
    d.box(f'<b>{name}</b> {{leaf}}', x, y, w, 50, 'fillColor=#edf2e8;strokeColor=#6e8e7a;fontSize=23;')
    attr_h = max(62, len(attrs)*28+20)
    d.text('<br>'.join(html.escape(a) for a in attrs) if attrs else 'Sem atributos declarados', x+18, y+60, w-36, attr_h-15, 18, align='left')
    d.line(x, y+50+attr_h, x+w, y+50+attr_h, style='strokeColor=#6e8e7a;')
    body = []
    for method in methods:
        s = html.escape(method)
        body.append(f'<u>{s}</u>' if name == 'Database' else s)
    d.text('<br>'.join(body), x+18, y+60+attr_h, w-36, h-70-attr_h, 17)


def classes():
    d = Diagram('Classes', 1860, 1260)
    d.heading('Classes PHP e dependências', 'Visibilidades e assinaturas reais. Os atributos do banco não são propriedades dessas classes.')
    class_box(d, 'Database', [], ['+ conectar(config: ?array = null): PDO'], 40, 210, 510, 195)
    class_box(d, 'AcervoService', ['- pdo: PDO', '- livros: Livro', '- categorias: Categoria', '- movimentacoes: Movimentacao'], [
        '+ __construct(pdo: PDO)', '- validarDados(dados: array): array',
        '+ cadastrarLivro(dados: array, estoqueInicial: int): int',
        '+ atualizarLivro(id: int, dados: array): void',
        '+ movimentar(livroId: int, tipo: string, quantidade: int,', '  observacao: ?string): void'], 680, 210, 1140, 460)
    d.box('«biblioteca PHP»<br><b>PDO</b>', 120, 480, 330, 100, 'fillColor=#f6f7f3;dashed=1;fontSize=22;')
    d.line(295, 405, 295, 480, 'cria', 'dashed=1;endArrow=open;endFill=0;')
    class_box(d, 'Livro', ['- pdo: PDO'], ['+ __construct(pdo: PDO)', "+ listar(busca: string = ''): array", '+ buscar(id: int, bloquear: bool = false): ?array', '+ cadastrar(dados: array): int', '+ atualizar(id: int, dados: array): void', '+ definirEstoque(id: int, estoque: int): void'], 40, 840, 650, 340)
    class_box(d, 'Categoria', ['- pdo: PDO'], ['+ __construct(pdo: PDO)', '+ listar(): array', '+ existe(id: int): bool'], 740, 840, 400, 270)
    class_box(d, 'Movimentacao', ['- pdo: PDO'], ['+ __construct(pdo: PDO)', '+ listar(livroId: ?int = null): array', '+ registrar(livroId: int, tipo: string,', '  quantidade: int, observacao: ?string): void'], 1190, 840, 630, 310)
    for x, tx in [(850,365),(1100,940),(1510,1505)]:
        d.line(x, 670, tx, 840, 'cria / utiliza', 'dashed=1;endArrow=open;endFill=0;', [(x,740),(tx,740)])
    d.text('− privado · + público · sublinhado: estático · {leaf}: classe final no PHP', 40, 1210, 1780, 28, 17, MUTED, align='center')
    d.text('Livro, Categoria, Movimentacao e AcervoService recebem o mesmo PDO por construtor.<br>src/bootstrap.php contém funções livres; não é uma classe.', 40, 630, 555, 125, 17, MUTED)
    d.save('docs/diagramas/classes.drawio')


def entity(d, name, rows, x, y, w):
    h = 66+len(rows)*43
    d.box('', x,y,w,h, 'strokeColor=#75917f;')
    d.box(f'<b>{name}</b>',x,y,w,56,'fillColor=#edf2e8;strokeColor=#75917f;fontSize=24;')
    for i,row in enumerate(rows):
        d.text(html.escape(row),x+18,y+64+i*43,w-36,35,19)
    return h


def mer():
    d = Diagram('MER', 2010, 980)
    d.heading('Modelo entidade-relacionamento', 'Modelo lógico derivado de sql/estrutura.sql · InnoDB · utf8mb4_unicode_ci · 3 tabelas / 17 colunas')
    entity(d,'categorias',['PK  id : INT AUTO_INCREMENT','UQ nome : VARCHAR(100) NOT NULL'],40,300,440)
    entity(d,'livros',['PK  id : INT AUTO_INCREMENT','FK  categoria_id : INT NOT NULL','titulo : VARCHAR(200) NOT NULL','autor : VARCHAR(150) NOT NULL','isbn : VARCHAR(20) NULL','preco : DECIMAL(10,2) DEFAULT 0.00','estoque : INT DEFAULT 0','criado_em : DATETIME DEFAULT CURRENT_TIMESTAMP','atualizado_em : DATETIME DEFAULT CURRENT_TIMESTAMP'],650,230,580)
    entity(d,'movimentacoes',['PK  id : INT AUTO_INCREMENT','FK  livro_id : INT NOT NULL',"tipo : ENUM('entrada', 'saida')",'quantidade : INT NOT NULL','observacao : VARCHAR(255) NULL','criado_em : DATETIME DEFAULT CURRENT_TIMESTAMP'],1390,300,580)
    # Notação pé de galinha mais multiplicidades explícitas para leitura independente do editor.
    d.line(480,380,650,380,'possui','startArrow=ERone;startFill=0;endArrow=ERzeroToMany;endFill=0;')
    d.text('1',492,400,40,25,18,GREEN,True)
    d.text('0..*',590,400,50,25,18,GREEN,True)
    d.line(1230,425,1390,425,'registra','startArrow=ERone;startFill=0;endArrow=ERzeroToMany;endFill=0;')
    d.text('1',1240,445,40,25,18,GREEN,True)
    d.text('0..*',1325,445,55,25,18,GREEN,True)
    d.box('PK = chave primária · FK = chave estrangeira · UQ = único<br>Em livros e movimentacoes, as colunas sem indicação NULL são NOT NULL.<br>FKs: ON UPDATE RESTRICT / ON DELETE RESTRICT.',40,760,1930,100,'fillColor=#f6f8f3;strokeColor=#dce4da;fontSize=19;')
    d.text('CHECK: título/autor não vazios; preço ≥ 0; estoque ≥ 0; quantidade > 0; tipo permitido.<br>atualizado_em: ON UPDATE CURRENT_TIMESTAMP. Detalhes de índices e limites: dicionario-dados.md.',40,875,1930,65,18,MUTED)
    d.save('docs/diagramas/mer.drawio')


def sequence():
    d=Diagram('Sequência de movimentação',1970,1900)
    d.heading('Registrar uma movimentação de estoque','Cenário: livro existente · a ação recebe POST, o serviço coordena os repositórios e a transação PDO.')
    xs=[120,390,680,990,1280,1530,1810]
    labels=['Responsável<br>pelo acervo','«interface»<br>movimentacoes.php','«ação PHP»<br>registrar-movimentacao.php','«serviço»<br>AcervoService','«acesso a dados»<br>Livro','«acesso a dados»<br>Movimentacao','«infraestrutura»<br>PDO / MariaDB']
    # Fragmento atrás das linhas de vida e mensagens.
    d.box('',600,920,1320,690,'fillColor=none;strokeColor=#65836f;')
    d.box('alt',600,920,70,38,'fillColor=#edf2e8;strokeColor=#65836f;fontStyle=1;')
    d.line(600,1090,1920,1090,style='dashed=1;strokeColor=#65836f;')
    for x,label in zip(xs,labels):
        d.box(label,x-115,205,230,82,'fillColor=#edf2e8;strokeColor=#819d89;fontSize=18;')
        d.line(x,287,x,1740,style='dashed=1;strokeColor=#a6b3a6;strokeWidth=1;')
    def msg(a,b,y,text,reply=False):
        d.line(xs[a],y,xs[b],y,text,'endArrow=open;endFill=0;dashed=1;' if reply else 'endArrow=block;endFill=1;')
    msg(0,1,335,'1. Preencher e enviar')
    msg(1,2,395,'2. POST + CSRF + campos')
    d.box('protegerPost(); inteiro(livro_id); inteiro(quantidade)<br>Conexão obtida; serviço instanciado.',560,430,440,70,'shape=note;fillColor=#fbf7e9;strokeColor=#c8b98f;fontSize=17;')
    msg(2,3,540,'3. movimentar(id, tipo, quantidade, observacao)')
    d.box('Valida tipo, quantidade e observação<br>antes de iniciar a transação.',850,568,480,60,'shape=note;fillColor=#fbf7e9;strokeColor=#c8b98f;fontSize=17;')
    msg(3,6,670,'4. beginTransaction()')
    msg(3,4,720,'5. buscar(id, true)')
    msg(4,6,765,'6. SELECT ... FOR UPDATE')
    msg(6,4,845,'7. livro e saldo (registro bloqueado)',True)
    msg(4,3,890,'8. dados do livro',True)
    d.text('[tipo = saida e quantidade > saldo]',1020,920,730,33,19,GREEN,True)
    msg(3,6,980,'9a. rollBack()')
    msg(3,2,1030,'10a. DomainException: estoque insuficiente',True)
    d.text('[saldo e limite válidos]',1020,1110,700,32,19,GREEN,True)
    msg(3,4,1170,'9b. definirEstoque(id, novoSaldo)')
    msg(4,6,1220,'10b. UPDATE livros SET estoque = ...')
    msg(3,5,1295,'11b. registrar(id, tipo, quantidade, observacao)')
    msg(5,6,1350,'12b. INSERT INTO movimentacoes (...)')
    msg(3,6,1425,'13b. commit()')
    msg(3,2,1485,'14b. retorno void',True)
    d.text('A ação trata exceção de domínio ou sucesso e prepara a mensagem correspondente.',650,1545,1210,38,17,MUTED)
    msg(2,1,1650,'15. mensagem na sessão + Location (303)',True)
    msg(1,0,1720,'16. Após GET, exibir saldo / histórico ou validação',True)
    d.box('Observações de fidelidade ao código<br>403/405 encerram a ação antes do serviço. Campos inválidos são rejeitados antes da transação.<br>Livro ausente, overflow ou erro SQL dentro da transação também causam rollback; o cenário alternativo detalhado é o de estoque insuficiente.<br>O navegador segue o 303 para public/movimentacoes.php?livro_id=...; a mensagem não faz parte da transação SQL.',40,1790,1890,95,'fillColor=#f6f8f3;strokeColor=#dce4da;fontSize=17;')
    d.save('docs/diagramas/sequencia.drawio')


def proto_base(name,title,subtitle):
    d=Diagram(name,1460,1270)
    d.text('PROTÓTIPO / MODELAGEM DA INTERFACE — NÃO É CAPTURA DA APLICAÇÃO',40,20,1380,30,15,GREEN,True)
    d.box('',30,70,1400,1110,'rounded=1;arcSize=2;fillColor=#f7f8f4;strokeColor=#bacbbd;')
    d.box('',30,70,1400,100,'fillColor=#ffffff;strokeColor=#dce4da;')
    d.box('L',65,95,50,50,f'rounded=1;arcSize=15;fillColor={GREEN};fontColor=#ffffff;fontSize=28;strokeColor=none;fontFamily=Georgia;')
    d.text('livros usados',130,95,300,30,26,INK,True)
    d.text('CONTROLE DO ACERVO',130,127,300,20,11,MUTED)
    for text,x,active in [('Catálogo',510,name in ['Catálogo','Edição']),('Cadastrar livro',680,name=='Cadastro'),('Movimentações',910,name=='Movimentações')]:
        d.text(text,x,108,210,30,17,GREEN if active else MUTED,active)
        if active:d.line(x,168,x+150,168,style=f'strokeColor={GREEN};strokeWidth=3;')
    d.text('Acervo local',1230,110,150,26,14,MUTED)
    d.text(title,70,210,1150,60,43,INK,False)
    d.text(subtitle,70,278,1250,35,18,MUTED)
    d.text('Sistema de Controle de Livros Usados',70,1132,700,25,14,MUTED)
    d.text('Um novo capítulo para cada exemplar.',900,1132,450,25,14,MUTED)
    return d


def button(d,text,x,y,w,primary=True):
    d.box(text,x,y,w,48,f'rounded=1;arcSize=12;fillColor={GREEN if primary else "#ffffff"};fontColor={"#ffffff" if primary else GREEN};strokeColor={GREEN if primary else "#bacbbd"};fontSize=16;fontStyle=1;')


def field(d,label,x,y,w,value='',h=50,readonly=False):
    d.text(label,x,y,w,27,16,INK,True)
    d.box(html.escape(value),x,y+34,w,h,f'rounded=1;arcSize=10;align=left;spacingLeft=14;fillColor={"#f7f9f3" if readonly else "#ffffff"};strokeColor=#cddace;fontSize=17;'+('dashed=1;' if readonly else ''))


def catalog():
    d=proto_base('Catálogo','Catálogo de livros.','Consulte os títulos e acompanhe cada exemplar do seu acervo.')
    button(d,'＋ Cadastrar livro',1130,220,250)
    for x,label,value,note in [(70,'Títulos no acervo','〈total〉','Livros cadastrados'),(515,'Exemplares disponíveis','〈soma do saldo〉','Soma das quantidades em estoque'),(960,'Títulos com estoque','〈total com saldo〉','Com pelo menos um exemplar')]:
        d.box('',x,355,420,165,'rounded=1;arcSize=8;fillColor=#edf2e8;' if x==960 else 'rounded=1;arcSize=8;')
        d.text(label,x+25,375,370,26,16,MUTED)
        d.text(value,x+25,415,370,50,30,INK)
        d.text(note,x+25,478,370,24,13,MUTED)
    d.box('',70,560,1310,480,'rounded=1;arcSize=3;')
    d.text('Seu catálogo',95,580,410,35,24,INK,True)
    d.text('Encontre o próximo livro em poucos segundos.',95,625,520,25,15,MUTED)
    d.box('Título, autor ou ISBN',775,585,365,49,'rounded=1;arcSize=9;align=left;spacingLeft=12;fontColor=#63736c;fontSize=16;')
    button(d,'Pesquisar',1155,585,195)
    d.box('',70,690,1310,65,'fillColor=#f6f8f3;strokeColor=#dce4da;')
    for label,x,w in [('LIVRO / AUTOR',95,380),('CATEGORIA',510,200),('PREÇO',740,150),('DISPONIBILIDADE',915,205),('AÇÕES',1160,180)]:d.text(label,x,710,w,25,13,MUTED,True)
    d.text('〈título do banco〉<br>〈autor〉<br>ISBN 〈ISBN, se informado〉',95,785,380,95,19)
    d.text('〈categoria〉',510,800,200,35,17)
    d.text('R$ 〈preço〉',740,800,155,35,17)
    d.text('〈saldo〉 exemplar(es)',915,800,220,35,16,GREEN)
    d.text('Editar   Movimentar ↗',1150,800,210,35,16,GREEN)
    d.line(70,915,1380,915,style=f'strokeColor={LINE};')
    d.text('〈quantidade de títulos〉 no catálogo',95,950,1150,35,16,MUTED)
    d.text('Anotações: os marcadores 〈 〉 representam dados do banco. Busca usa GET; estados vazios e “Limpar pesquisa” são condicionais.',50,1200,1360,55,16,MUTED)
    d.save('docs/prototipos/catalogo.drawio')


def book_form(edit=False):
    d=proto_base('Edição' if edit else 'Cadastro','Editar livro.' if edit else 'Cadastrar livro.','Atualize as informações cadastrais do seu acervo.' if edit else 'Registre os dados do livro e a quantidade inicial de exemplares.')
    d.text('← Voltar ao catálogo',70,180,400,22,14,GREEN)
    d.box('',70,350,850,710,'rounded=1;arcSize=3;')
    d.text('Dados do livro',100,375,730,36,24,INK,True)
    d.text('Os campos marcados com * são obrigatórios.',100,420,750,24,15,MUTED)
    field(d,'Título *',100,470,790,'〈título do livro〉' if edit else '')
    field(d,'Autor *',100,580,790,'〈autor〉' if edit else '')
    field(d,'Categoria *',100,690,370,'〈categoria atual〉 ▾' if edit else 'Selecione uma categoria ▾')
    field(d,'ISBN (opcional)',500,690,390,'〈ISBN〉' if edit else '')
    field(d,'Preço (R$) *',100,805,370,'〈preço atual〉' if edit else '0,00')
    field(d,'Estoque atual' if edit else 'Estoque inicial *',500,805,390,'〈saldo〉 exemplar(es)' if edit else '0',readonly=edit)
    d.text('Para alterar, registre uma movimentação.' if edit else 'Quantidade de exemplares disponíveis.',500,900,390,30,14,GREEN if edit else MUTED)
    button(d,'Cancelar',490,978,150,False)
    button(d,'Salvar alterações' if edit else 'Cadastrar livro',655,978,235)
    d.box('',960,350,420,610,'rounded=1;arcSize=4;fillColor=#edf1e5;')
    d.text('02 / CADASTRO' if edit else '01 / ACERVO',990,380,340,30,14,GREEN,True)
    d.text('Dados certos,<br>acervo organizado.' if edit else 'Todo exemplar<br>tem uma história.',990,455,350,140,35,GREEN)
    d.text('Altere título, autor, categoria, ISBN e preço sempre que necessário.' if edit else 'Um cadastro completo facilita a pesquisa e mantém o seu acervo organizado.',990,620,350,105,19,MUTED)
    d.line(990,750,1350,750,style='strokeColor=#c4d0b9;')
    d.text('A quantidade tem seu lugar' if edit else 'Estoque com histórico',990,785,350,30,19,GREEN,True)
    d.text('O estoque é alterado somente por entradas e saídas.' if edit else 'Se houver exemplares no cadastro, uma entrada inicial será registrada automaticamente.',990,835,350,100,18,MUTED)
    d.text('Anotações: modelo baseado no formulário real. CSRF'+(' e ID' if edit else '')+' são campos ocultos, não controles visuais. '+('Estoque é somente leitura.' if edit else 'Campos numéricos mostram os valores padrão.'),50,1200,1360,55,16,MUTED)
    d.save('docs/prototipos/edicao.drawio' if edit else 'docs/prototipos/cadastro.drawio')


def movements():
    d=proto_base('Movimentações','Movimentações.','Registre entradas e saídas e acompanhe o histórico do acervo.')
    button(d,'Ver catálogo ↗',1150,225,230,False)
    d.box('',70,350,420,730,'rounded=1;arcSize=4;')
    d.text('ESTOQUE',95,370,360,27,13,GREEN,True)
    d.text('Registrar movimentação',95,410,370,35,23,INK,True)
    d.text('Todos os campos são obrigatórios,<br>exceto a observação.',95,453,370,55,15,MUTED)
    field(d,'Livro',95,535,370,'Selecione um livro ▾')
    field(d,'Tipo de movimentação',95,650,370,'Entrada de exemplares ▾')
    field(d,'Quantidade',95,760,370,'1')
    field(d,'Observação (opcional)',95,860,370,'',70)
    button(d,'Registrar movimentação',95,990,370)
    d.box('',530,350,850,730,'rounded=1;arcSize=3;')
    d.text('Histórico de movimentações',560,380,775,35,24,INK,True)
    d.text('Todas as entradas e saídas do acervo.',560,430,775,28,16,MUTED)
    d.box('Todos os livros ▾',560,490,580,50,'rounded=1;arcSize=10;align=left;spacingLeft=14;fontSize=17;')
    button(d,'Filtrar',1160,490,190,False)
    d.box('',530,585,850,65,'fillColor=#f6f8f3;')
    for label,x,w in [('DATA / LIVRO',560,240),('TIPO',820,120),('QUANTIDADE',960,150),('OBSERVAÇÃO',1130,220)]:d.text(label,x,605,w,25,13,MUTED,True)
    d.text('〈data e hora〉<br>〈título do livro〉',560,695,240,80,18)
    d.text('〈tipo〉',820,710,120,35,17,GREEN)
    d.text('〈quantidade〉',960,710,150,35,17)
    d.text('〈observação〉',1130,695,220,80,17,MUTED)
    d.line(530,820,1380,820,style=f'strokeColor={LINE};')
    d.text('〈total〉 movimentação(ões) registrada(s)',560,865,750,35,16,MUTED)
    d.text('Anotações: campos vêm das tabelas reais; os marcadores são simbólicos. Sem movimentos, a tabela dá lugar ao estado vazio.<br>Seleção do livro mostra seu saldo. O filtro usa GET; o registro usa POST. Não há edição ou exclusão do histórico.',50,1190,1360,70,16,MUTED)
    d.save('docs/prototipos/movimentacoes.drawio')


if __name__ == '__main__':
    use_cases()
    classes()
    mer()
    sequence()
    catalog()
    book_form(False)
    book_form(True)
    movements()
