import json
import os

translations = {
    "ar": {
        "defaultSeriesDescription": "{seriesName} هو ذكاء متقدم يعرض أداءً عاليًا على Cortex.",
        "defaultModelDescription": "{modelName} هو ذكاء اصطناعي عالي الأداء مدمج في نظام Cortex البيئي. مصمم للتعامل مع مجموعة واسعة من المهام المعقدة، ويوفر قدرات معالجة موثوقة وفعالة عالية. من خلال تقديم أوقات استجابة سريعة وقوة تحليلية متقدمة، فإنه يعزز إنتاجيتك اليومية بشكل كبير. يعمل هذا النموذج بسلاسة على البنية التحتية المحلية الآمنة لـ Cortex، ويمكنه مساعدتك في مجموعة واسعة من المهام، من العصف الذهني الإبداعي إلى التحليل الفني العميق. ابدأ باستكشاف إمكاناته الكاملة اليوم."
    },
    "az": {
        "defaultSeriesDescription": "{seriesName}, Cortex-də yüksək performans göstərən qabaqcıl bir zəkadır.",
        "defaultModelDescription": "{modelName}, Cortex ekosisteminə inteqrasiya olunmuş yüksək performanslı süni intellektdir. Geniş çeşidli mürəkkəb tapşırıqları həll etmək üçün nəzərdə tutulub, yüksək etibarlı və səmərəli emal imkanları təqdim edir. Sürətli cavab müddətləri və təkmil analitik gücü təqdim edərək, gündəlik məhsuldarlığınızı əhəmiyyətli dərəcədə artırır. Cortex-in təhlükəsiz yerli infrastrukturu üzərində tam inteqrasiya olunmuş şəkildə işləyən bu model yaradıcı fikir mübadiləsindən tutmuş dərin texniki analizlərə qədər geniş bir spektrdə sizə kömək edə bilər. Tam potensialını bu gündən kəşf etməyə başlayın."
    },
    "de": {
        "defaultSeriesDescription": "{seriesName} ist eine fortschrittliche Intelligenz, die auf Cortex hohe Leistung zeigt.",
        "defaultModelDescription": "{modelName} ist eine leistungsstarke künstliche Intelligenz, die in das Cortex-Ökosystem integriert ist. Es wurde entwickelt, um eine Vielzahl komplexer Aufgaben zu bewältigen und bietet hochzuverlässige und effiziente Verarbeitungsfunktionen. Durch schnelle Reaktionszeiten und erweiterte Analyseleistung steigert es Ihre tägliche Produktivität erheblich. Dieses Modell arbeitet nahtlos auf der sicheren lokalen Infrastruktur von Cortex und kann Sie bei einer Vielzahl von Aufgaben unterstützen, vom kreativen Brainstorming bis hin zur tiefgehenden technischen Analyse. Beginnen Sie noch heute damit, sein volles Potenzial auszuschöpfen."
    },
    "es": {
        "defaultSeriesDescription": "{seriesName} es una inteligencia avanzada que muestra un alto rendimiento en Cortex.",
        "defaultModelDescription": "{modelName} es una inteligencia artificial de alto rendimiento integrada en el ecosistema Cortex. Diseñada para conquistar una amplia variedad de tareas complejas, proporciona capacidades de procesamiento altamente confiables y eficientes. Al ofrecer tiempos de respuesta rápidos y poder analítico avanzado, aumenta significativamente su productividad diaria. Operando sin problemas en la infraestructura local segura de Cortex, este modelo puede ayudarlo en una amplia gama de tareas, desde lluvia de ideas creativa hasta análisis técnicos profundos. Comience a explorar todo su potencial hoy."
    },
    "fr": {
        "defaultSeriesDescription": "{seriesName} est une intelligence avancée affichant des performances élevées sur Cortex.",
        "defaultModelDescription": "{modelName} est une intelligence artificielle très performante intégrée à l'écosystème Cortex. Conçue pour accomplir une grande variété de tâches complexes, elle offre des capacités de traitement hautement fiables et efficaces. En offrant des temps de réponse rapides et une puissance analytique avancée, elle augmente considérablement votre productivité quotidienne. Fonctionnant de manière transparente sur l'infrastructure locale sécurisée de Cortex, ce modèle peut vous aider dans un large éventail de tâches, du brainstorming créatif à l'analyse technique approfondie. Commencez à explorer tout son potentiel dès aujourd'hui."
    },
    "hi": {
        "defaultSeriesDescription": "{seriesName} एक उन्नत बुद्धिमत्ता है जो Cortex पर उच्च प्रदर्शन दिखाती है।",
        "defaultModelDescription": "{modelName} Cortex पारिस्थितिकी तंत्र में एकीकृत एक उच्च-प्रदर्शन कृत्रिम बुद्धिमत्ता है। जटिल कार्यों की एक विस्तृत विविधता को जीतने के लिए डिज़ाइन किया गया, यह अत्यधिक विश्वसनीय और कुशल प्रसंस्करण क्षमता प्रदान करता है। त्वरित प्रतिक्रिया समय और उन्नत विश्लेषणात्मक शक्ति प्रदान करके, यह आपकी दैनिक उत्पादकता को काफी बढ़ाता है। Cortex के सुरक्षित स्थानीय बुनियादी ढांचे पर निर्बाध रूप से काम करते हुए, यह मॉडल रचनात्मक बुद्धिशीलता से लेकर गहरे तकनीकी विश्लेषण तक, कई कार्यों में आपकी सहायता कर सकता है। आज ही इसकी पूरी क्षमता की खोज शुरू करें।"
    },
    "id": {
        "defaultSeriesDescription": "{seriesName} adalah kecerdasan maju yang menunjukkan performa tinggi di Cortex.",
        "defaultModelDescription": "{modelName} adalah kecerdasan buatan berkinerja tinggi yang terintegrasi di dalam ekosistem Cortex. Dirancang untuk menaklukkan berbagai macam tugas kompleks, ia memberikan kemampuan pemrosesan yang sangat andal dan efisien. Dengan menawarkan waktu respons yang cepat dan kekuatan analitis tingkat lanjut, ini secara signifikan meningkatkan produktivitas harian Anda. Beroperasi dengan lancar di infrastruktur lokal Cortex yang aman, model ini dapat membantu Anda dalam berbagai spektrum tugas, mulai dari curah pendapat kreatif hingga analisis teknis mendalam. Mulailah menjelajahi potensi penuhnya hari ini."
    },
    "it": {
        "defaultSeriesDescription": "{seriesName} è un'intelligenza avanzata che mostra prestazioni elevate su Cortex.",
        "defaultModelDescription": "{modelName} è un'intelligenza artificiale ad alte prestazioni integrata nell'ecosistema Cortex. Progettata per conquistare un'ampia varietà di compiti complessi, fornisce capacità di elaborazione altamente affidabili ed efficienti. Offrendo tempi di risposta rapidi e potenza analitica avanzata, aumenta in modo significativo la tua produttività quotidiana. Operando senza interruzioni sull'infrastruttura locale sicura di Cortex, questo modello può assisterti in un ampio spettro di compiti, dal brainstorming creativo all'analisi tecnica profonda. Inizia a esplorare il suo pieno potenziale oggi stesso."
    },
    "ja": {
        "defaultSeriesDescription": "{seriesName}は、Cortex上で高いパフォーマンスを発揮する高度な知能です。",
        "defaultModelDescription": "{modelName}は、Cortexエコシステムに統合された高性能な人工知能です。さまざまな複雑なタスクを克服するように設計されており、信頼性が高く効率的な処理機能を提供します。迅速な応答時間と高度な分析能力を提供することで、日常の生産性を大幅に向上させます。Cortexの安全なローカルインフラストラクチャ上でシームレスに動作するこのモデルは、創造的なブレインストーミングから深い技術分析まで、幅広いタスクでユーザーを支援します。今日からその可能性を最大限に引き出しましょう。"
    },
    "ko": {
        "defaultSeriesDescription": "{seriesName}은(는) Cortex에서 고성능을 발휘하는 고급 인공지능입니다.",
        "defaultModelDescription": "{modelName}은(는) Cortex 생태계에 통합된 고성능 인공지능입니다. 다양하고 복잡한 작업을 극복하도록 설계되어 고도로 안정적이고 효율적인 처리 기능을 제공합니다. 빠른 응답 시간과 향상된 분석 기능을 제공하여 일상적인 생산성을 크게 높입니다. Cortex의 안전한 로컬 인프라에서 원활하게 작동하는 이 모델은 창의적인 브레인스토밍부터 심층적인 기술 분석까지 광범위한 작업에서 사용자를 지원할 수 있습니다. 오늘부터 그 잠재력을 최대한 활용해 보세요."
    },
    "ku": {
        "defaultSeriesDescription": "{seriesName} zîrekiyek pêşkeftî ye ku performansa bilind li ser Cortex nîşan dide.",
        "defaultModelDescription": "{modelName} hişmendiyek çêkirî ya bi performansa bilind e ku di hundurê ekosîstema Cortex de yekbûyî ye. Ji bo têkbirina cûrbecûr karên tevlihev hatî çêkirin, ew kapasîteyên pêvajoyek pir pêbawer û bikêr peyda dike. Bi pêşkêşkirina demên bersivdana bilez û hêza analîtîk a pêşkeftî, ew hilberîna weya rojane bi girîngî zêde dike. Vê modela ku bi rengek bêkêmasî li ser binesaziya herêmî ya ewledar a Cortex kar dike, dikare di berfirehiyek kar de ji we re bibe alîkar, ji berhevkirina ramanên afirîner heya vekolîna teknîkî ya kûr. Îro dest bi vekolîna potansiyela wê ya tevahî bikin."
    },
    "nl": {
        "defaultSeriesDescription": "{seriesName} is een geavanceerde intelligentie die hoge prestaties levert op Cortex.",
        "defaultModelDescription": "{modelName} is een hoogwaardige kunstmatige intelligentie geïntegreerd binnen het Cortex-ecosysteem. Ontworpen om een grote verscheidenheid aan complexe taken te overwinnen, biedt het zeer betrouwbare en efficiënte verwerkingsmogelijkheden. Door snelle responstijden en geavanceerde analytische kracht te bieden, verhoogt het uw dagelijkse productiviteit aanzienlijk. Dit model werkt naadloos op de veilige lokale infrastructuur van Cortex en kan u helpen bij een breed scala aan taken, van creatieve brainstormsessies tot diepgaande technische analyses. Begin vandaag nog met het verkennen van zijn volledige potentieel."
    },
    "pt": {
        "defaultSeriesDescription": "{seriesName} é uma inteligência avançada demonstrando alto desempenho no Cortex.",
        "defaultModelDescription": "{modelName} é uma inteligência artificial de alto desempenho integrada ao ecossistema Cortex. Projetada para conquistar uma ampla variedade de tarefas complexas, oferece capacidades de processamento altamente confiáveis e eficientes. Ao oferecer tempos de resposta rápidos e poder analítico avançado, aumenta significativamente sua produtividade diária. Operando perfeitamente na infraestrutura local segura do Cortex, este modelo pode auxiliá-lo em um amplo espectro de tarefas, desde brainstorming criativo a análises técnicas profundas. Comece a explorar todo o seu potencial hoje."
    },
    "ru": {
        "defaultSeriesDescription": "{seriesName} — это продвинутый интеллект, демонстрирующий высокую производительность в Cortex.",
        "defaultModelDescription": "{modelName} — это высокопроизводительный искусственный интеллект, интегрированный в экосистему Cortex. Разработанный для решения широкого круга сложных задач, он обеспечивает высоконадежные и эффективные возможности обработки. Предлагая быстрое время отклика и расширенные аналитические возможности, он значительно повышает вашу повседневную производительность. Безупречно работая в безопасной локальной инфраструктуре Cortex, эта модель может помочь вам в широком спектре задач: от творческого мозгового штурма до глубокого технического анализа. Начните изучать весь его потенциал сегодня."
    },
    "zh": {
        "defaultSeriesDescription": "{seriesName}是一款在Cortex上展现出高性能的先进智能。",
        "defaultModelDescription": "{modelName}是集成在Cortex生态系统内的高性能人工智能。旨在克服各种复杂任务，提供高度可靠高效的处理能力。通过提供快速响应时间和高级分析能力，它能显著提高您的日常生产力。该模型能够在Cortex的安全本地基础设施上无缝运行，协助您完成从创意头脑风暴到深度技术分析等各种任务。今天就开始探索其全部潜力吧。"
    }
}

d = "/home/baba/Documents/Vertex/Cortex/cortex/lib/l10n"
files = [f for f in os.listdir(d) if f.endswith(".arb")]

for file in files:
    lang = file.replace("app_", "").replace(".arb", "")
    if lang in translations:
        path = os.path.join(d, file)
        try:
            with open(path, "r", encoding="utf-8") as f:
                data = json.load(f)
            data["defaultSeriesDescription"] = translations[lang]["defaultSeriesDescription"]
            data["defaultModelDescription"] = translations[lang]["defaultModelDescription"]
            with open(path, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=4, ensure_ascii=False)
            print(f"Fixed {lang}")
        except Exception as e:
            print(f"Failed {lang}: {e}")
