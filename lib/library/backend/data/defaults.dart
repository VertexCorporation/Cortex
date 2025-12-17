// lib/library/backend/data/defaults.dart

// This file contains static configuration data and default fallbacks for models.
// Separating this data from the service layer keeps the logic clean and readable.

class ModelDefaults {

  /// A map of predefined local asset paths for common models, structured by matching priority.
  /// The matching logic will check these in order:
  /// 1. Exact ID matches for specific models.
  /// 2. Partial "family" matches (e.g., 'phi' for 'phi-4').
  /// 3. General producer fallbacks (e.g., 'google' for any Google model).
  /// All keys must be lowercase for consistent matching.
  static final Map<String, String> localAssetImageMap = {
    // --- PRIORITY 1: EXACT MODEL IDS ---
    // Use this for specific models that need a unique image, overriding any family/producer rule.
    'neuro': 'assets/characters/neuro.jpg',
    'jannano128k': 'assets/models/jannano128k.jpg',
    'gptneox': 'assets/models/gptneox.jpg',
    'supernova-medius': 'assets/producers/arceeai.jpg',
    'hermes-2-pro-mistral-7b': 'assets/models/hermes.jpg',

    // All roleplay characters are treated as exact IDs.
    'teacher': 'assets/characters/teacher.jpg',
    'doctor': 'assets/characters/doctor.jpg',
    'animegirl': 'assets/characters/animegirl.jpg',
    'astronaut': 'assets/characters/astronaut.jpg',
    'psychologist': 'assets/characters/psychologist.jpg',
    'gamer': 'assets/characters/gamer.jpg',
    'hacker': 'assets/characters/hacker.jpg',
    'athlete': 'assets/characters/athlete.jpg',
    'trash': 'assets/characters/trash.jpg',
    'tree': 'assets/characters/tree.jpg',
    'chef': 'assets/characters/chef.jpg',
    'lawyer': 'assets/characters/lawyer.jpg',
    'engineer': 'assets/characters/engineer.jpg',
    'crazy': 'assets/characters/crazy.jpg',
    'baby': 'assets/characters/baby.jpg',
    'police': 'assets/characters/police.jpg',
    'scientist': 'assets/characters/scientist.jpg',
    'dj': 'assets/characters/dj.jpg',
    'lover': 'assets/characters/lover.jpg',
    'shaver': 'assets/characters/shaver.jpg',
    'detective': 'assets/characters/detective.jpg',
    'grandmother': 'assets/characters/grandmother.jpg',
    'miner': 'assets/characters/miner.jpg',

    // --- PRIORITY 2: MODEL FAMILIES / SERIES ---
    // These keys will match if a model's ID *contains* them. Longer keys are prioritized.
    // (e.g., 'gpt-3.5-turbo' will match 'gpt-')
    'gpt': 'assets/producers/openai.jpg', // Catches gpt-3.5, gpt-4, etc.
    'chatgpt': 'assets/producers/openai.jpg',
    'claude': 'assets/models/claude.jpg',
    'codex': 'assets/models/codex.jpg',
    'deepseek': 'assets/models/deepseek.jpg',
    'qwen': 'assets/models/qwen.png',
    'gemini': 'assets/models/gemini.png',
    'gemma': 'assets/models/gemma.jpg',
    'grok': 'assets/models/grok.jpg',
    'hermes': 'assets/models/hermes.jpg',
    'codestral': 'assets/models/codestral.jpg',
    'mai': 'assets/models/mai.jpg',
    'ministral': 'assets/models/ministral.jpg',
    'mixtral': 'assets/models/mixtral.jpg',
    'pixtral': 'assets/models/pixtral.jpg',
    'magistral': 'assets/models/magistral.jpg',
    'devstral': 'assets/models/devstral.jpg',
    'phi': 'assets/models/phi.png', // Catches phi-3, phi-4, etc.
    'wizardlm': 'assets/models/wizardlm.jpg',
    'tinyllama': 'assets/models/tinyllama.png',
    'llama': 'assets/models/llama.png',
    'command': 'assets/models/cohere.jpg',
    'nova': 'assets/models/nova.jpg', // Assuming you have an Amazon logo
    'perplexity': 'assets/models/perplexity.jpg',
    'lfm': 'assets/producers/liquidai.jpg',

    // --- PRIORITY 3: PRODUCERS (FALLBACK) ---
    // This is the last resort if no better match is found. Keys are simplified for broader matching.
    'openai': 'assets/producers/openai.jpg',
    'anthropic': 'assets/producers/anthropic.jpg',
    'amazon': 'assets/producers/amazon.jpg',
    'google': 'assets/producers/google.jpg',
    'xai': 'assets/producers/xai.jpg',
    'arcee': 'assets/producers/arceeai.jpg',
    'nousresearch': 'assets/producers/nousresearch.jpg',
    'mistral': 'assets/models/mistral.jpg',
    'microsoft': 'assets/producers/microsoft.jpg',
    'meta': 'assets/models/llama.png',
    'cohere': 'assets/models/cohere.jpg',
    'unsloth': 'assets/producers/unslothhai.jpg',
    'menlo': 'assets/producers/menloresearch.jpg',
    'thebloke': 'assets/producers/thebloke.jpg',
    'snowflake': 'assets/producers/snowflake.jpg',
    'secondstate': 'assets/producers/secondstate.jpg',
    'modular': 'assets/producers/modularai.jpg',
    'intel': 'assets/producers/intel.jpg',
    'ggml': 'assets/producers/ggmlorg.jpg',
    'fortytwonetwork': 'assets/producers/fortytwonetwork.jpg',
    'devquasar': 'assets/producers/devquasar.jpg',
    'defog': 'assets/producers/defogai.jpg',
    'lamapi': 'assets/producers/lamapi.jpg',
    'liquid': 'assets/producers/liquidai.jpg',
    'mazyarpanahi': 'assets/producers/mazyarpanahi.jpg',
    'neuphonic': 'assets/producers/neuphonic.jpg',
    'jetbrains': 'assets/producers/jetbrains.png',
    'zed': 'assets/producers/zed.jpg',
    'lm': 'assets/producers/lmstudiocommunity.jpg',
    'moonshot': 'assets/producers/moonshotai.jpg',
    'z.ai': 'assets/producers/z.ai.jpg',
    'ibm': 'assets/producers/ibm.jpg',
    'inclusion': 'assets/producers/inclusionai.jpg',
    'nvidia': 'assets/producers/nvidia.jpg'
  };

