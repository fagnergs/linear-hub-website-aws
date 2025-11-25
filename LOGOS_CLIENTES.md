# 📊 Guia: Adicionar Logos dos Clientes

## ✅ Status Atual

O componente de clientes está **100% funcional** e pronto para exibir logos reais!

### Recursos Implementados:
- ✅ Suporte para SVG e PNG
- ✅ Otimização automática de imagens (Next.js Image)
- ✅ Efeito grayscale → colorido ao hover
- ✅ Animações suaves (elevação 3D, sombra)
- ✅ Links clicáveis para sites das empresas
- ✅ Logos placeholder temporários criados

## 🎯 Como Substituir pelos Logos Reais

### Método 1: Download Direto (Recomendado)

#### 1. Grupo Equatorial
```bash
# Opção A: Baixar do site oficial
# Acesse: https://www.equatorialenergia.com.br/imprensa

# Opção B: Usar Brandfetch
# https://brandfetch.com/equatorialenergia.com.br
```

Salve como: `public/images/clients/equatorial.svg`

#### 2. Brasil Biofuels
```bash
# Acesse: https://brasilbiofuels.com.br/
# Ou solicite ao contato da empresa
```

Salve como: `public/images/clients/brasilbiofuels.svg`

#### 3. Energisa
```bash
# Opção A: Site oficial
# https://www.energisa.com.br/imprensa

# Opção B: Brandfetch
# https://brandfetch.com/energisa.com.br
```

Salve como: `public/images/clients/energisa.svg`

#### 4. JHSF
```bash
# Acesse: https://www.jhsf.com.br/
# Ou área de imprensa/mídia kit
```

Salve como: `public/images/clients/jhsf.svg`

### Método 2: Extração de Sites

Use ferramentas como:
- **Image Downloader** (extensão Chrome)
- **Inspect Element** → copiar URL da imagem
- **Figma** para criar versão vetorial

### Método 3: Solicitar aos Clientes

Email template:
```
Assunto: Solicitação de Logo para Site Corporativo

Prezados,

Estamos atualizando nosso site corporativo e gostaríamos de incluir
o logo da [EMPRESA] em nossa seção de clientes/parceiros.

Poderiam nos fornecer:
- Logo em formato SVG ou PNG de alta qualidade
- Fundo transparente
- Versão horizontal (preferencial)

Desde já agradecemos!
```

## 📁 Onde Colocar os Arquivos

Todos os logos devem estar em:
```
public/images/clients/
```

Estrutura final:
```
public/images/clients/
├── README.md
├── equatorial.svg    ← Substituir
├── brasilbiofuels.svg ← Substituir
├── energisa.svg      ← Substituir
└── jhsf.svg          ← Substituir
```

## 🎨 Especificações Técnicas

### Formato Ideal: SVG
- Escalável sem perder qualidade
- Tamanho de arquivo menor
- Suporte a cores e gradientes

### Formato Alternativo: PNG
- **Resolução mínima:** 400x160px
- **Fundo:** Transparente
- **DPI:** 150+

### Proporções Recomendadas
- Largura: 200-400px
- Altura: 80-120px
- Ratio: 2:1 a 4:1

## 🚀 Passo a Passo Completo

### 1. Baixar os Logos
```bash
# Baixe os 4 logos nos formatos SVG ou PNG
```

### 2. Renomear os Arquivos
```bash
# Nomes exatos (case-sensitive):
equatorial.svg
brasilbiofuels.svg
energisa.svg
jhsf.svg
```

### 3. Mover para o Diretório
```bash
# No terminal, dentro do projeto:
mv ~/Downloads/logo-equatorial.svg public/images/clients/equatorial.svg
mv ~/Downloads/logo-brasil-biofuels.svg public/images/clients/brasilbiofuels.svg
mv ~/Downloads/logo-energisa.svg public/images/clients/energisa.svg
mv ~/Downloads/logo-jhsf.svg public/images/clients/jhsf.svg
```

### 4. Verificar
```bash
ls -lh public/images/clients/
```

Deve mostrar:
```
equatorial.svg
brasilbiofuels.svg
energisa.svg
jhsf.svg
README.md
```

### 5. Testar
```bash
npm run dev
```

Acesse: http://localhost:3000/#clients

## ✨ Adicionar Mais Clientes

Para adicionar novos clientes, edite:

**Arquivo:** `components/sections/Clients.tsx`

```typescript
const clients = [
  // ... existentes
  {
    name: 'Nova Empresa',
    logo: '/images/clients/nova-empresa.svg',
    url: 'https://www.novaempresa.com.br/',
  },
];
```

Depois adicione o arquivo do logo em `public/images/clients/nova-empresa.svg`

## 🎯 Efeitos Visuais Automáticos

O componente já está configurado com:
- **Grayscale padrão** - Todos os logos em cinza
- **Colorido ao hover** - Cores aparecem ao passar o mouse
- **Elevação 3D** - Card sobe ao hover
- **Sombra dinâmica** - Sombra aumenta ao hover
- **Link ativo** - Clique abre site da empresa

## 🔧 Personalização Avançada

### Alterar o Grid
```typescript
// De 4 colunas para 3:
<div className="grid grid-cols-2 md:grid-cols-3 gap-8">
```

### Remover Efeito Grayscale
```typescript
// Remover: grayscale group-hover:grayscale-0
<div className="relative w-full h-20 transition-all duration-300">
```

### Ajustar Altura dos Cards
```typescript
// Alterar: h-32 para h-40
<div className="... h-40">
```

## 📞 Onde Conseguir Ajuda

- **Logos não carregam?** Verifique o console do navegador (F12)
- **Logos pixelizados?** Use SVG ao invés de PNG
- **Problemas com Next.js Image?** Veja: https://nextjs.org/docs/api-reference/next/image

## ✅ Checklist Final

- [ ] Baixei os 4 logos em alta qualidade
- [ ] Renomeei com os nomes corretos
- [ ] Coloquei em `public/images/clients/`
- [ ] Testei no navegador (npm run dev)
- [ ] Logos aparecem em grayscale
- [ ] Logos ficam coloridos ao hover
- [ ] Links funcionam ao clicar

Pronto! Seção de clientes finalizada! 🎉
