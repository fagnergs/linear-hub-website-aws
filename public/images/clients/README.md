# Logos dos Clientes

Este diretório contém os logos das empresas clientes exibidos na seção "Clientes" do site.

## 📋 Logos Necessários

Adicione os seguintes arquivos de logo neste diretório:

1. **equatorial.svg** ou **equatorial.png** - Grupo Equatorial
2. **brasilbiofuels.svg** ou **brasilbiofuels.png** - Brasil Biofuels
3. **energisa.svg** ou **energisa.png** - Energisa
4. **jhsf.svg** ou **jhsf.png** - JHSF

## 🎨 Especificações Recomendadas

### Formato
- **Preferível:** SVG (vetorial, escala perfeita)
- **Alternativo:** PNG com fundo transparente

### Dimensões
- **Largura:** 200-400px
- **Altura:** 80-120px
- **Proporção:** Manter proporção original do logo

### Qualidade
- **Resolução:** Alta (mínimo 150 DPI para PNG)
- **Fundo:** Transparente
- **Cores:** Preferencialmente versão colorida (o site aplica filtro grayscale automaticamente)

## 📂 Estrutura de Arquivos

```
public/images/clients/
├── README.md (este arquivo)
├── equatorial.svg
├── brasilbiofuels.svg
├── energisa.svg
└── jhsf.svg
```

## 🔧 Como Adicionar um Novo Cliente

### 1. Adicionar o Logo
Coloque o arquivo do logo neste diretório (`public/images/clients/`).

### 2. Atualizar o Componente
Edite o arquivo `components/sections/Clients.tsx`:

```typescript
const clients = [
  // ... logos existentes
  {
    name: 'Nome da Empresa',
    logo: '/images/clients/nome-empresa.svg', // ou .png
    url: 'https://www.empresa.com.br/',
  },
];
```

## 🎯 Efeitos Visuais

Os logos têm os seguintes efeitos automáticos:
- ✅ **Grayscale por padrão** - Logos aparecem em escala de cinza
- ✅ **Colorido ao hover** - Cores originais aparecem ao passar o mouse
- ✅ **Elevação 3D** - Card sobe levemente ao hover
- ✅ **Sombra dinâmica** - Sombra aumenta ao hover
- ✅ **Otimização automática** - Next.js otimiza as imagens

## 📝 Onde Obter os Logos

### Opção 1: Site Oficial da Empresa
1. Acesse a página "Imprensa" ou "Media Kit"
2. Baixe o logo oficial em alta qualidade
3. Prefira a versão horizontal/landscape

### Opção 2: Brandfetch
1. Acesse https://brandfetch.com
2. Busque pelo nome da empresa
3. Baixe o logo em SVG ou PNG

### Opção 3: Solicitar ao Cliente
Entre em contato com o departamento de marketing da empresa.

## ⚠️ Importante

- **Direitos autorais:** Use apenas logos com permissão ou de domínio público
- **Marca registrada:** Respeite as diretrizes de uso da marca de cada empresa
- **Qualidade:** Evite logos de baixa qualidade que possam pixelizar

## 🚀 Exemplo de Uso

Depois de adicionar os logos, o componente automaticamente:
1. Carrega as imagens otimizadas
2. Aplica efeito grayscale
3. Mostra cores ao hover
4. Links para o site da empresa ao clicar

## 🐛 Troubleshooting

### Logo não aparece
- Verifique se o caminho está correto: `/images/clients/nome.svg`
- Confirme que o arquivo está neste diretório
- Reinicie o servidor de desenvolvimento

### Logo pixelizado
- Use SVG ao invés de PNG
- Ou aumente a resolução do PNG (mínimo 300x120px)

### Logo muito grande/pequeno
- Ajuste usando ferramentas como Figma, Illustrator ou GIMP
- Mantenha proporção entre 2:1 e 4:1 (largura:altura)
