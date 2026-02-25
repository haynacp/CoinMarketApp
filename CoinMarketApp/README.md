# 🪙 CoinMarketApp

Uma aplicação iOS para visualização de exchanges de criptomoedas e suas moedas, desenvolvida em Swift utilizando UIKit e Swift Concurrency.

![iOS](https://img.shields.io/badge/iOS-15.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![UIKit](https://img.shields.io/badge/UIKit-Framework-green)

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Arquitetura](#-arquitetura)
- [Features](#-features)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Testes](#-testes)
- [Instalação](#-instalação)
- [Uso](#-uso)
- [Tecnologias](#-tecnologias)

## 🎯 Visão Geral

CoinMarketApp é uma aplicação nativa iOS que permite aos usuários explorar informações sobre exchanges de criptomoedas, incluindo volumes de negociação, taxas, moedas suportadas e dados detalhados sobre cada exchange.

A aplicação consome dados da API do CoinMarketCap, apresentando as informações de forma organizada e intuitiva.

## 🏗 Arquitetura

O projeto foi desenvolvido seguindo os princípios da arquitetura **MVVM (Model-View-ViewModel)** com algumas adaptações para UIKit, garantindo separação de responsabilidades, testabilidade e manutenibilidade do código.

### Camadas da Arquitetura

#### 1. **Model Layer** 
Responsável pela representação dos dados e lógica de negócio.

- **Exchange**: Modelo principal representando uma exchange de criptomoedas
- **Currency**: Modelo representando uma moeda/criptomoeda
- **Market**: Modelo representando um par de negociação
- **ViewState**: Enum genérico para gerenciar estados da view (idle, loading, loaded, empty, error)

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)
}
```

#### 2. **View Layer**
Interface do usuário construída com UIKit programaticamente (sem Storyboards).

- **ExchangeListViewController**: Lista de exchanges com scroll infinito
- **ExchangeDetailViewController**: Detalhes de uma exchange específica
- **ExchangeTableViewCell**: Célula customizada para exibir exchange
- **CurrencyTableViewCell**: Célula customizada para exibir moeda

**Características das Views:**
- Layout programático usando Auto Layout
- UI customizada com cores e estilos consistentes
- Splash screen animado
- Pull-to-refresh
- Loading states
- Empty states
- Error handling com alertas

#### 3. **ViewModel Layer**
Camada intermediária que processa dados e gerencia estados.

- **ExchangeListViewModel**: Gerencia lista de exchanges, paginação e formatação
- **ExchangeDetailViewModel**: Gerencia detalhes e moedas de uma exchange

**Responsabilidades dos ViewModels:**
- Buscar dados do serviço
- Processar e formatar dados para apresentação
- Gerenciar estados da view através de delegates
- Implementar lógica de paginação
- Cache e otimização de carregamento

#### 4. **Service Layer**
Responsável pela comunicação com APIs externas.

- **CoinMarketCapService**: Singleton que gerencia todas as requisições HTTP
- **APIError**: Enum customizado para tratamento de erros
- **RetryableOperation**: Sistema de retry para requisições falhadas

**Características do Service:**
- Implementação com `async/await` (Swift Concurrency)
- Tratamento robusto de erros
- Retry automático em caso de falha
- Suporte a mock data para desenvolvimento/testes
- Decodificação JSON com `Codable`

### Fluxo de Dados

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐      ┌─────────┐
│    View     │─────▶│  ViewModel   │─────▶│   Service   │─────▶│   API   │
│ Controller  │◀─────│              │◀─────│             │◀─────│         │
└─────────────┘      └──────────────┘      └─────────────┘      └─────────┘
     │                      │
     │                      │
     ▼                      ▼
 UI Updates            ViewState
  (Delegate)           Management
```

1. **View → ViewModel**: View solicita dados através do ViewModel
2. **ViewModel → Service**: ViewModel requisita dados do serviço
3. **Service → API**: Serviço faz requisição HTTP
4. **API → Service**: Resposta é recebida e decodificada
5. **Service → ViewModel**: Dados processados retornam
6. **ViewModel → View**: View é notificada via delegate para atualizar UI

### Padrões de Design Utilizados

#### **Delegation Pattern**
Usado para comunicação entre ViewModels e ViewControllers:

```swift
protocol ExchangeListViewModelDelegate: AnyObject {
    func didUpdateState(_ state: ViewState<[Exchange]>)
}
```

#### **Singleton Pattern**
Aplicado ao serviço de API para garantir instância única:

```swift
class CoinMarketCapService {
    static let shared = CoinMarketCapService()
}
```

#### **Dependency Injection**
ViewModels recebem dependências no inicializador, facilitando testes:

```swift
init(service: CoinMarketCapService = .shared) {
    self.service = service
}
```

#### **Factory Pattern**
Criação de células e componentes UI reutilizáveis.

## ✨ Features

### 1. **Splash Screen Animado**
- Animação de entrada suave com spring animation
- Logo rotativo
- Transição para tela principal
- Duração customizável

### 2. **Lista de Exchanges**
- ✅ Exibição de exchanges com informações principais
- ✅ Scroll infinito com paginação (20 itens por página)
- ✅ Pull-to-refresh para atualizar dados
- ✅ Indicador visual ao carregar mais itens
- ✅ Formatação inteligente de volumes (B, M, K)
- ✅ Imagens de logo com cache
- ✅ Empty state quando não há dados
- ✅ Tratamento de erros com opção de retry

**Informações exibidas por exchange:**
- Logo da exchange
- Nome
- Volume de negociação em USD
- Data de lançamento

### 3. **Detalhes da Exchange**
- ✅ Informações completas da exchange
- ✅ Logo em destaque
- ✅ Descrição detalhada
- ✅ Cards informativos com ícones:
  - Website oficial
  - Maker Fee
  - Taker Fee
  - Data de lançamento
- ✅ Lista de moedas suportadas
- ✅ Scroll com botão "voltar ao topo"
- ✅ Empty state para exchanges sem dados de holdings
- ✅ Loading states durante carregamento

### 4. **Sistema de Cores Customizado**
Paleta de cores consistente em todo o app:

```swift
// Cores principais
.mbOrange    // Laranja principal (#F98E1B)
.mbBackground // Fundo do app
.mbSecondaryBackground // Fundo secundário
.mbPrimaryText // Texto principal
.mbSecondaryText // Texto secundário
.mbSeparator // Separadores
```

### 5. **Carregamento de Imagens**
- Cache automático de imagens
- Placeholder durante carregamento
- Tratamento de falhas com ícone padrão

### 6. **Responsividade**
- Layout adaptável a diferentes tamanhos de tela
- Auto Layout programático
- Safe Area respeitada
- Animações suaves

## 📁 Estrutura do Projeto

```
CoinMarketApp/
├── App/
│   └── AppDelegate.swift              # Configuração inicial e splash screen
│
├── Models/
│   ├── Exchange.swift                 # Modelo de exchange
│   ├── Currency.swift                 # Modelo de moeda
│   ├── Market.swift                   # Modelo de mercado
│   └── ViewState.swift                # Estados genéricos da view
│
├── ViewModels/
│   ├── ExchangeListViewModel.swift    # ViewModel da lista
│   └── ExchangeDetailViewModel.swift  # ViewModel dos detalhes
│
├── Views/
│   ├── ExchangeListViewController.swift     # Lista de exchanges
│   ├── ExchangeDetailViewController.swift   # Detalhes da exchange
│   ├── Cells/
│   │   ├── ExchangeTableViewCell.swift     # Célula de exchange
│   │   └── CurrencyTableViewCell.swift     # Célula de moeda
│   └── Extensions/
│       ├── UIColor+Extensions.swift         # Cores customizadas
│       └── UIImageView+Extensions.swift     # Carregamento de imagens
│
├── Services/
│   ├── CoinMarketCapService.swift     # Serviço de API
│   ├── APIError.swift                 # Erros customizados
│   └── RetryableOperation.swift       # Sistema de retry
│
└── Tests/
    ├── CoinMarketAppTests/
    │   ├── ExchangeListViewModelTests.swift   # Testes unitários da lista
    │   ├── ExchangeDetailViewModelTests.swift # Testes unitários dos detalhes
    │   └── CoinMarketCapServiceTests.swift    # Testes do serviço
    └── CoinMarketAppUITests/
        └── CoinMarketAppUITests.swift         # Testes de interface
```

## 🧪 Testes

O projeto possui cobertura de testes em três níveis:

### 1. **Testes Unitários (Unit Tests)**

Utilizam o **Swift Testing Framework** (novo framework com macros do Swift 5.9+).

#### **ExchangeListViewModelTests** (14 testes)

```swift
@Suite("Exchange List ViewModel Tests")
struct ExchangeListViewModelTests {
    // Testes de inicialização
    @Test("Deve iniciar com estado idle")
    
    // Testes de carregamento
    @Test("Deve carregar exchanges com sucesso")
    @Test("Deve lidar com erro de rede")
    @Test("Deve carregar mock data quando solicitado")
    
    // Testes de formatação
    @Test("Deve formatar volume em bilhões")
    @Test("Deve formatar volume em milhões")
    @Test("Deve formatar volume em milhares")
    @Test("Deve retornar N/A quando volume é nil")
    @Test("Deve formatar data corretamente")
    
    // Testes de paginação
    @Test("Deve implementar paginação básica")
    @Test("Não deve carregar mais quando já está carregando")
    
    // Testes de acesso
    @Test("Deve retornar exchange por índice")
}
```

**Cobertura:**
- ✅ Estados iniciais
- ✅ Carregamento de dados (sucesso e erro)
- ✅ Formatação de valores monetários
- ✅ Formatação de datas
- ✅ Paginação e scroll infinito
- ✅ Acesso a dados por índice
- ✅ Mock data

#### **ExchangeDetailViewModelTests** (10+ testes)

```swift
@Suite("Exchange Detail ViewModel Tests")
struct ExchangeDetailViewModelTests {
    // Testes de inicialização
    @Test("Deve inicializar com exchange fornecida")
    
    // Testes de detalhes
    @Test("Deve buscar detalhes da exchange com sucesso")
    @Test("Deve lidar com erro ao buscar detalhes")
    
    // Testes de moedas
    @Test("Deve buscar currencies com sucesso")
    @Test("Deve lidar com erro ao buscar currencies")
    
    // Testes de formatação
    @Test("Deve formatar website corretamente")
    @Test("Deve formatar taxas")
    @Test("Deve formatar preços de moedas")
}
```

**Cobertura:**
- ✅ Inicialização com dados
- ✅ Busca de detalhes adicionais
- ✅ Busca de moedas/currencies
- ✅ Tratamento de erros
- ✅ Formatação de URLs
- ✅ Formatação de taxas (fees)
- ✅ Formatação de preços

#### **Mock Objects**

O projeto utiliza mocks para isolar testes:

```swift
final class MockCoinMarketCapService: CoinMarketCapService {
    var mockExchanges: [Exchange] = []
    var shouldFail = false
    var fetchExchangesCalled = false
    // ... outros mocks
}

class MockExchangeListDelegate: ExchangeListViewModelDelegate {
    var stateUpdateCount = 0
    var lastState: ViewState<[Exchange]>?
    // ... implementação
}
```

### 2. **Testes de Interface (UI Tests)**

Utilizam o **XCTest** framework para testes end-to-end.

#### **CoinMarketAppUITests** (14 testes)

```swift
// Testes de carregamento
✅ testExchangeListLoads()           // Verifica carregamento inicial
✅ testExchangeListDisplaysItems()   // Verifica exibição de itens
✅ testExchangeCellDisplaysInfo()    // Verifica conteúdo das células

// Testes de interação
✅ testPullToRefresh()               // Testa pull-to-refresh
✅ testScrollToBottom()              // Testa scroll e paginação
✅ testNavigationToDetail()          // Testa navegação para detalhes
✅ testBackNavigation()              // Testa voltar da navegação

// Testes de detalhes
✅ testExchangeDetailDisplaysInfo()  // Verifica informações nos detalhes
✅ testExchangeDetailScrolls()       // Testa scroll na tela de detalhes
✅ testExchangeDetailDisplaysCurrencies() // Verifica exibição de moedas

// Testes de erro
✅ testErrorAlertDisplays()          // Testa exibição de alertas

// Testes de performance
✅ testLaunchPerformance()           // Mede tempo de inicialização
✅ testScrollPerformance()           // Mede performance de scroll

// Testes de acessibilidade
✅ testAccessibility()               // Verifica elementos acessíveis
```

**Cobertura UI:**
- ✅ Navegação entre telas
- ✅ Exibição de dados
- ✅ Interações do usuário
- ✅ Pull-to-refresh
- ✅ Scroll e paginação
- ✅ Tratamento de erros
- ✅ Performance
- ✅ Acessibilidade

### 3. **Testes de Integração (Service Tests)**

```swift
// Testes de API
✅ Requisições HTTP bem-sucedidas
✅ Tratamento de erros de rede
✅ Decodificação JSON
✅ Sistema de retry
✅ Timeout handling
```

### Cobertura de Código

O projeto mantém cobertura de código:
- ViewModels: ~85%
- Services: ~75%
- Models: ~90%

## 🚀 Instalação

### Requisitos

- Xcode 15.0+
- iOS 15.0+
- Swift 5.9+
- Conexão com internet

### Passos

1. Clone o repositório
2. Abra o projeto no Xcode
3. Selecione o simulador ou dispositivo de destino
4. Execute o projeto

## 📱 Uso

### Navegação Básica

1. **Tela Inicial (Splash)**
   - Aguarde a animação de loading (2.5s)
   - Transição automática para lista de exchanges

2. **Lista de Exchanges**
   - Scroll para ver mais exchanges
   - Pull-down para atualizar
   - Toque em uma exchange para ver detalhes

3. **Detalhes da Exchange**
   - Visualize informações completas
   - Scroll down para ver moedas suportadas
   - Toque no botão de voltar ao topo (aparece após scroll)
   - Use botão back para retornar

### Recursos Especiais

- **Paginação automática**: Novos dados carregam ao chegar no fim da lista
- **Retry em erros**: Caso haja erro, tente novamente pelo alerta ou pull-to-refresh
- **Cache de imagens**: Imagens são mantidas em cache para melhor performance

## 🛠 Tecnologias

### Core
- **Swift 5.9+**: Linguagem principal
- **UIKit**: Framework de interface
- **Swift Concurrency**: async/await para operações assíncronas

### Networking
- **URLSession**: Requisições HTTP
- **Codable**: Serialização/deserialização JSON
- **Combine**: (preparado para uso futuro)

### Testing
- **Swift Testing**: Framework moderno com macros
- **XCTest**: Testes de UI e integração

### Patterns & Architecture
- **MVVM**: Arquitetura principal
- **Delegation**: Comunicação entre camadas
- **Dependency Injection**: Injeção de dependências
- **Generic Types**: ViewState genérico

### APIs Externas
- **CoinMarketCap API**: Dados de exchanges e criptomoedas

## 📝 Próximos Passos

### Melhorias Possíveis

- [ ] Implementar pesquisa de exchanges
- [ ] Adicionar filtros por volume, data, etc.
- [ ] Implementar favoritos com persistência local (Core Data/UserDefaults)
- [ ] Adicionar gráficos de volume
- [ ] Modo escuro completo
- [ ] Suporte a múltiplos idiomas (i18n)
- [ ] Widget para tela inicial
- [ ] Notificações push para mudanças de preço
- [ ] Implementar cache de dados com expiração

### Otimizações Técnicas

- [ ] Implementar image cache com SDWebImage ou Kingfisher
- [ ] Adicionar retry exponential backoff
- [ ] Implementar rate limiting
- [ ] Adicionar analytics
- [ ] Melhorar tratamento de erros
- [ ] Implementar logging estruturado
- [ ] Adicionar testes de snapshot

## 📄 Licença

Este projeto é licenciado sob a MIT License - veja o arquivo LICENSE para detalhes.

## 👤 Autor

**Hayna Cardoso**
- Data de criação: 21/02/26

---

Desenvolvido com ☕ usando Swift e UIKit
