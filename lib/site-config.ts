export const SITE_CONFIG = {
  name: 'luv',
  portfolioUrl: '#portfolio', // troque pelo link do portfólio
  discordUrl: '#contato', // troque pelo link do Discord
  bio: 'Tenho 15 anos e crio designs e Carrds com uma carinha única para cada projeto. Gosto de transformar ideias, referências e sentimentos em algo visual e especial.',

  characterImages: {
    left: 'public/characters/marin-left.png',
    right: 'public/characters/marin-right.png',
  },
  rules: [
    { title: 'pagamento', text: 'O pagamento deve ser combinado antes do início do projeto.' },
    { title: 'alterações', text: 'Pequenas alterações podem ser solicitadas durante o processo.' },
    { title: 'prazo', text: 'O prazo varia de acordo com a complexidade do pedido.' },
    { title: 'créditos', text: 'Não remova meus créditos quando eles fizerem parte do trabalho.' },
    { title: 'reembolso', text: 'As condições de reembolso são combinadas antes do início do pedido.' },
  ],
  prices: {
    carrds: [
      { label: 'Carrd simples', price: 'R$2,00' },
      { label: 'Carrd personalizado', price: 'R$4,00' },
      { label: 'Carrd completo', price: 'R$7,00' },
    ],
    designs: [
      { label: 'Design simples', price: 'R$4,00' },
      { label: 'Banner', price: 'R$2,00' },
      { label: 'Layout', price: 'R$6,00' },
      { label: 'Outros', price: 'consultar' },
    ],
  },
} as const;
