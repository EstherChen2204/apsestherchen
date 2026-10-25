# 🌊 APS - Alagamentos Urbanos (Sistemas Distribuídos)

Aplicação distribuída para dispositivo móvel que gerencia informações sobre alagamentos e inundações urbanas, combinando relatos colaborativos de cidadãos com registros oficiais de ocorrências do CEMADEN.

## 📋 Sobre o Projeto
O sistema foi desenvolvido para a disciplina de Sistemas Distribuídos do curso de Ciência da Computação da UNIP. Ele resolve o problema da falta de informação em tempo real sobre pontos de alagamento, permitindo que usuários enviem relatos mesmo sem conexão com a internet (fila offline) e recebam alertas em tempo real via WebSocket.

## 🛠️ Tecnologias Utilizadas
*   **Mobile:** Flutter, Dart, SQLite (sqflite), OpenStreetMap (flutter_map), WebSocket (web_socket_channel).
*   **Backend:** Python, FastAPI, SQLite, Pydantic, JWT.
*   **Testes:** Pytest.
*   **Infraestrutura:** Git, VS Code.

## 🚀 Como Executar o Projeto

### 1. Requisitos
*   Python 3.10+
*   Flutter SDK
*   Emulador Android ou celular físico com modo desenvolvedor ativado.

### 2. Configurar o Backend
```bash
# Clone o repositório
git clone https://github.com/EstherChen2204/apsestherchen.git
cd apsestherchen

# Crie e ative o ambiente virtual
python -m venv .venv
.\.venv\Scripts\Activate.ps1  # No Windows
# source .venv/bin/activate   # No Linux/Mac

# Instale as dependências
pip install -r backend/requirements.txt
pip install python-dotenv "uvicorn[standard]"

# Crie o arquivo .env na raiz com as variáveis (veja o exemplo no repositório)
# Inicie o servidor (escutando todas as interfaces para o celular acessar)
python -m uvicorn backend.api.main:app --host 0.0.0.0 --port 8000
Acesse a documentação interativa da API em: http://localhost:8000/docs

3. Carregar os Dados do CEMADEN (Opcional)
Com o servidor rodando em outro terminal:

bash
python -m backend.ingestao.ingestor
4. Executar o Aplicativo Móvel
bash
cd mobile
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:8000
(Nota: 10.0.2.2 é o IP para o emulador Android. Para celular físico, use o IP da sua máquina na rede local, ex: http://192.168.1.15:8000).

🧪 Rodando os Testes
O projeto conta com uma suíte de 36 testes automatizados que cobrem a API, tolerância a falhas e ingestão de dados.

bash
# Com o venv ativado
python -m pytest tests -q


📱 Funcionalidades Principais
RF01: Cadastro, login e perfis (cidadão, moderador, serviço).

RF02/03: Registro e visualização de relatos de alagamento no mapa com filtros por UF.

RF04/08: Alertas em tempo real via WebSocket (gerados após 3 relatos na mesma região).

RF05: Funcionamento offline com fila local (SQLite) e sincronização automática ao reconectar.

RF07: Integração com dados oficiais do CEMADEN.

RF09: Resumo estatístico e regiões críticas.

👩‍💻 Autora
Esther Chen - G846532

Curso: Ciência da Computação - UNIP Brasília

Disciplina: Sistemas Distribuídos (8º semestre)