  // This map acts as a local hardcoded entry for the virtual Cortex model.
  // Updates require an app update, which aligns with adding new languages.
  static const Map<String, dynamic> cortexDynamicChatData = {
    'id': 'cortex/auto',
    'title': 'Cortex',
    'producer': 'Vertex',
    'type': 'online',
    'category': 'general',
    'tier': 'free',
    'imagePath': 'assets/cortex.svg',
    'modalities': {'text': true, 'image': true},
    'outputs': {'text': true},
    'isFullyLocalized': true,
    'context': '128k',

    // Localized Summaries
    'summary': {
      'en': 'Advanced AI Intelligence',
      'tr': 'Gelişmiş Yapay Zeka',
      'ku': 'Zekaya Hunerî ya Pêşketî',
      'es': 'Inteligencia Artificial Avanzada',
      'fr': 'Intelligence Artificielle Avancée',
      'de': 'Fortschrittliche KI-Intelligenz',
      'it': 'Intelligenza Artificiale Avanzata',
      'pt': 'Inteligência Artificial Avançada',
      'ru': 'Продвинутый Искусственный Интеллект',
      'zh': '高级人工智能',
      'ja': '高度なAIインテリジェンス',
      'ko': '고급 AI 인텔리전스',
      'ar': 'ذكاء اصطناعي متقدم',
      'hi': 'उन्नत एआई इंटेलिजेंस',
      'id': 'Kecerdasan AI Tingkat Lanjut',
      'nl': 'Geavanceerde AI-intelligentie',
      'pl': 'Zaawansowana Sztuczna Inteligencja',
    },

    // Localized Descriptions
    'description': {
      'en': 'Cortex intelligently analyzes your request and activates the most capable AI model available to provide the best possible answer.',
      'tr': 'Cortex, isteğinizi analiz eder ve en iyi cevabı sunmak için mevcut en yetenekli yapay zeka modelini devreye sokar.',
      'ku': 'Cortex daxwaza we bi awayekî aqilmend analîz dike û modela AI ya herî jêhatî çalak dike da ku bersiva herî baş bide.',
      'es': 'Cortex analiza inteligentemente tu solicitud y activa el modelo de IA más capaz disponible para dar la mejor respuesta.',
      'fr': 'Cortex analyse intelligemment votre demande et active le modèle d\'IA le plus performant pour fournir la meilleure réponse.',
      'de': 'Cortex analysiert Ihre Anfrage intelligent und aktiviert das fähigste verfügbare KI-Modell, um die bestmögliche Antwort zu geben.',
      'it': 'Cortex analizza intelligentemente la tua richiesta e attiva il modello AI più capace disponibile per fornire la migliore risposta.',
      'pt': 'O Cortex analisa inteligentemente seu pedido e ativa o modelo de IA mais capaz disponível para fornecer a melhor resposta.',
      'ru': 'Cortex анализирует ваш запрос и активирует самую мощную доступную модель ИИ для предоставления наилучшего ответа.',
      'zh': 'Cortex 智能分析您的请求，并激活现有的最强 AI 模型以提供最佳答案。',
      'ja': 'Cortexはリクエストをインテリジェントに分析し、利用可能な最も高性能なAIモデルを起動して最適な回答を提供します。',
      'ko': 'Cortex는 귀하의 요청을 지능적으로 분석하고 가장 뛰어난 AI 모델을 활성화하여 최상의 답변을 제공합니다.',
      'ar': 'يقوم Cortex بتحليل طلبك بذكاء وتنشيط نموذج الذكاء الاصطناعي الأكثر قدرة لتقديم أفضل إجابة ممكنة.',
      'hi': 'Cortex आपके अनुरोध का बुद्धिमानी से विश्लेषण करता है और सर्वोत्तम संभव उत्तर प्रदान करने के लिए सबसे सक्षम AI मॉडल को सक्रिय करता है।',
      'id': 'Cortex menganalisis permintaan Anda dengan cerdas dan mengaktifkan model AI paling mumpuni yang tersedia untuk memberikan jawaban terbaik.',
      'nl': 'Cortex analyseert uw verzoek intelligent en activeert het meest capabele AI-model dat beschikbaar is om het best mogelijke antwoord te geven.',
      'pl': 'Cortex inteligentnie analizuje Twoje żądanie i aktywuje najlepszy dostępny model AI, aby zapewnić najlepszą możliwą odpowiedź.',
    },
  };
}