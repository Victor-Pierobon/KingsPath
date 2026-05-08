import '../core/models/quest.dart';

// XP armazenado como 0 — valor real calculado dinamicamente pelo nível global no momento da conclusão
final systemQuests = <Quest>[
  // Físico
  _sq('sq001', 'Fazer 20 flexões agora mesmo', 'fisico', QuestDifficulty.facil),
  _sq('sq002', '30 minutos de caminhada', 'fisico', QuestDifficulty.facil),
  _sq('sq003', '1 hora de academia', 'fisico', QuestDifficulty.medio),
  _sq('sq004', 'Subir escadas em vez de elevador por um dia', 'fisico', QuestDifficulty.facil),
  _sq('sq015', 'Correr 3km no menor tempo possível', 'fisico', QuestDifficulty.medio),
  _sq('sq016', '15 minutos de HIIT', 'fisico', QuestDifficulty.medio),
  _sq('sq018', 'Pular corda por 10 minutos', 'fisico', QuestDifficulty.facil),

  // Inteligência
  _sq('sq005', 'Ler 1 capítulo de um livro técnico', 'inteligencia', QuestDifficulty.facil),
  _sq('sq006', 'Resolver 1 exercício de lógica ou algoritmo', 'inteligencia', QuestDifficulty.facil),
  _sq('sq007', 'Assistir 1 aula de um curso online', 'inteligencia', QuestDifficulty.medio),
  _sq('sq008', 'Ler um artigo sobre um tema novo', 'inteligencia', QuestDifficulty.facil),
  _sq('sq009', 'Aprender 10 palavras em outro idioma', 'inteligencia', QuestDifficulty.facil),

  // Sabedoria
  _sq('sq010', 'Escrever 10 minutos no diário', 'sabedoria', QuestDifficulty.facil),
  _sq('sq011', 'Meditar por 10 minutos', 'sabedoria', QuestDifficulty.facil),
  _sq('sq012', 'Refletir sobre uma decisão difícil recente', 'sabedoria', QuestDifficulty.medio),
  _sq('sq013', 'Ler um trecho de filosofia ou estoicismo', 'sabedoria', QuestDifficulty.facil),
  _sq('sq014', 'Identificar 3 coisas pelas quais é grato hoje', 'sabedoria', QuestDifficulty.facil),

  // Espiritualidade
  _sq('sq017', 'Sessão de yoga com foco em respiração e presença', 'espiritualidade', QuestDifficulty.facil),
  _sq('sq029', 'Meditar profundamente por 15 minutos', 'espiritualidade', QuestDifficulty.medio),
  _sq('sq030', 'Escrever sobre seu propósito e valores de vida', 'espiritualidade', QuestDifficulty.medio),
  _sq('sq031', 'Passar 20 minutos em silêncio contemplativo', 'espiritualidade', QuestDifficulty.facil),
  _sq('sq032', 'Fazer uma prática espiritual pessoal (oração, ritual)', 'espiritualidade', QuestDifficulty.facil),
  _sq('sq033', 'Ler um texto sobre espiritualidade ou filosofia de vida', 'espiritualidade', QuestDifficulty.facil),

  // Carisma
  _sq('sq019', 'Gravar um vídeo de 2 minutos falando sobre algo que domina', 'carisma', QuestDifficulty.medio),
  _sq('sq020', 'Praticar uma abertura de conversa com um desconhecido', 'carisma', QuestDifficulty.medio),
  _sq('sq021', 'Pesquisar e aplicar 1 regra de etiqueta nova', 'carisma', QuestDifficulty.facil),
  _sq('sq022', 'Se arrumar completamente mesmo sem sair de casa', 'carisma', QuestDifficulty.facil),
  _sq('sq023', 'Escrever um post ou comentário público sobre algo relevante', 'carisma', QuestDifficulty.facil),

  // Relacionamento
  _sq('sq024', 'Ligar (não mensagem) para um amigo que não fala há semanas', 'relacionamento', QuestDifficulty.medio),
  _sq('sq025', 'Marcar um encontro social (presencial)', 'relacionamento', QuestDifficulty.medio),
  _sq('sq026', 'Enviar uma mensagem genuína de incentivo a alguém', 'relacionamento', QuestDifficulty.facil),
  _sq('sq027', 'Conhecer alguém novo (online ou presencial)', 'relacionamento', QuestDifficulty.facil),
  _sq('sq028', 'Fazer algo inesperado e gentil por alguém próximo', 'relacionamento', QuestDifficulty.facil),
];

Quest _sq(String id, String title, String attribute, QuestDifficulty difficulty) => Quest(
      id: id,
      title: title,
      description: '',
      xpPerAttribute: {attribute: 0}, // calculado dinamicamente ao concluir
      difficulty: difficulty,
      recurrence: QuestRecurrence.none,
      status: QuestStatus.pending,
      createdAt: DateTime(2026),
      isSystemQuest: true,
    );
