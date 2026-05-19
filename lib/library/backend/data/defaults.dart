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
    'neuro': 'assets/characters/neuro.webp',
    'ally': 'assets/characters/ally.webp',
    'jannano128k': 'assets/models/jannano128k.webp',
    'gptneox': 'assets/models/gptneox.webp',
    'supernova-medius': 'assets/producers/arceeai.webp',
    'nanobanana': 'assets/models/banana.webp',
    'nano banana': 'assets/models/banana.webp',
    'nano-banana': 'assets/models/banana.webp',
    'hermes-2-pro-mistral-7b': 'assets/models/hermes.webp',

    // All roleplay characters are treated as exact IDs.
    'teacher': 'assets/characters/teacher.webp',
    'doctor': 'assets/characters/doctor.webp',
    'animegirl': 'assets/characters/animegirl.webp',
    'astronaut': 'assets/characters/astronaut.webp',
    'psychologist': 'assets/characters/psychologist.webp',
    'gamer': 'assets/characters/gamer.webp',
    'hacker': 'assets/characters/hacker.webp',
    'athlete': 'assets/characters/athlete.webp',
    'trash': 'assets/characters/trash.webp',
    'tree': 'assets/characters/tree.webp',
    'chef': 'assets/characters/chef.webp',
    'lawyer': 'assets/characters/lawyer.webp',
    'engineer': 'assets/characters/engineer.webp',
    'crazy': 'assets/characters/crazy.webp',
    'baby': 'assets/characters/baby.webp',
    'police': 'assets/characters/police.webp',
    'scientist': 'assets/characters/scientist.webp',
    'dj': 'assets/characters/dj.webp',
    'lover': 'assets/characters/lover.webp',
    'shaver': 'assets/characters/shaver.webp',
    'detective': 'assets/characters/detective.webp',
    'grandmother': 'assets/characters/grandmother.webp',
    'miner': 'assets/characters/miner.webp',
    'rich': 'assets/characters/rich.webp',
    'philosopher': 'assets/characters/philosopher.webp',

    // --- PRIORITY 2: MODEL FAMILIES / SERIES ---
    // These keys will match if a model's ID *contains* them. Longer keys are prioritized.
    // (e.g., 'gpt-3.5-turbo' will match 'gpt-')
    'gpt': 'assets/producers/openai.webp',
    // Catches gpt-3.5, gpt-4, etc.
    'chatgpt': 'assets/producers/openai.webp',
    'claude': 'assets/models/claude.webp',
    'codex': 'assets/models/codex.webp',
    'deepseek': 'assets/models/deepseek.webp',
    'gpt-image': 'assets/producers/openai.webp',
    'qwen': 'assets/models/qwen.webp',
    'qwen-image': 'assets/models/qwen.webp',
    'gemini': 'assets/models/gemini.webp',
    'lyria': 'assets/models/lyria.webp',
    'gemma': 'assets/models/gemma.webp',
    'grok': 'assets/models/grok.webp',
    'xai-image': 'assets/producers/xai.webp',
    'hermes': 'assets/models/hermes.webp',
    'codestral': 'assets/models/codestral.webp',
    'mai': 'assets/models/mai.webp',
    'ministral': 'assets/models/ministral.webp',
    'mixtral': 'assets/models/mixtral.webp',
    'pixtral': 'assets/models/pixtral.webp',
    'magistral': 'assets/models/magistral.webp',
    'devstral': 'assets/models/devstral.webp',
    'phi': 'assets/models/phi.webp',
    // Catches phi-3, phi-4, etc.
    'wizardlm': 'assets/models/wizardlm.webp',
    'tinyllama': 'assets/models/tinyllama.webp',
    'llama': 'assets/models/llama.webp',
    'command': 'assets/models/cohere.webp',
    'nova': 'assets/models/nova.webp',
    'perplexity': 'assets/models/perplexity.webp',
    'lfm': 'assets/producers/liquidai.webp',
    'flux': 'assets/models/flux.webp',
    'ideogram': 'assets/models/ideogram.webp',
    'imagen': 'assets/models/imagen.webp',
    'kling': 'assets/models/kling.webp',
    'pixverse': 'assets/models/pixverse.webp',
    'sdxl': 'assets/models/sdxl.webp',
    'sora': 'assets/models/sora.webp',
    'topaz': 'assets/models/topaz.webp',
    'wan': 'assets/models/wan.webp',
    'z-image': 'assets/producers/z.ai.webp',
    'bria': 'assets/models/bria.webp',
    'bytedance': 'assets/models/bytedance.webp',
    'seedance': 'assets/models/seedance.webp',
    'seedream': 'assets/models/seedream.webp',
    'minimax': 'assets/producers/minimax.webp',
    'elevenlabs': 'assets/models/elevenlabs.webp',
    'ernie': 'assets/models/ernie.webp',
    // Placeholder fallback if Ernie logo missing
    'fabric': 'assets/models/cohere.webp',
    // Placeholder
    'veo': 'assets/models/veo.webp',
    // Veo is Google's
    'seedvr': 'assets/producers/seedvr.webp',
    // Placeholder
    'grok-imagine': 'assets/models/grok.webp',
    'suno': 'assets/models/suno.webp',
    'musicgen': 'assets/models/meta.webp',
    'stable': 'assets/models/stable.webp',
    'stable-audio': 'assets/models/stable.webp',
    'whisper': 'assets/models/whisper.webp',
    'banana': 'assets/models/banana.webp',

    // --- PRIORITY 3: PRODUCERS (FALLBACK) ---
    // This is the last resort if no better match is found. Keys are simplified for broader matching.
    'openai': 'assets/producers/openai.webp',
    'anthropic': 'assets/producers/anthropic.webp',
    'amazon': 'assets/producers/amazon.webp',
    'google': 'assets/producers/google.webp',
    'xai': 'assets/producers/xai.webp',
    'arcee': 'assets/producers/arceeai.webp',
    'nousresearch': 'assets/producers/nousresearch.webp',
    'mistral': 'assets/models/mistral.webp',
    'microsoft': 'assets/producers/microsoft.webp',
    'meta': 'assets/models/meta.webp',
    'cohere': 'assets/models/cohere.webp',
    'unsloth': 'assets/producers/unslothai.webp',
    'menlo': 'assets/producers/menloresearch.webp',
    'thebloke': 'assets/producers/thebloke.webp',
    'snowflake': 'assets/producers/snowflake.webp',
    'secondstate': 'assets/producers/secondstate.webp',
    'modular': 'assets/producers/modularai.webp',
    'intel': 'assets/producers/intel.webp',
    'ggml': 'assets/producers/ggmlorg.webp',
    'fortytwonetwork': 'assets/producers/fortytwonetwork.webp',
    'devquasar': 'assets/producers/devquasar.webp',
    'defog': 'assets/producers/defogai.webp',
    'lamapi': 'assets/producers/lamapi.webp',
    'liquid': 'assets/producers/liquidai.webp',
    'mazyarpanahi': 'assets/producers/maziyarpanahi.webp',
    'maziyarpanahi': 'assets/producers/maziyarpanahi.webp',
    'neuphonic': 'assets/producers/neuphonic.webp',
    'jetbrains': 'assets/producers/jetbrains.webp',
    'zed': 'assets/producers/zed.webp',
    'lm': 'assets/producers/lmstudiocommunity.webp',
    'midjourney': 'assets/producers/midjourney.webp',
    'runway': 'assets/producers/runway.webp',
    'veed': 'assets/producers/veed.webp',
    'moonshot': 'assets/producers/moonshotai.webp',
    'z.ai': 'assets/producers/z.ai.webp',
    'ibm': 'assets/producers/ibm.webp',
    'inclusion': 'assets/producers/inclusionai.webp',
    'nvidia': 'assets/producers/nvidia.webp'
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
    'context': '128000',

    // Localized Summaries
    'summary': {
      'en': 'Advanced AI Intelligence',
      'tr': 'Gelişmiş Yapay Zekâ',
      'ku': 'Zekâya Hunerî ya Pêşketî',
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
      'en':
          'Cortex intelligently analyzes your request and activates the most capable AI model available to provide the best possible answer.',
      'tr':
          'Cortex, isteğinizi analiz eder ve en iyi cevabı sunmak için mevcut en yetenekli yapay zekâ modelini devreye sokar.',
      'ku':
          'Cortex daxwaza we bi awayekî aqilmend analîz dike û modela AI ya herî jêhatî çalak dike da ku bersiva herî baş bide.',
      'es':
          'Cortex analiza inteligentemente tu solicitud y activa el modelo de IA más capaz disponible para dar la mejor respuesta.',
      'fr':
          'Cortex analyse intelligemment votre demande et active le modèle d\'IA le plus performant pour fournir la meilleure réponse.',
      'de':
          'Cortex analysiert Ihre Anfrage intelligent und aktiviert das fähigste verfügbare KI-Modell, um die bestmögliche Antwort zu geben.',
      'it':
          'Cortex analizza intelligentemente la tua richiesta e attiva il modello AI più capace disponibile per fornire la migliore risposta.',
      'pt':
          'O Cortex analisa inteligentemente seu pedido e ativa o modelo de IA mais capaz disponível para fornecer a melhor resposta.',
      'ru':
          'Cortex анализирует ваш запрос и активирует самую мощную доступную модель ИИ для предоставления наилучшего ответа.',
      'zh': 'Cortex 智能分析您的请求，并激活现有的最强 AI 模型以提供最佳答案。',
      'ja': 'Cortexはリクエストをインテリジェントに分析し、利用可能な最も高性能なAIモデルを起動して最適な回答を提供します。',
      'ko': 'Cortex는 귀하의 요청을 지능적으로 분석하고 가장 뛰어난 AI 모델을 활성화하여 최상의 답변을 제공합니다.',
      'ar':
          'يقوم Cortex بتحليل طلبك بذكاء وتنشيط نموذج الذكاء الاصطناعي الأكثر قدرة لتقديم أفضل إجابة ممكنة.',
      'hi':
          'Cortex आपके अनुरोध का बुद्धिमानी से विश्लेषण करता है और सर्वोत्तम संभव उत्तर प्रदान करने के लिए सबसे सक्षम AI मॉडल को सक्रिय करता है।',
      'id':
          'Cortex menganalisis permintaan Anda dengan cerdas dan mengaktifkan model AI paling mumpuni yang tersedia untuk memberikan jawaban terbaik.',
    }
  };

  // --- CHAT FORMAT TEMPLATES ---

  static const Map<String, dynamic> _chatmlFormat = {
    'template': 'chatml',
    'tokens': {
      'system_start': '<|im_start|>system\n',
      'system_end': '<|im_end|>\n',
      'user_start': '<|im_start|>user\n',
      'user_end': '<|im_end|>\n',
      'assistant_start': '<|im_start|>assistant\n',
      'assistant_end': '<|im_end|>\n',
      'stop_generation': ['<|im_end|>', '<|endoftext|>'],
    }
  };

  static const Map<String, dynamic> _llama3Format = {
    'template': 'llama3',
    'tokens': {
      'system_start':
          '<|begin_of_text|><|start_header_id|>system<|end_header_id|>\n\n',
      'system_end': '<|eot_id|>',
      'user_start': '<|start_header_id|>user<|end_header_id|>\n\n',
      'user_end': '<|eot_id|>',
      'assistant_start': '<|start_header_id|>assistant<|end_header_id|>\n\n',
      'assistant_end': '<|eot_id|>',
      'stop_generation': ['<|eot_id|>', '<|end_of_text|>'],
    }
  };

  static const Map<String, dynamic> _gemmaFormat = {
    'template': 'gemma',
    'tokens': {
      'user_start': '<start_of_turn>user\n',
      'user_end': '<end_of_turn>\n',
      'assistant_start': '<start_of_turn>model\n',
      'assistant_end': '<end_of_turn>\n',
      'stop_generation': ['<end_of_turn>', '<eos>'],
    }
  };

  static const Map<String, dynamic> _phi3Format = {
    'template': 'phi3',
    'tokens': {
      'system_start': '<|system|>\n',
      'system_end': '<|end|>\n',
      'user_start': '<|user|>\n',
      'user_end': '<|end|>\n',
      'assistant_start': '<|assistant|>\n',
      'assistant_end': '<|end|>\n',
      'stop_generation': ['<|end|>', '<|endoftext|>'],
    }
  };

  /// Returns a smart fallback format based on the model ID.
  /// If the ID matches a known family (Llama 3, Gemma, etc.), returns that specific format.
  /// Otherwise, returns ChatML as the safest general default.
  static Map<String, dynamic> getFallbackFormat(String modelId) {
    final id = modelId.toLowerCase();

    if (id.contains('llama-3') || id.contains('llama3')) {
      return _llama3Format;
    }
    if (id.contains('gemma')) {
      return _gemmaFormat;
    }
    if (id.contains('phi-3') || id.contains('phi3')) {
      return _phi3Format;
    }

    // Default to ChatML for Qwen, Mistral, and others as they often support it or are fine-tuned on it.
    return _chatmlFormat;
  }

  /// Expose generic ChatML for backward compatibility/direct usage
  static const Map<String, dynamic> defaultChatFormat = _chatmlFormat;
}
