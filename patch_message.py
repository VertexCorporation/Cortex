import re

with open('/home/baba/Documents/Vertex/General/functions/src/message.js', 'r') as f:
    text = f.read()

old_block = """          // 1. TIER 1: GROQ llama-3.3-70b-versatile
          let apiUrl = OPENROUTER_API_URL;
          if (finalPayload.model === "llama-3.3-70b-versatile") {
            apiUrl = GROQ_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${groqApiKey}`;
          } else {
            fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;
          }

          let payloadToSend = { ...finalPayload };
          if (apiUrl === GROQ_API_URL) {
            delete payloadToSend.route;
            delete payloadToSend.models;
            delete payloadToSend.plugins;
          }

          let openRouterResponse = await fetch(apiUrl, {
            ...fetchOptions,
            body: JSON.stringify(payloadToSend)
          });

          // 2. TIER 2: openai/gpt-oss-120b (GROQ)
          if (finalPayload.model === "llama-3.3-70b-versatile" && !openRouterResponse.ok) {
            const status = openRouterResponse.status;
            logger.warn(`[RETRY_STRATEGY] Primary model failed with status ${status}. Falling back to openai/gpt-oss-120b on Groq...`);
            try { await openRouterResponse.text(); } catch (e) { }

            finalPayload.model = "openai/gpt-oss-120b";
            apiUrl = GROQ_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${groqApiKey}`;

            let groqPayloadTier2 = { ...finalPayload };
            delete groqPayloadTier2.route;
            delete groqPayloadTier2.models;
            delete groqPayloadTier2.plugins;

            openRouterResponse = await fetch(apiUrl, {
              ...fetchOptions,
              body: JSON.stringify(groqPayloadTier2)
            });
          }

          // 3. TIER 3: OPENROUTER dynamicModelsPromise (Fallback Array)
          if (finalPayload.model === "openai/gpt-oss-120b" && !openRouterResponse.ok && dynamicModelsPromise) {
            const status = openRouterResponse.status;
            logger.warn(`[RETRY_STRATEGY] Secondary model failed with status ${status}. Falling back to OpenRouter dynamic list...`);
            try { await openRouterResponse.text(); } catch (e) { }

            const smartCandidates = await dynamicModelsPromise;
            finalPayload.models = smartCandidates;
            finalPayload.route = 'fallback';
            delete finalPayload.model;
            
            apiUrl = OPENROUTER_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;

            openRouterResponse = await fetch(apiUrl, {
              ...fetchOptions,
              body: JSON.stringify(finalPayload)
            });
          }
          
          // 4. TIER 4: OPENROUTER openrouter/auto (Ultimate Fallback)
          if (!finalPayload.model && finalPayload.models && !openRouterResponse.ok) {
            const status = openRouterResponse.status;
            logger.warn(`[RETRY_STRATEGY] Dynamic List failed with status ${status}. Falling back to openrouter/auto...`);
            try { await openRouterResponse.text(); } catch (e) { }

            delete finalPayload.models;
            finalPayload.model = "openrouter/auto";
            finalPayload.route = 'fallback';

            apiUrl = OPENROUTER_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;

            openRouterResponse = await fetch(apiUrl, {
              ...fetchOptions,
              body: JSON.stringify(finalPayload)
            });
          }"""

new_block = """          let openRouterResponse;
          let apiUrl = OPENROUTER_API_URL;

          // Eğer istek cortex/auto içerisinden dinamik olarak yaratıldıysa ve web araması kapalıysa YENİ 4-KATMANLI AKIŞ:
          if (isDynamicChat && !enableWebSearch && finalPayload.model === "llama-3.3-70b-versatile") {
            
            // 1. TIER 1: GROQ llama-3.3-70b-versatile
            apiUrl = GROQ_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${groqApiKey}`;

            let payloadToSend = { ...finalPayload };
            delete payloadToSend.route;
            delete payloadToSend.models;
            delete payloadToSend.plugins;

            openRouterResponse = await fetch(apiUrl, {
              ...fetchOptions,
              body: JSON.stringify(payloadToSend)
            });

            // 2. TIER 2: openai/gpt-oss-120b (GROQ)
            if (!openRouterResponse.ok) {
              const status = openRouterResponse.status;
              logger.warn(`[RETRY_STRATEGY] Primary model failed with status ${status}. Falling back to openai/gpt-oss-120b on Groq...`);
              try { await openRouterResponse.text(); } catch (e) {}

              finalPayload.model = "openai/gpt-oss-120b";
              // apiUrl is still GROQ_API_URL

              let groqPayloadTier2 = { ...finalPayload };
              delete groqPayloadTier2.route;
              delete groqPayloadTier2.models;
              delete groqPayloadTier2.plugins;

              openRouterResponse = await fetch(apiUrl, {
                ...fetchOptions,
                body: JSON.stringify(groqPayloadTier2)
              });
            }

            // 3. TIER 3: OPENROUTER dynamicModelsPromise (Fallback Array)
            if (!openRouterResponse.ok && dynamicModelsPromise) {
              const status = openRouterResponse.status;
              logger.warn(`[RETRY_STRATEGY] Secondary model failed with status ${status}. Falling back to OpenRouter dynamic list...`);
              try { await openRouterResponse.text(); } catch (e) {}

              const smartCandidates = await dynamicModelsPromise;
              finalPayload.models = smartCandidates;
              finalPayload.route = 'fallback';
              delete finalPayload.model;
              
              apiUrl = OPENROUTER_API_URL;
              fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;

              openRouterResponse = await fetch(apiUrl, {
                ...fetchOptions,
                body: JSON.stringify(finalPayload)
              });
            }
            
            // 4. TIER 4: OPENROUTER openrouter/auto (Ultimate Fallback)
            if (!openRouterResponse.ok) {
              const status = openRouterResponse.status;
              logger.warn(`[RETRY_STRATEGY] Dynamic List failed with status ${status}. Falling back to openrouter/auto...`);
              try { await openRouterResponse.text(); } catch (e) {}

              delete finalPayload.models;
              finalPayload.model = "openrouter/auto";
              finalPayload.route = 'fallback';

              apiUrl = OPENROUTER_API_URL;
              fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;

              openRouterResponse = await fetch(apiUrl, {
                ...fetchOptions,
                body: JSON.stringify(finalPayload)
              });
            }
            
          } else {
            // KLASİK AKIŞ: Kullanıcı kendisi model seçtiyse VEYA Web Araması varsa
            // Hepsini OpenRouter'a gönder! Araçlar/Eklentiler bozulmaz.
            apiUrl = OPENROUTER_API_URL;
            fetchOptions.headers["Authorization"] = `Bearer ${openRouterApiKey}`;
            
            openRouterResponse = await fetch(apiUrl, {
              ...fetchOptions,
              body: JSON.stringify(finalPayload)
            });
          }"""

new_text = text.replace(old_block, new_block)
with open('/home/baba/Documents/Vertex/General/functions/src/message.js', 'w') as f:
    f.write(new_text)

print("Patch applied.")
