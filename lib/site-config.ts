export const SITE_CONFIG = {
  name: 'luv',
  portfolioUrl: '#portfolio', // troque pelo link do portfólio
  discordUrl: '#contato', // troque pelo link do Discord
  bio: 'Tenho 15 anos e crio designs e Carrds com uma carinha única para cada projeto. Gosto de transformar ideias, referências e sentimentos em algo visual e especial.',
  characterImages: {
    left: null as string | null, // exemplo: '/characters/marin-left.png'
    right: null as string | null, // exemplo: '/characters/marin-right.png'
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
      { label: 'Carrd simples', price: 'R$ XX' },
      { label: 'Carrd personalizado', price: 'R$ XX' },
      { label: 'Carrd completo', price: 'R$ XX' },
    ],
    designs: [
      { label: 'Design simples', price: 'R$ XX' },
      { label: 'Banner', price: 'R$ XX' },
      { label: 'Layout', price: 'R$ XX' },
      { label: 'Outros', price: 'consultar' },
    ],
  },
} as const;
